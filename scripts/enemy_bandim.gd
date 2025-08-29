extends CharacterBody2D

@export var data: EnemyData

enum State {
	RANDOM,
	IDLE,
	JUMP,
	CHASE,
	FIRE,
	DIE,
	WAIT_FOR_EAT,
	KNOCKBACK,
}

const SPEED: float = 200.0
const MAX_HEALTH: float = 100.0
const KNOCKBACK_FORCE_X: float = 10.0
const KNOCKBACK_FORCE_Y: float = -30.0
const KNOCKBACK_TIME: float = 0.7
const IDLE_TIME: float = 1.0
const FIRE_ANIM_TIME: float = 1.0
const FIRE_TIME: float = FIRE_ANIM_TIME / 2.0
const MAX_FIRE: float = 10.0
const MAX_CHASE_BEFORE_ESCAPE: int = 3
const CHASE_LIMIT_MAX: float = 150.0
const CHASE_LIMIT_MIN: float = 50.0

var accel: float = 200.0 
var state: State = State.RANDOM
var last_state: State = state
var current_target_x: float
var knockback: Vector2
var knockback_timer: float = 0.0
var health: float = MAX_HEALTH
var need_new_target: bool = true
var skipped_possible_jump: bool = false
var idle_timer: float = IDLE_TIME
var fire_anim_timer: float = FIRE_ANIM_TIME
var fire_timer: float = FIRE_TIME
var player_offset: float = 0.0
var first_chase: bool = true
var chase_count: int = 0

@onready var flash_timer: Timer = $FlashTimer
@onready var head: Marker2D = $Head
@onready var root: Node2D = $Root
@onready var sprite: AnimatedSprite2D = $Root/AnimatedSprite2D
@onready var obstacle_ray: RayCast2D = $Root/ObstacleRay
@onready var optional_jump_ray: RayCast2D = $Root/OptionalJumpRay
@onready var head_ray: RayCast2D = $Root/HeadRay
@onready var trunk: Marker2D = $Root/Trunk


func change_state(new_state: State) -> void:
	last_state = state
	if last_state in [State.DIE, State.WAIT_FOR_EAT] and not new_state in [State.WAIT_FOR_EAT]:
		return
	state = new_state
	if state == State.CHASE:
		if first_chase:
			player_offset = randf_range(CHASE_LIMIT_MIN, CHASE_LIMIT_MAX)
			first_chase = false
			chase_count = 0
	elif state == State.FIRE:
		fire_anim_timer = FIRE_ANIM_TIME
		fire_timer = FIRE_TIME
	elif state == State.IDLE:
		idle_timer = IDLE_TIME
	elif state == State.RANDOM and need_new_target:
		current_target_x = randf_range(Global.enemy_manager.world_limit_min, Global.enemy_manager.world_limit_max)
		need_new_target = false


func _ready() -> void:
	change_state(State.RANDOM)
	$DeadArea/CollisionShape2D.disabled = true


func eat() -> float:
	#for now
	call_deferred("queue_free")
	return data.xp_gain


func damage(amount: float, up: bool) -> void:
	health -= amount
	if health <= 0:
		change_state(State.DIE)
		flash_timer.start()
		sprite.material.set_shader_parameter("line_scale", 0.0)
		sprite.material.set_shader_parameter("flash_amount", 0.5)
		sprite.material.set_shader_parameter("flash_light", Vector4(1.0, 0.0, 0.0, 1.0))
	else:
		flash_timer.start()
		sprite.material.set_shader_parameter("flash_amount", 0.8)


func damage_from_up(raw_nearness: float, mass: float, direct_damage: float = 0.0) -> void:
	if state in [State.DIE, State.WAIT_FOR_EAT]: return
	var nearness: float = absf(raw_nearness)
	apply_knockback(
		KNOCKBACK_TIME * nearness * Global.rng.randf_range(0.8, 1.2),
		Vector2(
			raw_nearness * mass * KNOCKBACK_FORCE_X * Global.rng.randf_range(0.8, 1.2),
			nearness * mass * KNOCKBACK_FORCE_Y * Global.rng.randf_range(0.8, 1.2),
		)
	)
	var damage_amount: float = mass * nearness * 2 if direct_damage == 0.0 else direct_damage
	damage(damage_amount, true)


func damage_hand(location: Vector2, amount: float) -> void:
	if state in [State.DIE, State.WAIT_FOR_EAT]: return
	player_offset = randf_range(player_offset, CHASE_LIMIT_MAX)
	chase_count = MAX_CHASE_BEFORE_ESCAPE - 1
	change_state(State.CHASE)
	#apply_knockback(
	#	KNOCKBACK_TIME * 0.1,
	#	Vector2(sign(global_position.x - location.x) * 500, -100)
	#)
	damage(amount, false)


func apply_knockback(time: float, force: Vector2) -> void:
	knockback = force
	if force.y != 0:
		velocity.y = force.y
	knockback_timer = time
	change_state(State.KNOCKBACK)


func _process(delta: float) -> void:
	if velocity.x != 0: root.scale.x = 1 if velocity.x > 0 else -1
	var player_position: Vector2 = Global.player_manager.player.global_position

	if Global.enemy_manager.lock:
		if not state in [State.DIE, State.WAIT_FOR_EAT]:
			sprite.play("idle")
		return

	if state == State.DIE:
		if velocity.y == 0:
			sprite.play("die")
	elif state == State.WAIT_FOR_EAT:
		sprite.play("die_wait")
	elif state == State.FIRE:
		root.scale.x = 1 if global_position.x < player_position.x else -1
		sprite.play("hit")
	elif velocity == Vector2.ZERO:
		sprite.play("idle")
	elif velocity.y != 0:
		sprite.play("jump")
	else:
		sprite.play("run")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Global.enemy_manager.lock: return

	var player_position: Vector2 = Global.player_manager.player.global_position

	if state == State.CHASE:
		var target_x: float = player_position.x + player_offset if global_position.x > player_position.x else player_position.x - player_offset

		target_x = clampf(target_x, Global.enemy_manager.world_limit_min, Global.enemy_manager.world_limit_max)

		velocity.x = global_position.direction_to(Vector2(target_x, global_position.y)).x * SPEED
		if obstacle_ray.is_colliding() and is_on_floor():
			velocity.y = -300
		if skipped_possible_jump and head_ray.is_colliding():
			skipped_possible_jump = false
		if optional_jump_ray.is_colliding() and is_on_floor() and not head_ray.is_colliding():
			if not skipped_possible_jump:
				if head.global_position.y > player_position.y:
					change_state(State.JUMP)
				else:
					skipped_possible_jump = true
		if abs(global_position.x - target_x) < Global.EPS:
			velocity.x = 0
			chase_count += 1
			if chase_count == MAX_CHASE_BEFORE_ESCAPE:
				#polisten kaçın
				player_offset = randf_range(player_offset, CHASE_LIMIT_MAX)
				change_state(State.FIRE)
			elif chase_count == MAX_CHASE_BEFORE_ESCAPE + 1:
				chase_count = 0
				#for keeping direction true
				velocity.x = (player_position.x - global_position.x) * 0.05 
				change_state(State.IDLE)
			else:
				player_offset = randf_range(CHASE_LIMIT_MIN, player_offset)
				change_state(State.FIRE)
	elif state == State.FIRE:
		fire_anim_timer -= delta
		fire_timer -= delta
		if fire_timer < 0:
			fire_timer = FIRE_TIME
			Global.projectile_manager.spawn(Projectile.Type.BANDIM, trunk.global_position, (player_position - trunk.global_position).normalized(), data)
		if fire_anim_timer < 0:
			change_state(State.CHASE)
	elif state == State.DIE:
		velocity.x = 0
	elif state == State.RANDOM:
		velocity.x = global_position.direction_to(Vector2(current_target_x, global_position.y)).x * SPEED
		if obstacle_ray.is_colliding() and is_on_floor():
			velocity.y = -300
		#worst shit
		if skipped_possible_jump and head_ray.is_colliding():
			skipped_possible_jump = false
		if optional_jump_ray.is_colliding() and is_on_floor() and not head_ray.is_colliding():
			if not skipped_possible_jump:
				if Global.rng.randi() % 2 == 1:
					change_state(State.JUMP)
				else:
					skipped_possible_jump = true
		if abs(global_position.x - current_target_x) < Global.EPS:
			change_state(State.IDLE)
			velocity.x = 0
	elif state == State.IDLE:
		velocity.x = 0
		idle_timer -= delta
		if idle_timer < 0:
			need_new_target = true
			change_state(last_state)
	elif state == State.JUMP:
		velocity.y = -500
		if not optional_jump_ray.is_colliding() or head_ray.is_colliding():
			change_state(last_state)
	elif state == State.KNOCKBACK:
		if knockback_timer > 0.0:
			knockback_timer -= delta
			velocity.x = knockback.x
			if knockback_timer <= 0.0:
				knockback.x = 0.0
				change_state(last_state)

	move_and_slide()


func _on_flash_timer_timeout() -> void:
	sprite.material.set_shader_parameter("flash_amount", 0.0)
	sprite.material.set_shader_parameter("flash_light", Vector4(1.0, 1.0, 1.0, 1.0))
	sprite.material.set_shader_parameter("line_scale", 0.0)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die":
		$DeadArea/CollisionShape2D.disabled = false
		$DashHurtArea/CollisionShape2D.disabled = true
		change_state(State.WAIT_FOR_EAT)


func _on_player_chase_area_area_entered(area: Area2D) -> void:
	if Global.enemy_manager.lock: return
	if not area.is_in_group("Player"): return
	if not state in [State.CHASE, State.FIRE]: first_chase = true
	change_state(State.CHASE)


func _on_player_chase_exit_area_area_exited(area: Area2D) -> void:
	if Global.enemy_manager.lock: return
	if not area.is_in_group("Player"): return
	if state in [State.CHASE, State.FIRE, State.IDLE]:
		need_new_target = true
		change_state(State.RANDOM)

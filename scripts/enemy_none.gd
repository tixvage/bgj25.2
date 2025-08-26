extends CharacterBody2D

@export var data: EnemyData

enum State {
	RANDOM,
	JUMP,
	KNOCKBACK,
}

const MAX_HEALTH: float = 100.0
const KNOCKBACK_FORCE_X: float = 10.0
const KNOCKBACK_FORCE_Y: float = -30.0
const KNOCKBACK_TIME: float = 0.7

var accel: float = 200.0 
var state: State = State.RANDOM
var current_target_x: float
var knockback: Vector2
var knockback_timer: float = 0.0
var health: float = MAX_HEALTH
var need_new_target: bool = false
var skipped_possible_jump: bool = false

@onready var flash_timer: Timer = $FlashTimer
@onready var sprite: Sprite2D = $Root/Sprite2D
@onready var obstacle_ray: RayCast2D = $Root/ObstacleRay
@onready var optional_jump_ray: RayCast2D = $Root/OptionalJumpRay
@onready var head_ray: RayCast2D = $Root/HeadRay
@onready var root: Node2D = $Root

func change_state(new_state: State) -> void:
	state = new_state
	if state == State.RANDOM and need_new_target:
		current_target_x = randf_range(Global.enemy_manager.world_limit_min, Global.enemy_manager.world_limit_max)
		need_new_target = false

func _ready() -> void:
	change_state(State.RANDOM)


func die() -> void:
	queue_free()


func damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()
	
	flash_timer.start()
	sprite.material.set_shader_parameter("flash_amount", 0.8)


func damage_from_up(raw_nearness: float, mass: float) -> void:
	var nearness: float = absf(raw_nearness)
	apply_knockback(
		KNOCKBACK_TIME * nearness * Global.rng.randf_range(0.8, 1.2),
		Vector2(
			raw_nearness * mass * KNOCKBACK_FORCE_X * Global.rng.randf_range(0.8, 1.2),
			nearness * mass * KNOCKBACK_FORCE_Y * Global.rng.randf_range(0.8, 1.2),
		)
	)
	var damage_amount: float = mass * nearness * 2
	damage(damage_amount)
	change_state(State.KNOCKBACK)


func apply_knockback(time: float, force: Vector2) -> void:
	knockback = force
	velocity.y = force.y
	knockback_timer = time


func _physics_process(delta: float) -> void:
	root.scale.x = 1 if velocity.x > 0 else -1

	if not is_on_floor():
		velocity += get_gravity() * delta

	if state == State.RANDOM:
		if abs(global_position.x - current_target_x) < Global.EPS:
			need_new_target = true
			change_state(State.RANDOM)
		velocity.x = global_position.direction_to(Vector2(current_target_x, global_position.y)).x * 200.0
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
	elif state == State.JUMP:
		velocity.y = -500
		if not optional_jump_ray.is_colliding() or head_ray.is_colliding():
			change_state(State.RANDOM)
	elif state == State.KNOCKBACK:
		if knockback_timer > 0.0:
			knockback_timer -= delta
			velocity.x = knockback.x
			if knockback_timer <= 0.0:
				knockback.x = 0.0
				change_state(State.RANDOM)

	move_and_slide()


func _on_flash_timer_timeout() -> void:
	sprite.material.set_shader_parameter("flash_amount", 0.0)

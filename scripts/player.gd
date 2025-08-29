extends CharacterBody2D
class_name Player

@export var player_datas: Array[PlayerData]

@export var ground_accel := 2500.0
@export var air_accel := 1800.0
@export var coyote_time := 0.15

const DASH_FORCE: float = 90.0
const DASH_LIMIT: float = 150.0
const SHAKE_FORCE: float = 1.0
const WEIGHT_ANIM_MAX: int = 8

@onready var shader_timer: Timer = $ShaderTimer
@onready var dash_ray: RayCast2D = $DashRay
@onready var ghost_spawn_timer: Timer = $GhostSpawnTimer
@onready var dash_damage_area: Area2D = $DashDamageArea
@onready var dash_damage_collision: CollisionShape2D = $DashDamageArea/CollisionShape2D
@onready var body_area: Area2D = $Body 
@onready var root: Node2D = $Root
#@onready var sprite: Sprite2D = $Root/Sprite2D
@onready var feet_mid: Node2D = $Root/FeetMid
@onready var move_particle: CPUParticles2D = $Root/MoveParticle
@onready var sprite: AnimatedSprite2D = $Root/AnimatedSprite2D
@onready var hand_area: Area2D = $Root/HandArea

@onready var player_ghost_scene := preload("res://scenes/player_ghost.tscn")

var xp: float = 0.0
var current_data: int
var is_dashing: bool = false
var is_falling: bool = false
var dash_distance: float = 0.0
var coyote_timer: float = 0.0
var locked: bool = false
var weight_change: bool = false
var weight_anim_count: int = 0
var chocolate_amount: float = 0.0

var data: PlayerData : get = get_current_data 


func next_data() -> void:
	xp = 0
	chocolate_amount = 0
	sprite.material.set_shader_parameter("chocolate_amount", chocolate_amount)
	current_data += 1


func _ready() -> void:
	Global.player_manager.player = self
	change_data(0)
	play_animation("idle")


func get_animation() -> String:
	return sprite.animation.substr(0, len(sprite.animation) - 2)


func play_animation(name: String) -> void:
	sprite.play(name + "_" + str(current_data + 1))


func change_data(new_data: int) -> void:
	current_data = new_data
	dash_damage_collision.shape.size = data.damage_area


func damage(xp_steal: float, projectile: bool = false) -> void:
	add_xp(-xp_steal)
	var anim := get_animation()
	shader_timer.start()
	if projectile and anim != "dash_end":
		chocolate_amount += 0.05
		sprite.material.set_shader_parameter("chocolate_amount", chocolate_amount)
	else:
		sprite.material.set_shader_parameter("flash_light", Vector4(1.0, 0.0, 0.0, 1.0))
		sprite.material.set_shader_parameter("flash_amount", 0.7)
	Global.camera_manager.shake(SHAKE_FORCE * 0.6, 10)


func get_fat():
	Global.enemy_manager.lock = true
	weight_change = true
	shader_timer.stop()
	shader_timer.start()
	sprite.material.set_shader_parameter("flash_light", Vector4(1.0, 1.0, 1.0, 1.0))
	sprite.material.set_shader_parameter("flash_amount", 0.7)
	next_data()
	play_animation("change")


func add_xp(amount: float) -> void:
	xp += amount
	xp = min(xp, data.required_xp_for_next)
	Global.stat_manager.update_xp(xp, data.required_xp_for_next)
	if xp == data.required_xp_for_next:
		get_fat()


func get_current_data() -> PlayerData:
	return player_datas[current_data]


func start_dash() -> void:
	is_dashing = true
	dash_distance = position.y

	ghost_spawn_timer.one_shot = false
	ghost_spawn_timer.start()

	Global.audio_manager.create_audio(SoundEffect.Type.DASH_START)

	if velocity.y < 0.0:
		velocity.y = DASH_FORCE * data.mass
	else:
		velocity.y += DASH_FORCE * data.mass


func stop_dash() -> void:
	shader_timer.start()
	chocolate_amount = 0.0
	sprite.material.set_shader_parameter("chocolate_amount", chocolate_amount)

	play_animation("dash_end")
	is_dashing = false
	dash_distance = position.y - dash_distance
	ghost_spawn_timer.one_shot = true
	var dash_power: float = 1.0 + min(1.0, dash_distance / (dash_ray.target_position.y * 2.0))
	dash_distance = 0.0

	Global.audio_manager.create_audio(SoundEffect.Type.DASH_END)
	Global.particle_manager.spawn(Particle.Type.DASH_END, global_position)
	Global.camera_manager.shake(SHAKE_FORCE * data.mass * dash_power, 5)
	var bodies := dash_damage_area.get_overlapping_areas()
	for body in bodies:
		if body.is_in_group("EnemyDash"):
			var distance: float = absf(position.x - body.global_position.x)
			#0.5 min - 1.5 max
			var nearness: float = max(0.0, 1.0 - (distance / (data.damage_area.x / 2.0))) + 0.5
			if nearness != 0.5:
				var raw_nearness: float = nearness if position.x < body.global_position.x else -nearness
				body.get_parent().damage_from_up(raw_nearness, data.mass)


func _process(delta: float) -> void:
	if velocity.x != 0: root.scale.x = 1 if velocity.x > 0 else -1

	var anim := get_animation()
	if not anim in ["hit", "dash_end", "finger", "river", "change"]:
		if is_dashing:
			play_animation("dash_start")
		if velocity == Vector2.ZERO:
			play_animation("idle")
		elif velocity.y != 0:
			play_animation("jump")
		else:
			play_animation("run")

	var can_hit = not locked
	var can_eat = not locked

	if Input.is_action_just_pressed("fire") and can_hit:
		play_animation("hit")
		var bodies := hand_area.get_overlapping_areas()
		for body in bodies:
			if body.is_in_group("EnemyDash"):
				body.get_parent().damage_hand(global_position, data.damage_amount)
				Global.audio_manager.create_audio(SoundEffect.Type.HIT)
				break

	if Input.is_action_just_pressed("eat") and can_eat:
		var eat_animations := ["river", "finger"]
		var bodies := body_area.get_overlapping_areas()
		for body in bodies:
			if body.is_in_group("EnemyDead"):
				var xp_gain: float = body.get_parent().eat()
				play_animation(eat_animations[randi() % len(eat_animations)])
				add_xp(xp_gain)
				break


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var can_jump: bool = coyote_timer > 0.0 and velocity.y >= 0 and not locked
	if on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	var can_dash: bool = not on_floor and not dash_ray.is_colliding() and not locked
	var can_move: bool = not is_dashing and not locked
	var accel = ground_accel if on_floor else air_accel


	if not on_floor:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_down") and can_dash:
		start_dash()

	if on_floor and is_dashing:
		stop_dash()

	if is_falling and on_floor:
		Global.particle_manager.spawn(Particle.Type.JUMP_END, feet_mid.global_position)
		is_falling = false

	if not is_falling and velocity.y > 0:
		is_falling = true

	if Input.is_action_just_pressed("move_up") and can_jump:
		velocity.y = -data.jump_force

	var direction := Input.get_axis("move_left", "move_right") if can_move else 0.0
	move_particle.emitting = velocity.x != 0.0 and on_floor
	var velocity_sign_old := signf(velocity.x)
	velocity.x = move_toward(velocity.x, direction * data.move_speed, accel * delta)
	var velocity_sign_new := signf(velocity.x)
	#direction changed
	if velocity_sign_old != velocity_sign_new and velocity_sign_new != 0 and on_floor:
		Global.particle_manager.spawn(Particle.Type.JUMP_END, feet_mid.global_position)

	move_and_slide()


func _on_ghost_spawn_timer_timeout() -> void:
	return
	var ghost_instance = player_ghost_scene.instantiate()
	#ghost_instance.apply_sprite(sprite, position)
	get_parent().add_child(ghost_instance)


func _on_animated_sprite_2d_animation_finished() -> void:
	var anim := get_animation()
	#if anim in ["dash_end", "river", "finger"]:
	locked = false
	if anim in ["change"]:
		add_xp(0)
	if anim in ["hit", "dash_end", "river", "finger", "change"]:
		play_animation("idle")


func _on_animated_sprite_2d_animation_changed() -> void:
	var anim := get_animation()
	if anim in ["dash_end", "river", "finger", "change"]:
		locked = true


func _on_shader_timer_timeout() -> void:
	if weight_change:
		shader_timer.start()
		if weight_anim_count % 2 == 0:
			sprite.material.set_shader_parameter("flash_amount", 0.0)
		else:
			sprite.material.set_shader_parameter("flash_amount", 0.7)
		weight_anim_count += 1
		if weight_anim_count == WEIGHT_ANIM_MAX:
			weight_anim_count = 0
			weight_change = false
			Global.enemy_manager.lock = false
	else:
		sprite.material.set_shader_parameter("flash_amount", 0.0)
		sprite.material.set_shader_parameter("flash_light", Vector4(1.0, 1.0, 1.0, 1.0))
		sprite.material.set_shader_parameter("line_scale", 0.0)

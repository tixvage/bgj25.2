extends CharacterBody2D

@export var data: EnemyData

enum State {
	RANDOM,
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


func change_state(new_state: State) -> void:
	state = new_state
	if state == State.RANDOM:
		current_target_x = randf_range(Global.enemy_manager.world_limit_min, Global.enemy_manager.world_limit_max)


func _ready() -> void:
	change_state(State.RANDOM)


func die() -> void:
	queue_free()


func damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die() 


func damage_from_up(raw_nearness: float, mass: float) -> void:
	var nearness: float = absf(raw_nearness)
	apply_knockback(
		KNOCKBACK_TIME * nearness * Global.rng.randf_range(0.8, 1.2),
		Vector2(
			raw_nearness * mass * KNOCKBACK_FORCE_X * Global.rng.randf_range(0.8, 1.2),
			nearness * mass * KNOCKBACK_FORCE_Y * Global.rng.randf_range(0.8, 1.2),
		)
	)
	var damage_amount: float = mass * nearness * 5
	damage(damage_amount)


func apply_knockback(time: float, force: Vector2) -> void:
	knockback = force
	velocity.y = force.y
	knockback_timer = time


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if state == State.RANDOM:
		if abs(global_position.x - current_target_x) < Global.EPS:
			change_state(State.RANDOM)

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = knockback.x
		if knockback_timer <= 0.0:
			knockback.x = 0.0
	else:
		velocity.x = global_position.direction_to(Vector2(current_target_x, global_position.y)).x * 200.0
		#velocity.x = move_toward(velocity.x, 0, delta * accel)
	move_and_slide()

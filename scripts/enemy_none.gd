extends CharacterBody2D

enum State {
	RANDOM,
}

@export var accel: float = 200.0 

var state: State = State.RANDOM
var current_target_x: float
var knockback: Vector2
var knockback_timer: float = 0.0

func change_state(new_state: State) -> void:
	state = new_state
	if state == State.RANDOM:
		current_target_x = randf_range(Global.enemy_manager.world_limit_min, Global.enemy_manager.world_limit_max)

func _ready() -> void:
	change_state(State.RANDOM)

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

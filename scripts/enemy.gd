extends CharacterBody2D


@export var accel: float = 200.0 

var knockback: Vector2
var knockback_timer: float = 0.0

func apply_knockback(time: float, force: Vector2) -> void:
	knockback = force
	velocity.y = force.y
	knockback_timer = time


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = knockback.x
		if knockback_timer <= 0.0:
			knockback.x = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, delta * accel)
	move_and_slide()

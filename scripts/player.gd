extends CharacterBody2D

@export var player_datas: Array[PlayerData]

@onready var camera: Camera2D = %Camera2D
@onready var dash_ray: RayCast2D = $DashRay

var is_dashing: bool = false
var dash_distance: float = 0.0
var current_data: int = 0

const DASH_FORCE: float = 60.0
const DASH_LIMIT: float = 150.0
const SHAKE_FORCE: float = 2

func _ready() -> void:
	Global.camera_manager.camera = camera


func get_current_data() -> PlayerData:
	return player_datas[current_data]

func _physics_process(delta: float) -> void:
	var data := get_current_data()

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_down") and not is_on_floor():
		var can_dash: bool = not dash_ray.is_colliding()
		if can_dash:
			is_dashing = true
			dash_distance = position.y
			if velocity.y < 0.0:
				velocity.y = DASH_FORCE * data.mass
			else:
				velocity.y += DASH_FORCE * data.mass

	if is_on_floor() and is_dashing:
		is_dashing = false
		dash_distance = position.y - dash_distance
		var dash_power: float = 1.0 + min(1.0, dash_distance / (dash_ray.target_position.y * 2.0))
		dash_distance = 0.0
		Global.camera_manager.shake(SHAKE_FORCE * data.mass * dash_power, 5)

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = -data.jump_force

	var direction := Input.get_axis("move_left", "move_right") if not is_dashing else 0.0
	if direction:
		velocity.x = direction * data.move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, data.move_speed)

	move_and_slide()

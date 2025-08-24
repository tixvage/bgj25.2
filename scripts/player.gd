extends CharacterBody2D

@export var player_datas: Array[PlayerData]

@onready var camera: Camera2D = %Camera2D

var is_dashing: bool = false
var current_data: int = 0

const DASH_FORCE: float = 60.0


func _ready() -> void:
	print(camera)
	Global.camera_manager.camera = camera


func get_current_data() -> PlayerData:
	return player_datas[current_data]

func _physics_process(delta: float) -> void:
	var data := get_current_data()

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_down") and not is_on_floor():
		is_dashing = true
		if velocity.y < 0:
			velocity.y = DASH_FORCE * data.mass
		else:
			velocity.y += DASH_FORCE * data.mass

	if is_on_floor() and is_dashing:
		Global.camera_manager.shake(20, 5)
		is_dashing = false

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = -data.jump_force

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * data.move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, data.move_speed)

	move_and_slide()

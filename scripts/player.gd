extends CharacterBody2D

@export var player_datas: Array[PlayerData]

@export var ground_accel := 2500.0
@export var air_accel := 1800.0
@export var coyote_time := 0.15

const DASH_FORCE: float = 90.0
const DASH_LIMIT: float = 150.0
const SHAKE_FORCE: float = 1.0

@onready var camera: Camera2D = %Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var dash_ray: RayCast2D = $DashRay
@onready var ghost_spawn_timer: Timer = $GhostSpawnTimer

@onready var player_ghost_scene := preload("res://scenes/player_ghost.tscn")

var current_data: int = 0
var is_dashing: bool = false
var dash_distance: float = 0.0
var coyote_timer: float = 0.0

func _ready() -> void:
	Global.camera_manager.camera = camera


func get_current_data() -> PlayerData:
	return player_datas[current_data]

func _physics_process(delta: float) -> void:
	var data := get_current_data()

	var on_floor := is_on_floor()
	var can_jump: bool = coyote_timer > 0.0
	if on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	var can_dash: bool = not on_floor and not dash_ray.is_colliding()
	var accel = ground_accel if on_floor else air_accel


	if not on_floor:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_down") and can_dash:
		is_dashing = true
		dash_distance = position.y
		ghost_spawn_timer.one_shot = false
		ghost_spawn_timer.start()
		if velocity.y < 0.0:
			velocity.y = DASH_FORCE * data.mass
		else:
			velocity.y += DASH_FORCE * data.mass

	if on_floor and is_dashing:
		is_dashing = false
		dash_distance = position.y - dash_distance
		ghost_spawn_timer.one_shot = true
		var dash_power: float = 1.0 + min(1.0, dash_distance / (dash_ray.target_position.y * 2.0))
		dash_distance = 0.0
		Global.camera_manager.shake(SHAKE_FORCE * data.mass * dash_power, 5)

	if Input.is_action_just_pressed("move_up") and can_jump:
		velocity.y = -data.jump_force

	var direction := Input.get_axis("move_left", "move_right") if not is_dashing else 0.0
	velocity.x = move_toward(velocity.x, direction * data.move_speed, accel * delta)

	move_and_slide()


func _on_ghost_spawn_timer_timeout() -> void:
	var ghost_instance = player_ghost_scene.instantiate()
	ghost_instance.apply_sprite(sprite, position)
	get_parent().add_child(ghost_instance)

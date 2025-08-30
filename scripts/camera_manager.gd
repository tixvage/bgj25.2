class_name CameraManager extends Node

var camera: Camera2D

var shake_strength: float = 0.0
var shake_speed: float = 0.0

var actual_cam_pos: Vector2


func _ready() -> void:
	Global.camera_manager = self

func shake(strength: float, speed: float) -> void:
	shake_strength = strength
	shake_speed = speed


func _physics_process(delta: float) -> void:
	var player_with_x = Vector2(Global.player_manager.player.global_position.x, camera.global_position.y)
	player_with_x.x = clampf(player_with_x.x, -115.0, 840.0)
	actual_cam_pos = actual_cam_pos.lerp(player_with_x, delta * 3)
	var cam_subpixel_offset: Vector2 = actual_cam_pos.round() - actual_cam_pos
	var cam_diff_offset: Vector2 = camera.offset.round() - camera.offset
	Global.world_viewport.material.set_shader_parameter("cam_offset", cam_subpixel_offset + cam_diff_offset)
	camera.global_position = actual_cam_pos.round()
	camera.offset = camera.offset.round()


func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shake_speed * delta)
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength),randf_range(-shake_strength, shake_strength))

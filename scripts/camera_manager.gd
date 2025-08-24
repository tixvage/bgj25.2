class_name CameraManager extends Node

var camera: Camera2D

var shake_strength: float = 0.0
var shake_speed: float = 0.0

func _ready() -> void:
	Global.camera_manager = self

func shake(strength: float, speed: float) -> void:
	shake_strength = strength
	shake_speed = speed


func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shake_speed * delta)
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength),randf_range(-shake_strength, shake_strength))

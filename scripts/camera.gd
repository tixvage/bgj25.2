extends Camera2D

var actual_cam_pos: Vector2


func _ready() -> void:
	pass # Replace with function body.

var a: float = 0.0

func _physics_process(delta: float) -> void:
	actual_cam_pos = actual_cam_pos.lerp($"../Player".global_position, delta * 3)
	var cam_subpixel_offset: Vector2 = actual_cam_pos.round() - actual_cam_pos
	var cam_diff_offset: Vector2 = offset.round() - offset
	Global.world_viewport.material.set_shader_parameter("cam_offset", cam_subpixel_offset + cam_diff_offset)
	global_position = actual_cam_pos.round()
	offset = offset.round()

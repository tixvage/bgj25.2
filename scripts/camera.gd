extends Camera2D

func _ready() -> void:
	Global.camera_manager.camera = self
	Global.camera_manager.actual_cam_pos = global_position

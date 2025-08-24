class_name WindowManager extends Node

func _ready() -> void:
	Global.window_manager = self

func _input(event: InputEvent) -> void:
	return
	#disable for now
	if event.is_action_pressed("fullscreen"):
		var window: bool = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if window else DisplayServer.WINDOW_MODE_WINDOWED)
		var borderless: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, not borderless)

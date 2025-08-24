class_name SceneManager extends Node

@onready var world_2d: Node2D = %World2D
@onready var gui: Control = %GUI

var current_world_2d_scene: Node2D = null
var current_gui_scene: Node2D = null

func _ready() -> void:
	Global.scene_manager = self
	change_world_2d_scene("res://scenes/demo_world.tscn")


func change_gui_scene(scene_name: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(scene_name).instantiate()
	gui.add_child(new)
	current_gui_scene = new

func change_world_2d_scene(scene_name: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_world_2d_scene != null:
		if delete:
			current_world_2d_scene.queue_free()
		elif keep_running:
			current_world_2d_scene.visible = false
		else:
			world_2d.remove_child(current_world_2d_scene)
	var new = load(scene_name).instantiate()
	world_2d.add_child(new)
	current_world_2d_scene = new

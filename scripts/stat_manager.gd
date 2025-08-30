class_name StatManager extends Node


@onready var xp_layer: CanvasLayer = $"../GUI/XpLayer"

var total_kill: int = 0
var total_eat: int = 0

func _ready() -> void:
	Global.stat_manager = self


func update_xp(xp: float, required_xp: float) -> void:
	xp_layer.update_xp(xp, required_xp)
	pass


func new_eat() -> void:
	total_eat += 1
	if total_eat == 1:
		Global.story_manager.first_eat()


func new_kill() -> void:
	total_kill += 1
	if total_kill == 1:
		Global.story_manager.first_kill()

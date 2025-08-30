class_name StatManager extends Node


@onready var xp_layer: CanvasLayer = $"../GUI/XpLayer"

var total_kill: int = 0
var total_eat: int = 0
var dashed: bool = false
var first_level_up: bool = false
var level_2_first_kill: bool = false
var level_2_wait_for_killing_all: bool = false

func _ready() -> void:
	Global.stat_manager = self


func update_xp(xp: float, required_xp: float) -> void:
	xp_layer.update_xp(xp, required_xp)


func level_up() -> void:
	if not first_level_up:
		Global.story_manager.level_up()
		Global.enemy_manager.spawner.reset(10)
		first_level_up = true
		level_2_wait_for_killing_all = true


func dash() -> void:
	if not dashed:
		dashed = true
		if Global.story_manager.dash_introduced:
			pass
		else:
			Global.story_manager.early_dash()


func new_eat() -> void:
	total_eat += 1
	if total_eat == 1:
		Global.story_manager.first_eat()


func new_kill() -> void:
	total_kill += 1
	if total_kill == 1:
		Global.story_manager.first_kill()
	elif total_kill == 3 and not dashed:
		Global.story_manager.introduce_dash()
	elif total_kill == 5:
		Global.story_manager.info_about_cookies()

	if first_level_up and not level_2_first_kill:
		level_2_first_kill = true
		Global.story_manager.level_2_skills()

class_name StoryManager extends Node

const first_kill_text: Array[String] = [
	"""After approaching the dead cookies, you can eat them by pressing the right mouse button.""",
]

const first_eat_text: Array[String] = [
	"""There is a jar at the bottom right of the screen. The more cookies you have collected, the closer you are to the next level.""",
	"""your mom.""",
]

var locked: bool = false

func _ready() -> void:
	Global.story_manager = self


func lock_everything(clear_enemies: bool = false) -> void:
	locked = true
	if clear_enemies:
		Global.enemy_manager.kill_all()
	Global.enemy_manager.lock = true
	Global.player_manager.player.unlock()


func unlock_everything() -> void:
	locked = false
	Global.enemy_manager.lock = false
	Global.player_manager.player.lock()


func run_dialogue(texts: Array[String], clear_enemies: bool = false) -> void:
	lock_everything(clear_enemies)
	for text in texts:
		await Global.dialogue_manager.enable_dialogue(text)
	unlock_everything()


func first_kill() -> void: run_dialogue(first_kill_text, true)
func first_eat() -> void: run_dialogue(first_eat_text)

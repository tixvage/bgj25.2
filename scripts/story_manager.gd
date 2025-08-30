class_name StoryManager extends Node


const spawn_text: Array[String] = [
"""Soooo, welcome to your dreams!
You can speed up and skip these texts with 'X'""",
"""Eating cookies huh?""",
"""Anyways, you can move around with 'A' and 'D' or 'Left' and 'Right'.""",
"""You can punch the cookies with the 'Left Mouse Button'.""",
"""Also you can jump with 'W' or 'Up'.""",
"""For now...""",
]

const first_kill_text: Array[String] = [
"""After approaching the dead cookies, you can eat them by pressing the right mouse button.""",
]

const first_eat_text: Array[String] = [
"""There is a jar at the bottom right of the screen. The more cookies you have collected, the closer you are to the next level.""",
"""What will happen when you move on to the next level?""",
"""Never mind, you'll see.""",
]

const early_dash_text: Array[String] = [
"""Hmmm.""",
"""You seem to be in a bit of a hurry...""",
"""I was going to teach you how to 'dash' anyway.""",
"""Anyway, you need to press 'S' or 'Down' key when you have enough height for the dash""",
]

const introduce_dash_text: Array[String] = [
"""Seems like you're having a hard time hitting one cookie with each punch.""",
"""After jumping, try pressing 'S' or 'Down' and dash"""
]

const info_about_cookies_text: Array[String] = [
"""The cookies hitting you have no effect at the moment.""",
"""It only gives headache to the person playing it on the computer with camera shake.""",
]

const level_up_text: Array[String] = [
"""You gained weight by eating enough cookies!""",
"""Or you leveled up, whichever you prefer...""",
"""There are 4 levels, I will guide you as your skills change.""",
]

const level_2_skills_text: Array[String] = [
"""If you noticed, you are running slower.""",
"""But your punches and dash damage are stronger.""",
]

const cookie_damage_text: Array[String] = [
"""I have bad news.""",
"""Now, when cookies hit you, it means they are stealing cookies from you.""",
"""If they steal enough cookies from you will return to the previous level.""",
"""By the way, the cookies might be acting a little silly.""",
"""After all, they are cookies, aren't they? It's not fair to blame the person who made the game...""",
]


var locked: bool = false
var dash_introduced: bool = false
var can_steal: bool = false

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


func spawn() -> void: run_dialogue(spawn_text)
func first_kill() -> void: run_dialogue(first_kill_text)
func first_eat() -> void: run_dialogue(first_eat_text)
func early_dash() -> void: run_dialogue(early_dash_text)
func introduce_dash() -> void: dash_introduced = true; run_dialogue(introduce_dash_text)
func info_about_cookies() -> void: run_dialogue(info_about_cookies_text)
func level_up() -> void: run_dialogue(level_up_text)
func level_2_skills() -> void: run_dialogue(level_2_skills_text)
func cookie_damage() -> void: can_steal = true; run_dialogue(cookie_damage_text)

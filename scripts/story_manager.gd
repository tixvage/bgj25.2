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
"""I was going to teach you how to 'dive' anyway.""",
"""Anyway, you need to press 'S' or 'Down' key when you have enough height for the dive""",
]

const introduce_dash_text: Array[String] = [
"""Seems like you're having a hard time hitting one cookie with each punch.""",
"""After jumping, try pressing 'S' or 'Down' for diving"""
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
"""If they steal enough cookies, you will return to the previous level.""",
"""By the way, the cookies might be acting a little silly.""",
"""After all, they are cookies, aren't they? It's not fair to blame the person who made the game...""",
]

const level_down_text: Array[String] = [
"""Hello again, skinny man.""",
"""Keep in mind that it makes more sense to start eating after killing every cookie you see.""",
"""I'll leave you alone for a bit. See you after you eat some cookies.""",
"""..."""
]

const level_3_text: Array[String] = [
"""Wooow, you looking strong!""",
"""I guess you still want to eat some more cookies.""",
]

const level_4_text: Array[String] = [
"""Uhhh, things got a little out of hand...""",
"""I think you ate too many cookies.""",
"""You're no longer able to jump...""",
"""You can roll by pressing 'S' or 'Down' instead.""",
"""If you still want to continue..."""
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
func level_down() -> void: run_dialogue(level_down_text)
func level_3() -> void: run_dialogue(level_3_text)
func level_4() -> void: run_dialogue(level_4_text)

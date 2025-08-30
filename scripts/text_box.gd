class_name DialogueManager extends MarginContainer

@onready var texture_node: TextureRect = $MarginContainer/HBoxContainer/Texture
@onready var text_node: RichTextLabel = $MarginContainer/HBoxContainer/Text

var texture_minimum_size: float

const DEFAULT_SPEED: float = 0.1
const SKIP_SPEED: float = DEFAULT_SPEED * 6

var speed_ratio: float = 1.0
var speeding_up: bool = false
var text_running: bool = false

signal current_text_finished

const demo_string = """Demo message (Press 'X' to speed up then close):
[color=#dddddd]Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Excepteur sint occaecat cupidatat non proident.[/color]
"""


func _speed_ratio() -> float:
	return float(len(demo_string)) / float(len(text_node.text))


func _ready() -> void:
	Global.dialogue_manager = self
	texture_minimum_size = texture_node.custom_minimum_size.x
	disable_dialog()


func enable_dialogue(text: String, texture: Texture2D = null) -> Signal:
	speeding_up = false
	visible = true
	text_running = true
	text_node.visible_ratio = 0.0

	if texture == null:
		texture_node.custom_minimum_size = Vector2.ZERO
		texture_node.visible = false
	else:
		texture_node.custom_minimum_size = Vector2(texture_minimum_size, texture_minimum_size)
		texture_node.visible = true
	texture_node.texture = texture

	text_node.text = text
	
	return current_text_finished


func disable_dialog() -> void:
	speeding_up = false
	texture_node.texture = null
	text_node.text = ""
	visible = false
	current_text_finished.emit()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("text_read"):
		if text_running:
			speeding_up = true
		elif visible:
			disable_dialog()
	var speed = SKIP_SPEED if speeding_up else DEFAULT_SPEED
	if text_running:
		text_node.visible_ratio += delta * speed * _speed_ratio()
		if text_node.visible_ratio >= 1.0:
			text_running = false

extends CanvasLayer


@onready var container: VBoxContainer = $TextureRect/MarginContainer/VBoxContainer
@export var cookie_scene: Resource

const MAX_COOKIE_COUNT: float = 6.0


func update_xp(xp: float, required_xp: float) -> void:
	var child_count := container.get_child_count()
	var cookie_count: int = roundi((xp / required_xp) * MAX_COOKIE_COUNT)

	var diff = abs(child_count - cookie_count)

	if child_count > cookie_count:
		for i in diff:
			container.remove_child(container.get_child(0))
	else:
		for i in diff:
			var cookie_instance = cookie_scene.instantiate()
			container.add_child(cookie_instance)

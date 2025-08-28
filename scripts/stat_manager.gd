class_name StatManager extends Node


@onready var xp_layer: CanvasLayer = $"../GUI/XpLayer"


func _ready() -> void:
	Global.stat_manager = self


func update_xp(xp: float, required_xp: float) -> void:
	xp_layer.update_xp(xp, required_xp)
	pass


func _process(delta: float) -> void:
	pass

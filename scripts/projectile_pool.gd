extends Node2D


func _ready() -> void:
	Global.projectile_manager.pool = self


func _process(delta: float) -> void:
	pass

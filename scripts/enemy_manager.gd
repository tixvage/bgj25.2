class_name EnemyManager extends Node

@export var world_limit_min: float
@export var world_limit_max: float

var spawner: EnemySpawner

var lock: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.enemy_manager = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

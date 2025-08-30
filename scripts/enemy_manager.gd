class_name EnemyManager extends Node

@export var world_limit_min: float
@export var world_limit_max: float

var spawner: EnemySpawner

var lock: bool = false


func _ready() -> void:
	Global.enemy_manager = self


func kill_all() -> void:
	var enemies := spawner.pool.get_children()
	for enemy in enemies:
		enemy.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

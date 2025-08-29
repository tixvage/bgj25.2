extends Node2D
class_name EnemySpawner

enum Type {
	LOTUS = 0,
	BANDIM,
}

@export var pool: Node2D
@export var enemies: Array[Resource]
@export var spawn_points: Node2D
var enemy_dict: Dictionary[Type, Resource] = {}

var random_spawn_time: float = 2.0
var random_spawn_timer: float = 0.0


func get_random_spawn_position_type(type: Type) -> Vector2:
	var children = spawn_points.get_node(Type.keys()[type]).get_children()
	return children[Global.rng.randi_range(0, len(children) - 1)].global_position


func spawn_enemy_type(type: Type) -> void:
	var enemy_instance = enemy_dict[type].instantiate()
	pool.add_child(enemy_instance)
	enemy_instance.global_position = get_random_spawn_position_type(type)

func _ready() -> void:
	random_spawn_timer = random_spawn_time
	Global.enemy_manager.spawner = self
	for enemy in enemies:
		var temp = enemy.instantiate()
		enemy_dict[temp.data.type] = enemy
		temp.queue_free()

func _process(delta: float) -> void:
	if random_spawn_timer > 0.0:
		random_spawn_timer -= delta
	else:
		random_spawn_timer = random_spawn_time
		spawn_enemy_type(EnemySpawner.Type.BANDIM)#Global.rng.randi() % 2)

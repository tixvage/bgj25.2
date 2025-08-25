extends Node2D
class_name EnemySpawner

enum Type {
	NONE = 0,
}

@export var pool: Node2D
@export var enemies: Array[EnemyData]
@export var spawn_points: Node2D
var enemy_dict: Dictionary[Type, EnemyData] = {}

var random_spawn_time: float = 2.0
var random_spawn_timer: float = 0.0


func get_random_spawn_position_type(type: Type) -> Vector2:
	print(Type.keys()[type])
	var children = spawn_points.get_node(Type.keys()[type]).get_children()
	return children[Global.rng.randi_range(0, len(children) - 1)].global_position


func spawn_enemy_type(type: Type) -> void:
	var enemy_instance = enemy_dict[type].scene.instantiate()
	pool.add_child(enemy_instance)
	enemy_instance.global_position = get_random_spawn_position_type(type)

func _ready() -> void:
	random_spawn_timer = random_spawn_time
	Global.enemy_manager.spawner = self
	for enemy in enemies:
		enemy_dict[enemy.type] = enemy


func _process(delta: float) -> void:
	if random_spawn_timer > 0.0:
		random_spawn_timer -= delta
	else:
		random_spawn_timer = random_spawn_time
		spawn_enemy_type(Type.NONE)

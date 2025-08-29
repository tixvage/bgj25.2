class_name ProjectileManager extends Node

var pool: Node2D

var projectile_dict: Dictionary = {}
@export var projectiles: Array[Projectile]

func _ready() -> void:
	Global.projectile_manager = self
	for p: Projectile in projectiles:
		projectile_dict[p.type] = p


func spawn(type: Projectile.Type, spawn_position: Vector2, direction: Vector2, data: EnemyData) -> void:
	var instance = projectile_dict[type].scene.instantiate()
	instance.init(spawn_position, direction, data)
	pool.add_child(instance)

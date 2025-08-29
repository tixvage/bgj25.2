extends Area2D

const SPEED: float = 500.0

var direction: Vector2
var data: EnemyData


func init(spawn_position: Vector2, spawn_direction: Vector2, spawn_data: EnemyData) -> void:
	global_position = spawn_position
	direction = spawn_direction
	data = spawn_data


func _process(delta: float) -> void:
	$AnimatedSprite2D.play("default")

	global_position += direction * SPEED * delta


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Player"): return

	area.get_parent().damage(data.xp_steal, true)

	queue_free()

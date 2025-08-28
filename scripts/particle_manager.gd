class_name ParticleManager extends Node

var spawner: ParticleSpawner


func _ready() -> void:
	Global.particle_manager = self


func spawn(type: Particle.Type, spawn_position: Vector2, child: Node2D = null) -> void:
	var particle_instance = spawner.particle_dict[type].scene.instantiate()
	particle_instance.emitting = true
	var pool = child if child else spawner.pool
	pool.add_child(particle_instance)
	particle_instance.global_position = spawn_position


func _process(delta: float) -> void:
	pass

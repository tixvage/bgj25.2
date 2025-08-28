extends Node2D
class_name ParticleSpawner

@export var pool: Node2D

var particle_dict: Dictionary = {}
@export var particles: Array[Particle]


func _ready() -> void:
	Global.particle_manager.spawner = self
	for particle: Particle in particles:
		particle_dict[particle.type] = particle


func _process(delta: float) -> void:
	pass

extends Resource
class_name Particle

enum Type {
	HIT = 0,
	DASH_END,
}

@export var type: Type
@export var scene: Resource

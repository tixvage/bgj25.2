extends Sprite2D


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func apply_sprite(sprite: Sprite2D, spawn_position: Vector2) -> void:
	var a = sprite.duplicate()
	position = spawn_position
	texture = a.texture
	vframes = a.vframes
	hframes = a.hframes
	frame = a.frame
	flip_h = a.flip_h
	flip_v = a.flip_v
	z_index = 1

func _process(delta: float) -> void:
	pass

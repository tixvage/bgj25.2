extends Resource
class_name SoundEffect

enum Type {
	NONE = 0,
	DASH_START,
	DASH_END,
	HIT,
	HIT_ENEMY,
	MISS,
	SHOOT_START,
	SHOOT_HIT,
	LEVEL_UP,
	LEVEL_DOWN,
	JUMP,
	TALKBOX,
	WALK,
	BREAK,
	EAT,
}

@export_range(0, 10) var limit: int = 5
@export var type: Type
@export var sound_effect: AudioStreamMP3
@export_range(-40, 20) var volume: int = 0
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0

var audio_count: int = 0

func add_audio(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


func can_play_more() -> bool:
	return audio_count < limit


func _on_audio_finished() -> void:
	add_audio(-1)

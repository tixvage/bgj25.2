class_name AudioManager extends Node

var sound_effect_dict: Dictionary = {}
@export var sound_effects: Array[SoundEffect]

func _ready() -> void:
	Global.audio_manager = self
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect


func create_2d_audio_at_location(position: Vector2, type: SoundEffect.Type) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.can_play_more():
			sound_effect.add_audio(1)
			var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)
			new_2D_audio.position = position
			new_2D_audio.stream = sound_effect.sound_effect
			new_2D_audio.volume_db = sound_effect.volume
			new_2D_audio.pitch_scale = sound_effect.pitch_scale
			new_2D_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_2D_audio.finished.connect(sound_effect._on_audio_finished)
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)


func create_audio(type: SoundEffect.Type) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.volume
			new_audio.pitch_scale = sound_effect.pitch_scale
			new_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

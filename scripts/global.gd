extends Node

var scene_manager: SceneManager
var audio_manager: AudioManager 
var window_manager: WindowManager
var camera_manager: CameraManager
var enemy_manager: EnemyManager
var player_manager: PlayerManager
var particle_manager: ParticleManager
var stat_manager: StatManager
var world_viewport: SubViewportContainer
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
const EPS: float = 3.0
func _ready() -> void:
	pass

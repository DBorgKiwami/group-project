extends Node

@export var audio_player: AudioStreamPlayer3D
@export var sprite: AnimatedSprite3D
@export_range(0.1, 1.0, 0.01) var step_interval := 0.4

@onready var player: Player3D = get_parent() as Player3D

var _time_until_next_step := 0.0
var _was_walking := false


func _process(delta: float) -> void:
	if player == null or audio_player == null or sprite == null:
		return

	var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	var is_walking := (
		horizontal_speed > 0.1
		and player.is_on_floor()
		and not player.grappling
		and String(sprite.animation).to_lower().ends_with("walk")
	)

	if not is_walking:
		_was_walking = false
		_time_until_next_step = 0.0
		return

	if not _was_walking:
		_was_walking = true
		_play_step()
		_time_until_next_step = step_interval
		return

	_time_until_next_step -= delta
	if _time_until_next_step <= 0.0:
		_play_step()
		_time_until_next_step += step_interval


func _play_step() -> void:
	audio_player.pitch_scale = 1.0
	audio_player.play()

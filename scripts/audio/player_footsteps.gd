extends Node

@export var audio_player: AudioStreamPlayer3D
@export var water_audio_player: AudioStreamPlayer3D
@export var lotus_audio_player: AudioStreamPlayer3D
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

	# The reference character uses a four-frame animation at 5 FPS, with a
	# foot plant every two frames: one evenly spaced step every 0.4 seconds.
	# Keeping that cadence here avoids the 0.4/0.2 pattern created by this
	# version's three-frame walk cycle, which sounded like galloping hooves.
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
	var active_audio_player := _get_surface_audio_player()
	if active_audio_player == null:
		return
	active_audio_player.pitch_scale = 1.0
	active_audio_player.play()


func _get_surface_audio_player() -> AudioStreamPlayer3D:
	# Lotus leaves overlap the pond, so they must take priority over water.
	if lotus_audio_player != null and _is_inside_surface_group(&"footstep_lotus"):
		return lotus_audio_player
	if water_audio_player != null and _is_inside_surface_group(&"footstep_water"):
		return water_audio_player
	return audio_player


func _is_inside_surface_group(group_name: StringName) -> bool:
	for surface in get_tree().get_nodes_in_group(group_name):
		if surface is Node3D:
			var local_position := (surface as Node3D).to_local(player.global_position)
			if Vector2(local_position.x, local_position.z).length_squared() <= 1.0:
				return true
	return false

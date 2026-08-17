extends Node

@export var combat_music: AudioStreamPlayer
@export var victory_sfx: AudioStreamPlayer
@export var birds_sfx: AudioStreamPlayer
@export var breeze_sfx: AudioStreamPlayer
@export var combat_start: AudioStream
@export var combat_middle: AudioStream
@export var combat_final: AudioStream
@export_range(1.0, 5.0, 0.1) var ambience_delay_min := 2.0
@export_range(1.0, 5.0, 0.1) var ambience_delay_max := 3.0

var _tracks: Array[AudioStream] = []
var _track_index := 0
var _remaining_enemies := 0
var _victory_started := false
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_set_loop(combat_start, false)
	_set_loop(combat_middle, false)
	_set_loop(combat_final, true)
	_tracks = [combat_start, combat_middle, combat_final]
	combat_music.finished.connect(_on_music_finished)
	call_deferred("_start_combat_audio")
	_play_ambient(birds_sfx, -18.0, -14.0, 0.97, 1.03)
	_play_ambient(breeze_sfx, -20.0, -16.0, 0.98, 1.02)

func _start_combat_audio() -> void:
	var level := get_parent()
	for enemy in get_tree().get_nodes_in_group("combat_enemy"):
		if level.is_ancestor_of(enemy) and enemy.has_signal("defeated"):
			_remaining_enemies += 1
			enemy.connect("defeated", _on_enemy_defeated)
	_play_track(0)

func _set_loop(track: AudioStream, enabled: bool) -> void:
	if track is AudioStreamOggVorbis:
		(track as AudioStreamOggVorbis).loop = enabled

func _play_track(index: int) -> void:
	if index < 0 or index >= _tracks.size() or _tracks[index] == null:
		return
	_track_index = index
	combat_music.stream = _tracks[index]
	combat_music.play()

func _on_music_finished() -> void:
	if _victory_started:
		return
	if _track_index < _tracks.size() - 1:
		_play_track(_track_index + 1)
	else:
		combat_music.play()

func _on_enemy_defeated() -> void:
	if _victory_started:
		return
	_remaining_enemies = maxi(0, _remaining_enemies - 1)
	if _remaining_enemies == 0:
		_victory_started = true
		combat_music.stop()
		victory_sfx.play()

func _play_ambient(
	player: AudioStreamPlayer,
	min_volume_db: float,
	max_volume_db: float,
	min_pitch: float,
	max_pitch: float
) -> void:
	await get_tree().create_timer(_rng.randf_range(0.8, 1.8)).timeout
	while is_inside_tree():
		player.volume_db = _rng.randf_range(min_volume_db, max_volume_db)
		player.pitch_scale = _rng.randf_range(min_pitch, max_pitch)
		player.play()
		await player.finished
		if not is_inside_tree():
			return
		await get_tree().create_timer(
			_rng.randf_range(ambience_delay_min, ambience_delay_max)
		).timeout

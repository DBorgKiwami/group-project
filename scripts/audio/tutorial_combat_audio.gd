extends Node

@export var combat_player: AudioStreamPlayer
@export var combat_start: AudioStream
@export var combat_middle: AudioStream
@export var combat_final: AudioStream
@export var enemy_cry_player: AudioStreamPlayer
@export var victory_player: AudioStreamPlayer
@export var birds_player: AudioStreamPlayer
@export var breeze_player: AudioStreamPlayer

var _combat_tracks: Array[AudioStream] = []
var _combat_track_index := 0
var _enemy_count := 0
var _defeated_count := 0
var _victory_started := false
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	_connect_enemies(get_parent())
	_start_combat_sequence()
	_play_birds()
	_play_breezes()


func _connect_enemies(node: Node) -> void:
	for child in node.get_children():
		if child.has_signal("defeated"):
			child.connect("defeated", _on_enemy_defeated)
			_enemy_count += 1
		_connect_enemies(child)


func _start_combat_sequence() -> void:
	if (
		combat_player == null
		or combat_start == null
		or combat_middle == null
		or combat_final == null
	):
		push_error("Tutorial combat audio requires start, middle, and final tracks.")
		return

	_combat_tracks = [
		_copy_with_loop(combat_start, false),
		_copy_with_loop(combat_middle, false),
		_copy_with_loop(combat_final, true),
	]
	combat_player.finished.connect(_on_combat_track_finished)
	_play_combat_track(0)


func _copy_with_loop(track: AudioStream, enabled: bool) -> AudioStream:
	var local_track := track.duplicate()
	if local_track is AudioStreamOggVorbis:
		local_track.loop = enabled
	return local_track


func _play_combat_track(index: int) -> void:
	_combat_track_index = index
	combat_player.stream = _combat_tracks[index]
	combat_player.play()


func _on_combat_track_finished() -> void:
	if _victory_started:
		return

	if _combat_track_index < _combat_tracks.size() - 1:
		_play_combat_track(_combat_track_index + 1)
	else:
		# The final OGG loops internally; this is a safety fallback.
		combat_player.play()


func _on_enemy_defeated() -> void:
	if _victory_started:
		return

	_defeated_count += 1
	if enemy_cry_player:
		enemy_cry_player.pitch_scale = _random.randf_range(0.97, 1.03)
		enemy_cry_player.play()

	if _enemy_count > 0 and _defeated_count >= _enemy_count:
		_victory_started = true
		if combat_player:
			combat_player.stop()
		if victory_player:
			victory_player.play()


func _play_birds() -> void:
	if birds_player == null or birds_player.stream == null:
		return

	while is_inside_tree():
		birds_player.volume_db = _random.randf_range(-20.0, -17.0)
		birds_player.pitch_scale = _random.randf_range(0.98, 1.02)
		birds_player.play()
		await birds_player.finished
		if not is_inside_tree():
			return
		await get_tree().create_timer(_random.randf_range(2.0, 3.0)).timeout


func _play_breezes() -> void:
	if breeze_player == null or breeze_player.stream == null:
		return

	while is_inside_tree():
		breeze_player.volume_db = _random.randf_range(-22.0, -19.0)
		breeze_player.pitch_scale = _random.randf_range(0.99, 1.01)
		breeze_player.play()
		await breeze_player.finished
		if not is_inside_tree():
			return
		await get_tree().create_timer(_random.randf_range(2.0, 3.0)).timeout

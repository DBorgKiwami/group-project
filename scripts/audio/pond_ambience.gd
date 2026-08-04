extends Node

@export var damp_and_watery: AudioStreamPlayer
@export var pond_sounds: AudioStreamPlayer
@export var breeze: AudioStreamPlayer
@export var insect_chirping: AudioStreamPlayer
@export var insects_chirping: AudioStreamPlayer
@export_range(-6.0, 8.0, 0.5) var ambience_gain_db := 6.0

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	_apply_ambience_gain()
	_start_continuous_loop(damp_and_watery)
	_start_continuous_loop(pond_sounds)
	_vary_pond_layer()
	_play_breezes()
	_play_single_insect()
	_play_insect_group()


func _apply_ambience_gain() -> void:
	for player in [
		damp_and_watery,
		pond_sounds,
		breeze,
		insect_chirping,
		insects_chirping,
	]:
		if player != null:
			player.volume_db += ambience_gain_db


func _start_continuous_loop(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	# Duplicate the imported stream so enabling looping here does not change
	# how the same audio asset behaves if another scene reuses it.
	var looping_stream := player.stream.duplicate()
	if looping_stream is AudioStreamOggVorbis:
		looping_stream.loop = true
	player.stream = looping_stream
	player.play()


func _vary_pond_layer() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(3.5, 6.5)).timeout
		if not is_inside_tree() or pond_sounds == null:
			return

		var tween := create_tween().set_parallel(true)
		var transition_time := _random.randf_range(2.0, 3.5)
		tween.tween_property(
			pond_sounds,
			"volume_db",
			_random.randf_range(-13.0, -9.0) + ambience_gain_db,
			transition_time
		).set_trans(Tween.TRANS_SINE)
		tween.tween_property(
			pond_sounds,
			"pitch_scale",
			_random.randf_range(0.97, 1.03),
			transition_time
		).set_trans(Tween.TRANS_SINE)


func _play_breezes() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(5.0, 9.0)).timeout
		if not is_inside_tree():
			return
		_play_with_variation(breeze, -17.0, -12.5, 0.98, 1.02)
		if breeze != null and breeze.playing:
			await breeze.finished


func _play_single_insect() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(6.0, 7.0)).timeout
		if not is_inside_tree():
			return
		_play_with_variation(insect_chirping, -15.0, -10.5, 0.94, 1.06)
		if insect_chirping != null and insect_chirping.playing:
			await insect_chirping.finished


func _play_insect_group() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(1.8, 2.2)).timeout
		if not is_inside_tree():
			return
		_play_with_variation(insects_chirping, -18.0, -13.0, 0.95, 1.05)
		if insects_chirping != null and insects_chirping.playing:
			await insects_chirping.finished


func _play_with_variation(
	player: AudioStreamPlayer,
	minimum_volume_db: float,
	maximum_volume_db: float,
	minimum_pitch: float,
	maximum_pitch: float
) -> void:
	if player == null or player.stream == null:
		return

	player.volume_db = (
		_random.randf_range(minimum_volume_db, maximum_volume_db)
		+ ambience_gain_db
	)
	player.pitch_scale = _random.randf_range(minimum_pitch, maximum_pitch)
	player.play()

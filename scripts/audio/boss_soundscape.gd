extends Node

@export var background_music: AudioStreamPlayer
@export var damp_and_watery: AudioStreamPlayer
@export var pond_sounds: AudioStreamPlayer
@export var breeze: AudioStreamPlayer
@export var insect_chirping: AudioStreamPlayer
@export var insects_chirping: AudioStreamPlayer
@export var left_waterfall: AudioStreamPlayer3D
@export var right_waterfall: AudioStreamPlayer3D
@export var boss: Node
@export var enemy_defeat_sfx: AudioStreamPlayer
@export var victory_sfx: AudioStreamPlayer

var _random := RandomNumberGenerator.new()
var _pond_base_volume_db := 0.0
var _victory_started := false
var _music_base_volume_db := 0.0


func _ready() -> void:
	_random.randomize()
	_pond_base_volume_db = pond_sounds.volume_db
	_music_base_volume_db = background_music.volume_db

	_start_continuous_loop(background_music)
	_start_continuous_loop(damp_and_watery)
	_start_continuous_loop(pond_sounds)
	_start_waterfall_loop(left_waterfall, 0.0)
	_start_waterfall_loop(right_waterfall, 0.18)

	_vary_pond_layer()
	_play_breezes()
	_play_single_insect()
	_play_insect_group()
	call_deferred("_connect_boss_audio")


func _start_continuous_loop(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	player.stream = _duplicate_looping_ogg(player.stream, 0.0)
	player.play()


func _start_waterfall_loop(player: AudioStreamPlayer3D, start_offset: float) -> void:
	if player == null or player.stream == null:
		return

	# Restart each OGG loop at 0.5 s, skipping its leading edge so the waterfall
	# remains continuous. AudioStreamPlayer3D supplies smooth distance falloff.
	player.stream = _duplicate_looping_ogg(player.stream, 0.5)
	player.play(start_offset)


func _duplicate_looping_ogg(stream: AudioStream, loop_offset: float) -> AudioStream:
	var looping_stream := stream.duplicate()
	if looping_stream is AudioStreamOggVorbis:
		looping_stream.loop = true
		looping_stream.loop_offset = loop_offset
	return looping_stream


func _vary_pond_layer() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(3.5, 6.5), false).timeout
		if not is_inside_tree():
			return

		var transition_time := _random.randf_range(2.0, 3.5)
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(
			pond_sounds,
			"volume_db",
			_pond_base_volume_db + _random.randf_range(-2.0, 2.0),
			transition_time
		)
		tween.tween_property(
			pond_sounds,
			"pitch_scale",
			_random.randf_range(0.97, 1.03),
			transition_time
		)


func _play_breezes() -> void:
	await get_tree().create_timer(_random.randf_range(2.0, 4.0), false).timeout
	while is_inside_tree():
		_play_with_variation(breeze, -16.0, -12.0, 0.98, 1.02)
		if breeze.playing:
			await breeze.finished
		await get_tree().create_timer(_random.randf_range(4.0, 8.0), false).timeout


func _play_single_insect() -> void:
	await get_tree().create_timer(_random.randf_range(1.0, 2.0), false).timeout
	while is_inside_tree():
		_play_with_variation(insect_chirping, -14.0, -10.0, 0.94, 1.06)
		if insect_chirping.playing:
			await insect_chirping.finished
		await get_tree().create_timer(_random.randf_range(6.0, 7.0), false).timeout


func _play_insect_group() -> void:
	while is_inside_tree():
		await get_tree().create_timer(_random.randf_range(1.8, 2.2), false).timeout
		if not is_inside_tree():
			return
		_play_with_variation(insects_chirping, -17.0, -13.0, 0.95, 1.05)
		if insects_chirping.playing:
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
	player.volume_db = _random.randf_range(minimum_volume_db, maximum_volume_db)
	player.pitch_scale = _random.randf_range(minimum_pitch, maximum_pitch)
	player.play()


func _connect_boss_audio() -> void:
	if boss == null:
		boss = get_parent().find_child("Dragonfly Boss", true, false)
	var defeated_callback := Callable(self, "_on_boss_defeated")
	if boss != null and boss.has_signal("defeated") and not boss.is_connected("defeated", defeated_callback):
		boss.connect("defeated", defeated_callback)


func _on_boss_defeated() -> void:
	if _victory_started:
		return
	_victory_started = true
	enemy_defeat_sfx.play()
	victory_sfx.play()

	# Give the victory cue immediate space without abruptly cutting the BGM.
	var music_fade := create_tween()
	music_fade.tween_property(background_music, "volume_db", -40.0, 0.25)
	await music_fade.finished
	background_music.stop()
	background_music.volume_db = _music_base_volume_db

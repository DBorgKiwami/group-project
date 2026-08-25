extends AudioStreamPlayer

@export var combat_start: AudioStream
@export var combat_middle: AudioStream
@export var combat_final: AudioStream
@export var victory_sound: AudioStream

var _tracks: Array[AudioStream]
var _track_index := 0
var _victory_started := false


func _ready() -> void:
	if combat_start == null or combat_middle == null or combat_final == null or victory_sound == null:
		push_error("CombatMusic requires start, middle, final, and victory audio streams.")
		return

	_set_loop(combat_start, false)
	_set_loop(combat_middle, false)
	_set_loop(combat_final, true)
	_set_loop(victory_sound, false)

	_tracks = [combat_start, combat_middle, combat_final]
	finished.connect(_on_track_finished)
	_play_track(0)


func _set_loop(track: AudioStream, enabled: bool) -> void:
	if track is AudioStreamOggVorbis:
		(track as AudioStreamOggVorbis).loop = enabled


func _play_track(index: int) -> void:
	_track_index = index
	stream = _tracks[_track_index]
	play()


func _on_enemy_defeated() -> void:
	if _victory_started:
		return

	_victory_started = true
	stop()
	stream = victory_sound
	volume_db = -6.0
	play()


func _on_track_finished() -> void:
	if _victory_started:
		return
	if _track_index < _tracks.size() - 1:
		_play_track(_track_index + 1)
	else:
		# AudioStreamOggVorbis loops internally. This fallback also keeps the
		# final section repeating if the imported stream ever loses that flag.
		play()

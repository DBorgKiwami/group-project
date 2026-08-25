extends Node
#https://www.youtube.com/watch?v=m4PfHg3hmSo
#Referenced from this tutorial
#No point re-inventing wheels
signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("res://scripts/globals/loading_screen.tscn")
var transition_stream: AudioStream = preload("res://audio/music/transition.ogg")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true
var start_position_check = false
var start_position_value = Vector3(0,0,0)
var transition_in_progress := false
var transition_audio: AudioStreamPlayer


func _check_start_position() -> bool:
	print(start_position_check)
	return start_position_check;

func _ready() -> void:
	transition_audio = AudioStreamPlayer.new()
	transition_audio.name = "TransitionAudio"
	transition_audio.stream = transition_stream
	transition_audio.volume_db = -4.0
	transition_audio.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(transition_audio)
	set_process(false);


func load_scene_with_transition_sound(_scene_path: String) -> void:
	if transition_in_progress:
		return
	transition_in_progress = true
	transition_audio.play()
	await transition_audio.finished
	load_scene(_scene_path)


func load_scene_with_position_and_transition_sound(
	_scene_path: String,
	player_position: Vector3
) -> void:
	if transition_in_progress:
		return
	transition_in_progress = true
	transition_audio.play()
	await transition_audio.finished
	load_scene_with_position(_scene_path, player_position)

func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	start_load()

func load_scene_with_position(_scene_path: String, player_position: Vector3) -> void:
	scene_path = _scene_path
	start_position_check = true
	start_position_value = player_position
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			transition_in_progress = false
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()
			transition_in_progress = false
	pass

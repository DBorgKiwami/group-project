extends Control

func _ready():
	$VideoStreamPlayer.finished.connect(_on_video_finished)
	$VideoStreamPlayer.play()

func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # or wherever you want to go after

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_video_finished()

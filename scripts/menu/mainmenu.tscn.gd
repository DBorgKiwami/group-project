extends Control

@export var game_scene: PackedScene

func _ready():
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(start_game)
	$CenterContainer/VBoxContainer/OptionsButton.pressed.connect(open_options)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(quit_game)


func start_game():
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)


func open_options():
	print("Options menu opened")


func quit_game():
	get_tree().quit()

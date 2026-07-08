extends Control

# Drag your actual level scene path in here, or set it in the Inspector if you
# expose it as an @export var instead.
@export var level_scene_path : String = "res://scenes/levels/testlevel.tscn"

func _on_play_pressed() -> void:
	Scenecontroler.load_scene(level_scene_path)

func _on_settings_pressed() -> void:
	# Wire this up once you have a settings scene/menu.
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

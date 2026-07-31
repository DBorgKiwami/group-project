extends Control

# Drag your actual level scene path in here, or set it in the Inspector if you
# expose it as an @export var instead.
@export var level_scene_path : String = "res://scenes/levels/testlevel.tscn"
@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var click_sfx: AudioStreamPlayer = $ClickSfx
@onready var menu_buttons: Array[Node] = $VBoxContainer.get_children()


func _on_menu_button_hovered() -> void:
	hover_sfx.play()


func _play_click_sfx() -> void:
	_set_buttons_disabled(true)
	click_sfx.play()
	await click_sfx.finished
	_set_buttons_disabled(false)


func _set_buttons_disabled(disabled: bool) -> void:
	for button in menu_buttons:
		if button is Button:
			button.disabled = disabled


func _on_play_pressed() -> void:
	await _play_click_sfx()
	Scenecontroler.load_scene(level_scene_path)

func _on_settings_pressed() -> void:
	await _play_click_sfx()
	# Wire this up once you have a settings scene/menu.
	pass

func _on_quit_pressed() -> void:
	await _play_click_sfx()
	get_tree().quit()

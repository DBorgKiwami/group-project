extends CanvasLayer
@export var main_menu_scene_path : String = "res://scenes/menu/menu.tscn"
@onready var visual: Control = $Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if visual:
		visual.visible = false
		visual.resume_pressed.connect(_on_resume_pressed)
		visual.quit_to_menu_pressed.connect(_on_quit_to_menu_pressed)
		visual.exit_desktop_pressed.connect(_on_exit_desktop_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	if visual:
		visual.visible = get_tree().paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)

func _on_exit_desktop_pressed() -> void:
	get_tree().quit()

extends CanvasLayer

@export var main_menu_scene_path : String = "res://scenes/menu/menu.tscn"

@onready var panel: Control = $Control/PanelContainer
@onready var options_panel: Control = null 

func _ready() -> void:
	# Keep this node (and everything under it) processing even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if options_panel:
		options_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# If the options sub-panel is open, close that first instead of unpausing
		if options_panel and options_panel.visible:
			options_panel.visible = false
			get_viewport().set_input_as_handled()
			return
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_options_pressed() -> void:
	if options_panel:
		options_panel.visible = true
	else:
		print("Options panel not built yet")

func _on_options_back_pressed() -> void:
	if options_panel:
		options_panel.visible = false

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)

extends Button

@export var glow_color : Color = Color(2.2, 2.2, 2.2, 1.0)  
@export var base_outline_size : int = 2
@export var hover_outline_size : int = 2
@export var glow_duration : float = 0.15

var tween : Tween
var base_font_color : Color

func _ready() -> void:
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	base_font_color = get_theme_color("font_color")
	add_theme_color_override("font_outline_color", glow_color)
	add_theme_constant_override("outline_size", base_outline_size)

func _on_hover_start() -> void:
	_animate_outline(hover_outline_size)
	add_theme_color_override("font_color", glow_color)

func _on_hover_end() -> void:
	_animate_outline(base_outline_size)
	add_theme_color_override("font_color", base_font_color)

func _animate_outline(target_size: int) -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	var current_size = get_theme_constant("outline_size")
	tween.tween_method(_set_outline_size, current_size, target_size, glow_duration)

func _set_outline_size(value: float) -> void:
	add_theme_constant_override("outline_size", int(round(value)))

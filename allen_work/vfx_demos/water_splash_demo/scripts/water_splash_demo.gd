extends Node2D

const SPLASH_SHEET := preload("res://assets/water_splash_sheet.png")

var splash_pos := Vector2(192, 125)
var is_playing := false
var timer := 0.0
var total_time := 0.62

var frame_count := 6
var frame_size := Vector2(96, 64)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	start_splash()


func _process(delta: float) -> void:
	if is_playing:
		timer += delta
		if timer > total_time:
			is_playing = false

	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			splash_pos = Vector2(192, 125)
			start_splash()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			splash_pos = get_global_mouse_position()
			start_splash()


func start_splash() -> void:
	is_playing = true
	timer = 0.0


func _draw() -> void:
	draw_background()
	draw_water_line()

	if is_playing:
		draw_splash_sprite()
		draw_soft_ripple()


func draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.012, 0.025, 0.045))

	for x in range(0, 384, 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, 216)), Color(0.035, 0.100, 0.135, 0.35))
	for y in range(0, 216, 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(384, 1)), Color(0.035, 0.100, 0.135, 0.35))


func draw_water_line() -> void:
	var water_color := Color(0.04, 0.30, 0.36, 0.65)
	draw_rect(Rect2(Vector2(0, splash_pos.y + 12), Vector2(384, 2)), water_color)

	for x in range(0, 384, 28):
		var small_offset := int(x / 28) % 2
		draw_rect(Rect2(Vector2(x, splash_pos.y + 18 + small_offset), Vector2(12, 1)), Color(0.10, 0.55, 0.62, 0.45))


func draw_splash_sprite() -> void:
	var frame := int((timer / total_time) * frame_count)
	frame = clampi(frame, 0, frame_count - 1)

	var source := Rect2(Vector2(frame * frame_size.x, 0), frame_size)
	var target_size := frame_size * 2.0
	var target_pos := splash_pos + Vector2(-target_size.x * 0.5, -target_size.y + 24)

	draw_texture_rect_region(SPLASH_SHEET, Rect2(target_pos, target_size), source)


func draw_soft_ripple() -> void:
	var t := clampf(timer / total_time, 0.0, 1.0)
	var alpha := 1.0 - t
	var width := 34.0 + t * 95.0
	var y := splash_pos.y + 14
	var color := Color(0.30, 0.82, 0.95, 0.32 * alpha)

	draw_line(Vector2(splash_pos.x - width, y), Vector2(splash_pos.x - 12, y - 2), color, 2.0)
	draw_line(Vector2(splash_pos.x + 12, y - 2), Vector2(splash_pos.x + width, y), color, 2.0)

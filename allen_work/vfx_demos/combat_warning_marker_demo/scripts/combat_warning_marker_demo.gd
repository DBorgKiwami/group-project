extends Node2D

const BG := Color(0.030, 0.050, 0.052)
const TILE := Color(0.045, 0.065, 0.064)
const DANGER := Color(0.850, 0.080, 0.070)
const DANGER_DARK := Color(0.280, 0.030, 0.035)
const WARNING_GOLD := Color(1.000, 0.700, 0.230)
const WARNING_LIGHT := Color(1.000, 0.920, 0.560)
const SHADOW := Color(0.010, 0.012, 0.014)

const MODES := ["CIRCLE", "LINE", "ARC"]

var time := 0.0
var mode_index := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT:
			mode_index = (mode_index + MODES.size() - 1) % MODES.size()
			time = 0.0
		if event.keycode == KEY_RIGHT:
			mode_index = (mode_index + 1) % MODES.size()
			time = 0.0
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			time = 0.0
		if event.keycode == KEY_R:
			mode_index = 0
			time = 0.0


func _draw() -> void:
	draw_clean_background()

	if mode_index == 0:
		draw_circle_marker(Vector2(192, 108), 48)
	elif mode_index == 1:
		draw_line_marker(Vector2(192, 108), 132, 34, -12.0)
	else:
		draw_arc_marker(Vector2(192, 126), 70, -140.0, -40.0)


func draw_clean_background() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)


func get_phase() -> float:
	return fmod(time, 1.25) / 1.25


func get_fill_alpha() -> float:
	var phase := get_phase()
	return 0.18 + phase * 0.26


func get_border_alpha() -> float:
	var phase := get_phase()
	var flash := 0.12 if phase < 0.82 else 0.38
	return 0.55 + sin(time * 15.0) * flash


func draw_circle_marker(center: Vector2, radius: int) -> void:
	var cell := 4
	var fill := Color(DANGER.r, DANGER.g, DANGER.b, get_fill_alpha())
	var border := Color(WARNING_GOLD.r, WARNING_GOLD.g, WARNING_GOLD.b, get_border_alpha())

	for y in range(-radius, radius + cell, cell):
		for x in range(-radius, radius + cell, cell):
			var p := Vector2(x, y)
			var dist := p.length()
			if dist <= radius:
				var draw_pos := center + p
				if dist > radius - 7:
					draw_rect(Rect2(draw_pos, Vector2(cell, cell)), border)
				else:
					draw_rect(Rect2(draw_pos, Vector2(cell, cell)), fill)

	draw_warning_center(center)
	draw_countdown_ticks(center, radius + 12)


func draw_line_marker(center: Vector2, length: int, width: int, angle_degrees: float) -> void:
	var cell := 4
	var angle := deg_to_rad(angle_degrees)
	var dir := Vector2(cos(angle), sin(angle))
	var side := Vector2(-dir.y, dir.x)
	var half_length := int(length / 2)
	var half_width := int(width / 2)
	var fill := Color(DANGER.r, DANGER.g, DANGER.b, get_fill_alpha())
	var border := Color(WARNING_GOLD.r, WARNING_GOLD.g, WARNING_GOLD.b, get_border_alpha())

	for along in range(-half_length, half_length + cell, cell):
		for across in range(-half_width, half_width + cell, cell):
			var p := dir * along + side * across
			var is_border := abs(across) > half_width - 6 or abs(along) > half_length - 6
			var color := border if is_border else fill
			draw_rect(Rect2(center + p, Vector2(cell, cell)), color)

	draw_warning_center(center)


func draw_arc_marker(center: Vector2, radius: int, start_degrees: float, end_degrees: float) -> void:
	var cell := 4
	var start_angle := deg_to_rad(start_degrees)
	var end_angle := deg_to_rad(end_degrees)
	var fill := Color(DANGER.r, DANGER.g, DANGER.b, get_fill_alpha())
	var border := Color(WARNING_GOLD.r, WARNING_GOLD.g, WARNING_GOLD.b, get_border_alpha())

	for y in range(-radius, cell, cell):
		for x in range(-radius, radius + cell, cell):
			var p := Vector2(x, y)
			var dist := p.length()
			var angle := atan2(p.y, p.x)
			if dist <= radius and angle >= start_angle and angle <= end_angle:
				var is_border := dist > radius - 8 or abs(angle - start_angle) < 0.08 or abs(angle - end_angle) < 0.08
				var color := border if is_border else fill
				draw_rect(Rect2(center + p, Vector2(cell, cell)), color)

	draw_warning_center(center)


func draw_warning_center(center: Vector2) -> void:
	var pulse := get_border_alpha()
	draw_rect(Rect2(center + Vector2(-8, -8), Vector2(16, 16)), Color(SHADOW.r, SHADOW.g, SHADOW.b, 0.55))
	draw_rect(Rect2(center + Vector2(-5, -5), Vector2(10, 10)), Color(WARNING_LIGHT.r, WARNING_LIGHT.g, WARNING_LIGHT.b, pulse))
	draw_rect(Rect2(center + Vector2(-2, -2), Vector2(4, 4)), Color(DANGER_DARK.r, DANGER_DARK.g, DANGER_DARK.b, 0.90))


func draw_countdown_ticks(center: Vector2, radius: int) -> void:
	var phase := get_phase()
	var active_ticks := int(3.0 - phase * 3.0)
	for i in range(3):
		var angle := deg_to_rad(-90 + i * 120)
		var pos := center + Vector2(cos(angle), sin(angle)) * radius
		var color := WARNING_LIGHT if i < active_ticks else DANGER_DARK
		draw_rect(Rect2(pos + Vector2(-3, -3), Vector2(6, 6)), color)

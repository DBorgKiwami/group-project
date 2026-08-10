extends Control

signal resume_pressed
signal quit_to_menu_pressed
signal exit_desktop_pressed

const SHADOW := Color(0.010, 0.012, 0.014)
const PANEL := Color(0.095, 0.075, 0.060, 0.92)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const BUTTON_DARK := Color(0.055, 0.066, 0.060)
const BUTTON_SELECTED := Color(0.170, 0.165, 0.130)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

const OPTIONS := ["RESUME", "QUIT GAME", "EXIT DESKTOP"]
const LETTERS := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"G": ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
}

var time := 0.0
var selected_option := 0
var button_size := Vector2(400, 58)
var button_positions: Array[Vector2] = []


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_compute_button_positions()


func _compute_button_positions() -> void:
	button_positions.clear()
	for i in range(OPTIONS.size()):
		button_positions.append(Vector2(400, 300 + i * 78))


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_UP or event.keycode == KEY_W:
			selected_option = (selected_option + OPTIONS.size() - 1) % OPTIONS.size()
		if event.keycode == KEY_DOWN or event.keycode == KEY_S:
			selected_option = (selected_option + 1) % OPTIONS.size()
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			choose_option()

	if event is InputEventMouseMotion:
		var hovered := _get_hovered_button(event.position)
		if hovered != -1:
			selected_option = hovered

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var clicked := _get_hovered_button(event.position)
			if clicked != -1:
				selected_option = clicked
				choose_option()


func _get_hovered_button(mouse_pos: Vector2) -> int:
	for i in range(button_positions.size()):
		var rect := Rect2(button_positions[i], button_size)
		if rect.has_point(mouse_pos):
			return i
	return -1


func choose_option() -> void:
	match selected_option:
		0:
			resume_pressed.emit()
		1:
			quit_to_menu_pressed.emit()
		2:
			exit_desktop_pressed.emit()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.020, 0.025, 0.025, 0.62))
	draw_panel(Vector2(276, 156), Vector2(600, 384))
	draw_pixel_text_center(Vector2(576, 210), "PAUSED", 6, WHITE)
	for i in range(OPTIONS.size()):
		draw_button(button_positions[i], OPTIONS[i], selected_option == i)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), SHADOW)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), FRAME)
	draw_rect(Rect2(pos + Vector2(12, 12), size - Vector2(24, 24)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(18, 18), size - Vector2(36, 36)), PANEL)


func draw_button(pos: Vector2, label: String, selected: bool) -> void:
	var fill_color := BUTTON_SELECTED if selected else BUTTON_DARK
	var frame_color := CREAM if selected else FRAME

	draw_rect(Rect2(pos, button_size), SHADOW)
	draw_rect(Rect2(pos + Vector2(5, 5), button_size - Vector2(10, 10)), frame_color)
	draw_rect(Rect2(pos + Vector2(10, 10), button_size - Vector2(20, 20)), fill_color)

	if selected:
		var pulse := 0.18 + sin(time * 4.0) * 0.08
		draw_rect(Rect2(pos + Vector2(12, 12), button_size - Vector2(24, 24)), Color(0.980, 0.760, 0.360, pulse))
		draw_pointer(pos + Vector2(-31, 19), true)
		draw_pointer(pos + Vector2(button_size.x + 22, 19), false)

	draw_pixel_text_center(pos + Vector2(button_size.x / 2, 12), label, 5, WHITE)


func draw_pointer(pos: Vector2, points_right: bool) -> void:
	var points := PackedVector2Array()
	if points_right:
		points = PackedVector2Array([pos, pos + Vector2(17, 10), pos + Vector2(0, 20)])
	else:
		points = PackedVector2Array([pos + Vector2(17, 0), pos + Vector2(0, 10), pos + Vector2(17, 20)])
	draw_colored_polygon(points, CREAM)


func draw_pixel_text_center(pos: Vector2, text: String, scale: int, color: Color) -> void:
	var width := get_pixel_text_width(text, scale)
	draw_pixel_text(pos - Vector2(width / 2, 0), text, scale, color)


func draw_pixel_text(pos: Vector2, text: String, scale: int, color: Color) -> void:
	var x_offset := 0
	for i in range(text.length()):
		var ch := text.substr(i, 1)
		if ch == " ":
			x_offset += 4 * scale
			continue
		if not LETTERS.has(ch):
			x_offset += 4 * scale
			continue
		var rows: Array = LETTERS[ch]
		for y in range(rows.size()):
			var row: String = rows[y]
			for x in range(row.length()):
				if row.substr(x, 1) == "1":
					draw_rect(Rect2(pos + Vector2(x_offset + x * scale, y * scale), Vector2(scale, scale)), color)
		x_offset += (rows[0].length() + 1) * scale


func get_pixel_text_width(text: String, scale: int) -> int:
	var width := 0
	for i in range(text.length()):
		var ch := text.substr(i, 1)
		if ch == " ":
			width += 4 * scale
		elif LETTERS.has(ch):
			var rows: Array = LETTERS[ch]
			width += (rows[0].length() + 1) * scale
		else:
			width += 4 * scale
	return width

extends Node2D

const BG := Color(0.030, 0.050, 0.052)
const TILE := Color(0.050, 0.083, 0.076)
const WATER := Color(0.030, 0.115, 0.130)
const DARK := Color(0.018, 0.020, 0.024)
const PANEL := Color(0.095, 0.075, 0.060, 0.92)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const BUTTON_DARK := Color(0.055, 0.066, 0.060)
const BUTTON_SELECTED := Color(0.170, 0.165, 0.130)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)
const SHADOW := Color(0.010, 0.012, 0.014)

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
var pause_visible := true
var selected_option := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			pause_visible = not pause_visible

		if not pause_visible:
			return

		if event.keycode == KEY_UP or event.keycode == KEY_W:
			selected_option = (selected_option + OPTIONS.size() - 1) % OPTIONS.size()
		if event.keycode == KEY_DOWN or event.keycode == KEY_S:
			selected_option = (selected_option + 1) % OPTIONS.size()
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			choose_option()


func choose_option() -> void:
	if selected_option == 0:
		pause_visible = false
	elif selected_option == 2:
		get_tree().quit()


func _draw() -> void:
	draw_game_scene()
	if pause_visible:
		draw_pause_screen()


func draw_game_scene() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)

	for i in range(7):
		var x := 38 + i * 48
		var y := 138 + int(sin(time * 1.2 + i) * 3.0)
		draw_rect(Rect2(Vector2(x, y), Vector2(38, 2)), WATER)
		draw_rect(Rect2(Vector2(x + 12, y + 5), Vector2(20, 1)), WATER)

	draw_rect(Rect2(Vector2(0, 0), size), Color(0.010, 0.012, 0.014, 0.22))


func draw_pause_screen() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.020, 0.025, 0.025, 0.62))
	draw_panel(Vector2(70, 28), Vector2(244, 160))

	draw_pixel_text_center(Vector2(192, 50), "PAUSED", 3, WHITE)

	for i in range(OPTIONS.size()):
		draw_button(Vector2(110, 82 + i * 32), OPTIONS[i], selected_option == i)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)


func draw_button(pos: Vector2, label: String, selected: bool) -> void:
	var button_size := Vector2(164, 24)
	var fill_color := BUTTON_SELECTED if selected else BUTTON_DARK
	var frame_color := CREAM if selected else FRAME

	draw_rect(Rect2(pos, button_size), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), button_size - Vector2(4, 4)), frame_color)
	draw_rect(Rect2(pos + Vector2(4, 4), button_size - Vector2(8, 8)), fill_color)

	if selected:
		var pulse := 0.18 + sin(time * 4.0) * 0.08
		draw_rect(Rect2(pos + Vector2(5, 5), button_size - Vector2(10, 10)), Color(0.980, 0.760, 0.360, pulse))
		draw_pointer(pos + Vector2(-13, 8), true)
		draw_pointer(pos + Vector2(button_size.x + 9, 8), false)

	draw_pixel_text_center(pos + Vector2(button_size.x / 2, 5), label, 2, WHITE)


func draw_pointer(pos: Vector2, points_right: bool) -> void:
	var points := PackedVector2Array()
	if points_right:
		points = PackedVector2Array([pos, pos + Vector2(7, 4), pos + Vector2(0, 8)])
	else:
		points = PackedVector2Array([pos + Vector2(7, 0), pos + Vector2(0, 4), pos + Vector2(7, 8)])
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

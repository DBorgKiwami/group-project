extends Node2D

const PLAYER_PORTRAIT := preload("res://assets/ui/player_portrait.png")

const BG := Color(0.010, 0.020, 0.026)
const TILE := Color(0.035, 0.060, 0.070)
const DARK := Color(0.025, 0.028, 0.036)
const PANEL := Color(0.120, 0.050, 0.055, 0.86)
const FRAME := Color(0.370, 0.280, 0.170)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.920, 0.800, 0.560)
const RED := Color(0.780, 0.090, 0.100)
const RED_LIGHT := Color(1.000, 0.380, 0.360)
const EMPTY_HEART := Color(0.145, 0.070, 0.080)

const HEART_ROWS := [
	"01100110",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100",
	"00011000",
]
const LETTERS := {
	"!": ["1", "1", "1", "1", "1", "0", "1"],
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
}

var time := 0.0
var selected_button := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT or event.keycode == KEY_RIGHT:
			selected_button = 1 - selected_button
		if event.keycode == KEY_R:
			time = 0.0


func _draw() -> void:
	draw_dark_water()
	draw_death_card()


func draw_dark_water() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)

	for i in range(5):
		var y := 126 + i * 13
		var offset := int(sin(time * 1.4 + i) * 8.0)
		draw_rect(Rect2(Vector2(54 + offset, y), Vector2(276, 2)), Color(0.150, 0.055, 0.060, 0.24))

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.420, 0.030, 0.035, 0.48))


func draw_death_card() -> void:
	var card_pos := Vector2(39, 16)
	var card_size := Vector2(306, 184)
	draw_panel(card_pos, card_size)

	draw_pixel_text_center(Vector2(192, 38), "YOU CROAKED!", 3, Color(1.000, 0.900, 0.840))
	draw_pixel_text_center(Vector2(192, 70), "THE POND PULLS YOU UNDER", 1, CREAM)

	draw_death_portrait(Vector2(164, 82))
	draw_empty_hearts(Vector2(128, 147))

	draw_button(Vector2(107, 172), "RETRY", selected_button == 0)
	draw_button(Vector2(209, 172), "RETURN", selected_button == 1)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)


func draw_death_portrait(pos: Vector2) -> void:
	var blink := 0.18 + sin(time * 6.0) * 0.12
	draw_texture_rect(PLAYER_PORTRAIT, Rect2(pos, Vector2(56, 60)), false)
	draw_texture_rect(PLAYER_PORTRAIT, Rect2(pos, Vector2(56, 60)), false, Color(1.0, 0.05, 0.05, blink))


func draw_empty_hearts(pos: Vector2) -> void:
	for i in range(5):
		draw_heart(pos + Vector2(i * 28, 0), false)


func draw_heart(pos: Vector2, is_full: bool) -> void:
	var fill := RED if is_full else EMPTY_HEART
	draw_heart_pixels(pos + Vector2(-2, 0), DARK)
	draw_heart_pixels(pos + Vector2(2, 0), DARK)
	draw_heart_pixels(pos + Vector2(0, -2), DARK)
	draw_heart_pixels(pos + Vector2(0, 2), DARK)
	draw_heart_pixels(pos, fill)


func draw_heart_pixels(pos: Vector2, color: Color) -> void:
	var pixel_size := 2
	for y in range(HEART_ROWS.size()):
		var row: String = HEART_ROWS[y]
		for x in range(row.length()):
			if row.substr(x, 1) == "1":
				draw_rect(Rect2(pos + Vector2(x * pixel_size, y * pixel_size), Vector2(pixel_size, pixel_size)), color)


func draw_button(pos: Vector2, label: String, selected: bool) -> void:
	var frame_color := RED_LIGHT if selected else FRAME
	draw_rect(Rect2(pos, Vector2(68, 18)), DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(64, 14)), frame_color)
	draw_rect(Rect2(pos + Vector2(4, 4), Vector2(60, 10)), Color(0.120, 0.065, 0.070))
	if selected:
		draw_rect(Rect2(pos + Vector2(5, 5), Vector2(58, 8)), Color(0.450, 0.055, 0.060, 0.30))
	draw_pixel_text_center(pos + Vector2(34, 5), label, 1, WHITE)


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

extends Node2D

const PLAYER_PORTRAIT := preload("res://assets/ui/player_portrait.png")

const BG := Color(0.030, 0.050, 0.052)
const TILE := Color(0.050, 0.083, 0.076)
const WATER := Color(0.030, 0.115, 0.130)
const DARK := Color(0.018, 0.020, 0.024)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PORTRAIT_BG := Color(0.080, 0.150, 0.155)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)
const MUTED := Color(0.610, 0.690, 0.630)
const SHADOW := Color(0.010, 0.012, 0.014)

const DIALOGUE := [
	{
		"name": "POND GUIDE",
		"lines": ["THE MARSH IS QUIET", "KEEP YOUR EYES OPEN"],
	},
	{
		"name": "POND GUIDE",
		"lines": ["OLD DOORS WAKE UP", "WHEN THE LILY GLOWS"],
	},
	{
		"name": "POND GUIDE",
		"lines": ["COME BACK SAFELY", "LITTLE FROG"],
	},
]

const LETTERS := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
	"G": ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
	"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"J": ["00111", "00010", "00010", "00010", "10010", "10010", "01100"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"V": ["10001", "10001", "10001", "10001", "01010", "01010", "00100"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
	"Z": ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
}

var time := 0.0
var dialogue_index := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E:
			dialogue_index = (dialogue_index + 1) % DIALOGUE.size()
			time = 0.0
		if event.keycode == KEY_R:
			dialogue_index = 0
			time = 0.0


func _draw() -> void:
	draw_game_scene()
	draw_dialogue_screen()


func draw_game_scene() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)

	for i in range(7):
		var x := 36 + i * 48
		var y := 116 + int(sin(time * 1.1 + i) * 3.0)
		draw_rect(Rect2(Vector2(x, y), Vector2(38, 2)), WATER)
		draw_rect(Rect2(Vector2(x + 12, y + 5), Vector2(20, 1)), WATER)

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.010, 0.012, 0.014, 0.20))


func draw_dialogue_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.010, 0.014, 0.015, 0.24))
	draw_name_plate(Vector2(28, 112), Vector2(116, 22))
	draw_panel(Vector2(18, 132), Vector2(348, 70))
	draw_portrait_box(Vector2(29, 143))
	draw_dialogue_text(Vector2(96, 151))
	draw_continue_hint(Vector2(335, 177))


func draw_name_plate(pos: Vector2, size: Vector2) -> void:
	var page: Dictionary = DIALOGUE[dialogue_index]
	var speaker_name: String = page["name"]

	draw_rect(Rect2(pos, size), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), Color(0.120, 0.095, 0.070))
	draw_pixel_text_center(pos + Vector2(size.x / 2, 7), speaker_name, 1, CREAM)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)


func draw_portrait_box(pos: Vector2) -> void:
	draw_rect(Rect2(pos, Vector2(54, 50)), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(50, 46)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), Vector2(46, 42)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(7, 5), Vector2(40, 40)), PORTRAIT_BG)
	draw_texture_rect(PLAYER_PORTRAIT, Rect2(pos + Vector2(8, 5), Vector2(37, 40)), false)


func draw_dialogue_text(pos: Vector2) -> void:
	var page: Dictionary = DIALOGUE[dialogue_index]
	var lines: Array = page["lines"]
	var visible_letters := int(time * 24.0)
	var left := visible_letters

	for i in range(lines.size()):
		var line: String = lines[i]
		var shown_count := clamp(left, 0, line.length())
		var shown := line.substr(0, shown_count)
		draw_pixel_text(pos + Vector2(0, i * 22), shown, 2, WHITE)
		left -= line.length()


func draw_continue_hint(pos: Vector2) -> void:
	var pulse := 0.45 + sin(time * 5.0) * 0.20
	var arrow_pos := pos + Vector2(int(sin(time * 5.0) * 2.0), int(sin(time * 4.0) * 1.0))
	var points := PackedVector2Array([arrow_pos, arrow_pos + Vector2(10, 6), arrow_pos + Vector2(0, 12)])
	draw_colored_polygon(points, Color(CREAM.r, CREAM.g, CREAM.b, pulse))


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

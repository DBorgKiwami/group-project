extends Node2D

const BG := Color(0.025, 0.040, 0.042)
const TILE := Color(0.045, 0.065, 0.064)
const WATER := Color(0.030, 0.115, 0.130)
const DARK := Color(0.020, 0.024, 0.030)
const SHADOW := Color(0.010, 0.012, 0.014)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)
const MUTED := Color(0.560, 0.630, 0.585)
const GREEN := Color(0.330, 0.720, 0.430)
const BLUE := Color(0.180, 0.460, 0.520)

const OBJECTIVES := [
	{"title": "REACH PUMP", "hint": "FOLLOW POND PATH"},
	{"title": "CROSS LILY PADS", "hint": "USE SMALL PLATFORMS"},
	{"title": "TALK TO DWELLER", "hint": "PRESS E NEAR NPC"},
	{"title": "ENTER OLD WELL", "hint": "FIND NEXT AREA"},
]

const LETTERS := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
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
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"V": ["10001", "10001", "10001", "10001", "01010", "01010", "00100"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"],
}

var time := 0.0
var objective_index := 0
var update_time := 1.2
var complete_flash := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	update_time = maxf(update_time - delta, 0.0)
	complete_flash = maxf(complete_flash - delta, 0.0)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			next_objective()
		if event.keycode == KEY_LEFT:
			objective_index = max(objective_index - 1, 0)
			update_time = 1.2
		if event.keycode == KEY_RIGHT:
			objective_index = min(objective_index + 1, OBJECTIVES.size() - 1)
			update_time = 1.2
		if event.keycode == KEY_R:
			objective_index = 0
			update_time = 1.2
			complete_flash = 0.0


func next_objective() -> void:
	complete_flash = 0.25
	if objective_index < OBJECTIVES.size() - 1:
		objective_index += 1
	update_time = 1.2


func _draw() -> void:
	draw_demo_background()
	draw_objective_tracker()
	draw_update_banner()


func draw_demo_background() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)

	for i in range(5):
		var y := 145 + i * 12
		var offset := int(sin(time * 1.1 + i) * 5.0)
		draw_rect(Rect2(Vector2(36 + offset, y), Vector2(112, 2)), Color(WATER.r, WATER.g, WATER.b, 0.36))
		draw_rect(Rect2(Vector2(208 - offset, y + 5), Vector2(92, 1)), Color(BLUE.r, BLUE.g, BLUE.b, 0.28))


func draw_objective_tracker() -> void:
	var pos := Vector2(8, 8)
	var size := Vector2(188, 62)
	draw_panel(pos, size)
	draw_pixel_text(pos + Vector2(13, 10), "OBJECTIVE", 1, CREAM)

	var objective: Dictionary = OBJECTIVES[objective_index]
	var title: String = objective["title"]
	var hint: String = objective["hint"]
	draw_objective_icon(pos + Vector2(13, 29))
	draw_pixel_text(pos + Vector2(33, 27), title, 1, WHITE)
	draw_pixel_text(pos + Vector2(33, 45), hint, 1, MUTED)
	draw_progress_dots(pos + Vector2(150, 12))

	if complete_flash > 0.0:
		draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), Color(GREEN.r, GREEN.g, GREEN.b, complete_flash))


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(3, 4), size), SHADOW)
	draw_rect(Rect2(pos, size), DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)


func draw_objective_icon(pos: Vector2) -> void:
	draw_rect(Rect2(pos, Vector2(13, 13)), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(9, 9)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(4, 4), Vector2(5, 5)), Color(0.090, 0.120, 0.100))
	draw_rect(Rect2(pos + Vector2(6, 2), Vector2(2, 9)), GREEN)
	draw_rect(Rect2(pos + Vector2(2, 6), Vector2(9, 2)), GREEN)


func draw_progress_dots(pos: Vector2) -> void:
	for i in range(OBJECTIVES.size()):
		var color := GREEN if i <= objective_index else Color(0.170, 0.135, 0.090)
		draw_rect(Rect2(pos + Vector2(i * 8, 0), Vector2(5, 5)), SHADOW)
		draw_rect(Rect2(pos + Vector2(i * 8 + 1, 1), Vector2(3, 3)), color)


func draw_update_banner() -> void:
	if update_time <= 0.0:
		return

	var alpha := minf(update_time / 0.35, 1.0)
	var y_offset := int((1.0 - alpha) * -8.0)
	var pos := Vector2(98, 78 + y_offset)
	var size := Vector2(188, 30)
	draw_rect(Rect2(pos + Vector2(3, 4), size), Color(SHADOW.r, SHADOW.g, SHADOW.b, 0.45 * alpha))
	draw_rect(Rect2(pos, size), Color(DARK.r, DARK.g, DARK.b, alpha))
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), Color(FRAME.r, FRAME.g, FRAME.b, alpha))
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), Color(FRAME_LIGHT.r, FRAME_LIGHT.g, FRAME_LIGHT.b, alpha))
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), Color(PANEL.r, PANEL.g, PANEL.b, PANEL.a * alpha))
	draw_pixel_text_center(pos + Vector2(size.x / 2, 10), "OBJECTIVE UPDATED", 1, Color(WHITE.r, WHITE.g, WHITE.b, alpha))


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

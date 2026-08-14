extends Node2D

const BG := Color(0.025, 0.040, 0.042)
const TILE := Color(0.045, 0.065, 0.064)
const WATER := Color(0.030, 0.120, 0.135)
const POND_DEEP := Color(0.010, 0.045, 0.055)
const POND_DARK := Color(0.015, 0.075, 0.085)
const POND_MID := Color(0.045, 0.155, 0.170)
const POND_LIGHT := Color(0.150, 0.390, 0.430)
const POND_GLOW := Color(0.080, 0.260, 0.290)
const MUD := Color(0.120, 0.095, 0.060)
const REED := Color(0.285, 0.430, 0.220)
const LILY := Color(0.105, 0.300, 0.185)
const DARK := Color(0.020, 0.024, 0.030)
const SHADOW := Color(0.010, 0.012, 0.014)
const PANEL := Color(0.070, 0.090, 0.085, 0.88)
const FRAME := Color(0.380, 0.280, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.920, 0.800, 0.560)
const GREEN_LIGHT := Color(0.260, 0.620, 0.560)
const FADE_COLOR := Color(0.005, 0.010, 0.010)

const AREA_NAMES := [
	"MISTY POND",
	"OLD WELL",
	"FLOODED RUINS",
]

const AREA_SUBTITLES := [
	"THE OLD WATERWAY",
	"DEEP UNDER THE ROOTS",
	"WATER BELOW THE STONE",
]

const LETTERS := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
	"G": ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
	"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
}

var time := 0.0
var area_index := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	if time > 5.6:
		time = 0.0
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_R:
			time = 0.0
		if event.keycode == KEY_LEFT:
			area_index = (area_index + AREA_NAMES.size() - 1) % AREA_NAMES.size()
			time = 0.0
		if event.keycode == KEY_RIGHT:
			area_index = (area_index + 1) % AREA_NAMES.size()
			time = 0.0


func _draw() -> void:
	draw_simple_scene()
	draw_area_title()
	draw_fade_layer()


func draw_simple_scene() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)

	draw_pond_water()


func draw_pond_water() -> void:
	draw_rect(Rect2(Vector2(0, 116), Vector2(384, 100)), Color(POND_DEEP.r, POND_DEEP.g, POND_DEEP.b, 0.78))

	for y in range(116, 216, 16):
		for x in range(0, 384, 16):
			if int(x / 16 + y / 16) % 3 == 0:
				draw_rect(Rect2(Vector2(x, y), Vector2(16, 16)), Color(POND_DARK.r, POND_DARK.g, POND_DARK.b, 0.22))

	draw_pond_bank()

	for i in range(18):
		var x := 18 + (i * 37) % 342
		var y := 130 + (i * 17) % 72
		var offset := int(sin(time * 1.1 + i) * 2.0)
		var width := 12 + (i % 4) * 4
		var alpha := 0.16 + (i % 3) * 0.05
		draw_water_ripple(Vector2(x + offset, y), width, alpha)

	draw_lily_pad(Vector2(58, 177))
	draw_lily_pad(Vector2(294, 158))
	draw_lily_pad(Vector2(326, 192))
	draw_reeds(Vector2(24, 183))
	draw_reeds(Vector2(350, 170))


func draw_pond_bank() -> void:
	draw_rect(Rect2(Vector2(0, 112), Vector2(384, 8)), Color(MUD.r, MUD.g, MUD.b, 0.38))
	for i in range(10):
		var x := i * 42 + 8
		draw_rect(Rect2(Vector2(x, 116), Vector2(22, 4)), Color(POND_DARK.r, POND_DARK.g, POND_DARK.b, 0.60))


func draw_water_ripple(pos: Vector2, width: int, alpha: float) -> void:
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(width, 2)), Color(POND_DARK.r, POND_DARK.g, POND_DARK.b, alpha * 0.90))
	draw_rect(Rect2(pos, Vector2(width - 3, 2)), Color(POND_GLOW.r, POND_GLOW.g, POND_GLOW.b, alpha))
	draw_rect(Rect2(pos + Vector2(5, -2), Vector2(maxi(width - 11, 4), 1)), Color(POND_LIGHT.r, POND_LIGHT.g, POND_LIGHT.b, alpha * 0.62))
	if width > 18:
		draw_rect(Rect2(pos + Vector2(9, 4), Vector2(width - 16, 1)), Color(WATER.r, WATER.g, WATER.b, alpha * 0.45))


func draw_lily_pad(pos: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(2, 0), Vector2(12, 4)), Color(LILY.r, LILY.g, LILY.b, 0.70))
	draw_rect(Rect2(pos, Vector2(16, 8)), Color(LILY.r, LILY.g, LILY.b, 0.70))
	draw_rect(Rect2(pos + Vector2(6, 3), Vector2(5, 3)), Color(POND_DEEP.r, POND_DEEP.g, POND_DEEP.b, 0.70))
	draw_rect(Rect2(pos + Vector2(3, 1), Vector2(4, 1)), Color(GREEN_LIGHT.r, GREEN_LIGHT.g, GREEN_LIGHT.b, 0.38))


func draw_reeds(pos: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(0, 6), Vector2(2, 16)), Color(REED.r, REED.g, REED.b, 0.62))
	draw_rect(Rect2(pos + Vector2(6, 0), Vector2(2, 22)), Color(REED.r, REED.g, REED.b, 0.68))
	draw_rect(Rect2(pos + Vector2(12, 8), Vector2(2, 14)), Color(REED.r, REED.g, REED.b, 0.58))
	draw_rect(Rect2(pos + Vector2(3, 10), Vector2(8, 2)), Color(GREEN_LIGHT.r, GREEN_LIGHT.g, GREEN_LIGHT.b, 0.26))


func draw_area_title() -> void:
	var alpha := get_title_alpha()
	if alpha <= 0.0:
		return

	var panel_width := 264
	var panel_height := 58
	var panel_pos := Vector2(60, 70)
	var move_y := int((1.0 - alpha) * 8.0)
	panel_pos.y += move_y

	draw_transition_panel(panel_pos, Vector2(panel_width, panel_height), alpha)
	draw_corner_marks(panel_pos, Vector2(panel_width, panel_height), alpha)

	var title_color := Color(WHITE.r, WHITE.g, WHITE.b, alpha)
	var subtitle_color := Color(CREAM.r, CREAM.g, CREAM.b, alpha)
	draw_pixel_text_center(Vector2(192, panel_pos.y + 17), AREA_NAMES[area_index], 3, title_color)
	draw_pixel_text_center(Vector2(192, panel_pos.y + 42), AREA_SUBTITLES[area_index], 1, subtitle_color)


func draw_transition_panel(pos: Vector2, size: Vector2, alpha: float) -> void:
	draw_rect(Rect2(pos + Vector2(3, 4), size), Color(SHADOW.r, SHADOW.g, SHADOW.b, 0.42 * alpha))
	draw_rect(Rect2(pos, size), Color(DARK.r, DARK.g, DARK.b, alpha))
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), Color(FRAME.r, FRAME.g, FRAME.b, alpha))
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), Color(FRAME_LIGHT.r, FRAME_LIGHT.g, FRAME_LIGHT.b, alpha))
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), Color(PANEL.r, PANEL.g, PANEL.b, PANEL.a * alpha))


func draw_corner_marks(pos: Vector2, size: Vector2, alpha: float) -> void:
	var color := Color(GREEN_LIGHT.r, GREEN_LIGHT.g, GREEN_LIGHT.b, 0.65 * alpha)
	draw_rect(Rect2(pos + Vector2(14, 14), Vector2(16, 2)), color)
	draw_rect(Rect2(pos + Vector2(14, 14), Vector2(2, 12)), color)
	draw_rect(Rect2(pos + Vector2(size.x - 30, size.y - 16), Vector2(16, 2)), color)
	draw_rect(Rect2(pos + Vector2(size.x - 16, size.y - 26), Vector2(2, 12)), color)


func draw_fade_layer() -> void:
	var alpha := get_fade_alpha()
	if alpha > 0.0:
		var size := get_viewport_rect().size
		draw_rect(Rect2(Vector2.ZERO, size), Color(FADE_COLOR.r, FADE_COLOR.g, FADE_COLOR.b, alpha))


func get_fade_alpha() -> float:
	if time < 0.9:
		return 1.0 - time / 0.9
	if time > 4.5:
		return minf((time - 4.5) / 0.9, 1.0)
	return 0.0


func get_title_alpha() -> float:
	if time < 0.7:
		return 0.0
	if time < 1.3:
		return (time - 0.7) / 0.6
	if time < 3.9:
		return 1.0
	if time < 4.5:
		return 1.0 - (time - 3.9) / 0.6
	return 0.0


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

extends Node2D

const BG := Color(0.030, 0.050, 0.052)
const SHADOW := Color(0.010, 0.012, 0.014)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

const ACTIONS := ["TALK", "INSPECT", "PICK UP", "ENTER"]
const LETTERS := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
}

var time := 0.0
var action_index := 0
var confirm_time := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	confirm_time = max(confirm_time - delta, 0.0)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT:
			action_index = (action_index + ACTIONS.size() - 1) % ACTIONS.size()
		if event.keycode == KEY_RIGHT:
			action_index = (action_index + 1) % ACTIONS.size()
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			confirm_time = 0.18
		if event.keycode == KEY_R:
			action_index = 0
			confirm_time = 0.0


func _draw() -> void:
	draw_clean_background()
	draw_interaction_prompt(Vector2(192, 96))


func draw_clean_background() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)


func draw_interaction_prompt(pos: Vector2) -> void:
	var label: String = ACTIONS[action_index]
	var box_width := get_pixel_text_width(label, 1) + 40
	var box_pos := pos + Vector2(-box_width / 2, int(sin(time * 4.0) * 3.0))
	var glow := 0.0
	if confirm_time > 0.0:
		glow = confirm_time * 2.5

	draw_prompt_box(box_pos, Vector2(box_width, 24), glow)
	draw_key_box(box_pos + Vector2(6, 5), glow)
	draw_pixel_text(box_pos + Vector2(29, 8), label, 1, WHITE)
	draw_prompt_tail(box_pos + Vector2(box_width / 2 - 4, 22))


func draw_prompt_box(pos: Vector2, size: Vector2, glow: float) -> void:
	draw_rect(Rect2(pos, size), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)
	if glow > 0.0:
		draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), Color(CREAM.r, CREAM.g, CREAM.b, glow))


func draw_key_box(pos: Vector2, glow: float) -> void:
	var fill := Color(0.110, 0.095, 0.070)
	if glow > 0.0:
		fill = Color(0.240, 0.170, 0.090)

	draw_rect(Rect2(pos, Vector2(17, 14)), SHADOW)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(13, 10)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(4, 4), Vector2(9, 6)), fill)
	draw_pixel_text(pos + Vector2(7, 4), "E", 1, CREAM)


func draw_prompt_tail(pos: Vector2) -> void:
	var points := PackedVector2Array([pos, pos + Vector2(8, 0), pos + Vector2(4, 6)])
	draw_colored_polygon(points, FRAME_LIGHT)


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

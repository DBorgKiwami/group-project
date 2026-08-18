extends Node2D

const PLAYER_PORTRAIT := preload("res://allen_work/allen_work/ui_demos/death_screen_demo/assets/ui/player_portrait.png")

const SHADOW := Color(0.010, 0.012, 0.014)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PORTRAIT_BG := Color(0.080, 0.150, 0.155)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

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
	"!": ["1", "1", "1", "1", "1", "0", "1"],
	"?": ["01110", "10001", "00010", "00100", "00100", "00000", "00100"],
	",": ["000", "000", "000", "000", "010", "010", "100"],
	".": ["000", "000", "000", "000", "000", "010", "010"],
	"'": ["010", "010", "000", "000", "000", "000", "000"],
}

var speaker_name: String = "SPEAKER"
var current_line: String = ""
var time: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func start_line(line: String) -> void:
	current_line = line
	time = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return

	time += delta
	queue_redraw()


func _draw() -> void:
	draw_dialogue_screen()


func draw_dialogue_screen() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_pos := Vector2(
		viewport_size.x / 2.0 - 250.0,
		viewport_size.y - 180.0
	)

	draw_name_plate(
		panel_pos + Vector2(10, -20),
		Vector2(150, 30)
	)

	draw_panel(
		panel_pos,
		Vector2(500, 150)
	)

	draw_portrait_box(
		panel_pos + Vector2(12, 24)
	)

	draw_dialogue_text(
		panel_pos + Vector2(140, 42)
	)

	draw_continue_hint(
		panel_pos + Vector2(470, 120)
	)


func draw_name_plate(pos: Vector2, size: Vector2) -> void:
	draw_rect(
		Rect2(pos, size),
		SHADOW
	)

	draw_rect(
		Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)),
		FRAME
	)

	draw_rect(
		Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)),
		Color(0.120, 0.095, 0.070)
	)

	draw_pixel_text_center(
		pos + Vector2(size.x / 2.0, 9),
		speaker_name,
		2,
		CREAM
	)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(
		Rect2(pos, size),
		SHADOW
	)

	draw_rect(
		Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)),
		FRAME
	)

	draw_rect(
		Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)),
		FRAME_LIGHT
	)

	draw_rect(
		Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)),
		PANEL
	)


func draw_portrait_box(pos: Vector2) -> void:
	draw_rect(
		Rect2(pos, Vector2(110, 100)),
		SHADOW
	)

	draw_rect(
		Rect2(pos + Vector2(4, 4), Vector2(102, 92)),
		FRAME
	)

	draw_rect(
		Rect2(pos + Vector2(8, 8), Vector2(94, 84)),
		FRAME_LIGHT
	)

	draw_rect(
		Rect2(pos + Vector2(14, 10), Vector2(80, 80)),
		PORTRAIT_BG
	)

	draw_texture_rect(
		PLAYER_PORTRAIT,
		Rect2(
			pos + Vector2(16, 10),
			Vector2(74, 80)
		),
		false
	)


func draw_dialogue_text(pos: Vector2) -> void:
	if current_line == "":
		return

	var visible_letters: int = int(time * 30.0)

	var shown_count: int = clampi(
		visible_letters,
		0,
		current_line.length()
	)

	var shown: String = current_line.substr(
		0,
		shown_count
	)

	# Wrap the text before drawing it.
	var wrapped_lines: Array[String] = _wrap_text(
		shown,
		32
	)

	# The box has room for three lines.
	var max_lines: int = mini(
		wrapped_lines.size(),
		3
	)

	for i in range(max_lines):
		draw_pixel_text(
			pos + Vector2(0, i * 22),
			wrapped_lines[i],
			2,
			WHITE
		)


func _wrap_text(text: String, max_chars: int) -> Array[String]:
	var words: PackedStringArray = text.split(" ")
	var lines: Array[String] = []
	var current_line_buf: String = ""

	for word in words:
		var test_line: String

		if current_line_buf == "":
			test_line = word
		else:
			test_line = current_line_buf + " " + word

		if test_line.length() > max_chars and current_line_buf != "":
			lines.append(current_line_buf)
			current_line_buf = word
		else:
			current_line_buf = test_line

	if current_line_buf != "":
		lines.append(current_line_buf)

	return lines


func draw_continue_hint(pos: Vector2) -> void:
	if current_line == "":
		return

	var visible_letters: int = int(time * 30.0)

	if visible_letters < current_line.length():
		return

	var pulse: float = 0.45 + sin(time * 5.0) * 0.20

	var arrow_pos := pos + Vector2(
		int(sin(time * 5.0) * 2.0),
		int(sin(time * 4.0) * 1.0)
	)

	var points := PackedVector2Array([
		arrow_pos,
		arrow_pos + Vector2(10, 6),
		arrow_pos + Vector2(0, 12)
	])

	draw_colored_polygon(
		points,
		Color(
			CREAM.r,
			CREAM.g,
			CREAM.b,
			pulse
		)
	)


func draw_pixel_text_center(
	pos: Vector2,
	text: String,
	scale: int,
	color: Color
) -> void:
	var width: int = get_pixel_text_width(
		text,
		scale
	)

	draw_pixel_text(
		pos - Vector2(width / 2.0, 0),
		text,
		scale,
		color
	)


func draw_pixel_text(
	pos: Vector2,
	text: String,
	scale: int,
	color: Color
) -> void:
	var x_offset: int = 0

	for i in range(text.length()):
		var ch: String = text.substr(
			i,
			1
		).to_upper()

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
					draw_rect(
						Rect2(
							pos + Vector2(
								x_offset + x * scale,
								y * scale
							),
							Vector2(
								scale,
								scale
							)
						),
						color
					)

		x_offset += (
			rows[0].length() + 1
		) * scale


func get_pixel_text_width(
	text: String,
	scale: int
) -> int:
	var width: int = 0

	for i in range(text.length()):
		var ch: String = text.substr(
			i,
			1
		)

		if ch == " ":
			width += 4 * scale

		elif LETTERS.has(ch.to_upper()):
			var rows: Array = LETTERS[ch.to_upper()]
			width += (
				rows[0].length() + 1
			) * scale

		else:
			width += 4 * scale

	return width

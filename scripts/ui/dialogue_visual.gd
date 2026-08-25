extends Node2D

const SHADOW := Color(0.010, 0.012, 0.014)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

const PANEL_WIDTH := 700.0
const PANEL_HEIGHT := 150.0

const TEXT_LEFT := 25.0
const TEXT_TOP := 30.0
const TEXT_WIDTH := 630.0
const LINE_HEIGHT := 22.0
const MAX_LINES := 5
const TEXT_SPEED := 30.0

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

	# Visible pixel apostrophe
	"'": ["011", "011", "000", "000", "000", "000", "000"],
}

var speaker_name: String = "MERCHANT"
var current_line: String = ""
var pages: Array[String] = []
var current_page: int = 0
var time: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func start_line(line: String) -> void:
	current_line = line
	pages = _create_pages(line)
	current_page = 0
	time = 0.0
	queue_redraw()


func is_typing() -> bool:
	if pages.is_empty():
		return false

	return time * TEXT_SPEED < pages[current_page].length()


func has_next_page() -> bool:
	return current_page < pages.size() - 1


func advance_page() -> bool:
	if not has_next_page():
		return false

	current_page += 1
	time = 0.0
	queue_redraw()

	return true


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
		(viewport_size.x - PANEL_WIDTH) / 2.0,
		viewport_size.y - 180.0
	)

	draw_name_plate(
		panel_pos + Vector2(10, -20),
		Vector2(170, 30)
	)

	draw_panel(
		panel_pos,
		Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	)

	draw_dialogue_text(
		panel_pos + Vector2(TEXT_LEFT, TEXT_TOP)
	)

	draw_continue_hint(
		panel_pos + Vector2(PANEL_WIDTH - 30, PANEL_HEIGHT - 30)
	)


func draw_name_plate(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), SHADOW)

	draw_rect(
		Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)),
		FRAME
	)

	draw_rect(
		Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)),
		Color(0.120, 0.095, 0.070)
	)

	draw_pixel_text_center(
		pos + Vector2(size.x / 2.0, 7),
		speaker_name,
		2,
		CREAM
	)


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), SHADOW)

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


func draw_dialogue_text(pos: Vector2) -> void:
	if pages.is_empty():
		return

	var page_text: String = pages[current_page]

	var visible_letters: int = int(time * TEXT_SPEED)

	var shown_count: int = clampi(
		visible_letters,
		0,
		page_text.length()
	)

	var shown: String = page_text.substr(0, shown_count)

	var lines: Array[String] = _wrap_text_by_width(shown)

	for i in range(lines.size()):
		if i >= MAX_LINES:
			break

		draw_pixel_text(
			pos + Vector2(0, i * LINE_HEIGHT),
			lines[i],
			2,
			WHITE
		)


func _create_pages(text: String) -> Array[String]:
	var all_lines: Array[String] = _wrap_text_by_width(text)
	var result: Array[String] = []

	var current_page_text := ""
	var line_count := 0

	for line in all_lines:
		if line_count >= MAX_LINES:
			result.append(current_page_text)
			current_page_text = ""
			line_count = 0

		if current_page_text == "":
			current_page_text = line
		else:
			current_page_text += "\n" + line

		line_count += 1

	if current_page_text != "":
		result.append(current_page_text)

	return result


func _wrap_text_by_width(text: String) -> Array[String]:
	var result: Array[String] = []

	var paragraphs: PackedStringArray = text.split("\n")

	for paragraph in paragraphs:
		var words: PackedStringArray = paragraph.split(" ")
		var current: String = ""

		for word in words:
			if word == "":
				continue

			var test_line: String

			if current == "":
				test_line = word
			else:
				test_line = current + " " + word

			if get_pixel_text_width(test_line, 2) <= TEXT_WIDTH:
				current = test_line
			else:
				if current != "":
					result.append(current)

				if get_pixel_text_width(word, 2) > TEXT_WIDTH:
					var partial := ""

					for character_index in range(word.length()):
						var character := word.substr(character_index, 1)
						var test_partial := partial + character

						if get_pixel_text_width(test_partial, 2) <= TEXT_WIDTH:
							partial = test_partial
						else:
							if partial != "":
								result.append(partial)

							partial = character

					current = partial
				else:
					current = word

		if current != "":
			result.append(current)

	return result


func draw_continue_hint(pos: Vector2) -> void:
	if pages.is_empty():
		return

	var page_text: String = pages[current_page]
	var visible_letters: int = int(time * TEXT_SPEED)

	if visible_letters < page_text.length():
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
		Color(CREAM.r, CREAM.g, CREAM.b, pulse)
	)


func draw_pixel_text_center(
	pos: Vector2,
	text: String,
	scale: int,
	color: Color
) -> void:
	var width: int = get_pixel_text_width(text, scale)

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
		var ch: String = text.substr(i, 1)

		# Keep punctuation intact.
		if ch != "'" and ch != "," and ch != "." and ch != "!" and ch != "?":
			ch = ch.to_upper()

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
							Vector2(scale, scale)
						),
						color
					)

		x_offset += (rows[0].length() + 1) * scale


func get_pixel_text_width(
	text: String,
	scale: int
) -> int:
	var width: int = 0

	for i in range(text.length()):
		var ch: String = text.substr(i, 1)

		if ch == " ":
			width += 4 * scale

		elif LETTERS.has(ch.to_upper()):
			var rows: Array = LETTERS[ch.to_upper()]
			width += (rows[0].length() + 1) * scale

		else:
			width += 4 * scale

	return width

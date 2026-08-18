extends Node2D

const SHADOW := Color(0.010, 0.012, 0.014)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

const LETTERS := {
	"A": ["01110","10001","10001","11111","10001","10001","10001"],
	"B": ["11110","10001","10001","11110","10001","10001","11110"],
	"C": ["01111","10000","10000","10000","10000","10000","01111"],
	"D": ["11110","10001","10001","10001","10001","10001","11110"],
	"E": ["11111","10000","10000","11110","10000","10000","11111"],
	"F": ["11111","10000","10000","11110","10000","10000","10000"],
	"G": ["01111","10000","10000","10011","10001","10001","01111"],
	"H": ["10001","10001","10001","11111","10001","10001","10001"],
	"I": ["111","010","010","010","010","010","111"],
	"J": ["00111","00010","00010","00010","10010","10010","01100"],
	"K": ["10001","10010","10100","11000","10100","10010","10001"],
	"L": ["10000","10000","10000","10000","10000","10000","11111"],
	"M": ["10001","11011","10101","10101","10001","10001","10001"],
	"N": ["10001","11001","10101","10011","10001","10001","10001"],
	"O": ["01110","10001","10001","10001","10001","10001","01110"],
	"P": ["11110","10001","10001","11110","10000","10000","10000"],
	"Q": ["01110","10001","10001","10001","10101","10010","01101"],
	"R": ["11110","10001","10001","11110","10100","10010","10001"],
	"S": ["01111","10000","10000","01110","00001","00001","11110"],
	"T": ["11111","00100","00100","00100","00100","00100","00100"],
	"U": ["10001","10001","10001","10001","10001","10001","01110"],
	"V": ["10001","10001","10001","10001","01010","01010","00100"],
	"W": ["10001","10001","10001","10101","10101","11011","10001"],
	"X": ["10001","10001","01010","00100","01010","10001","10001"],
	"Y": ["10001","10001","01010","00100","00100","00100","00100"],
	"Z": ["11111","00001","00010","00100","01000","10000","11111"],
}

var tutorial_lines: Array[Dictionary] = [
	{"key": "WASD", "text": "MOVE", "type": "move"},
	{"key": "SPACE", "text": "JUMP", "type": "jump"},
	{"key": "SHIFT", "text": "SPRINT", "type": "sprint"},
	{"key": "LMB", "text": "ATTACK", "type": "attack"},
	{"key": "W + SPACE + LMB", "text": "UP ATTACK", "type": "up_attack"},
	{"key": "S + LMB", "text": "DOWN ATTACK", "type": "down_attack"},
	{"key": "TAB", "text": "TONGUE ATTACK", "type": "tongue"},
]

var current_index: int = 0
var visible_characters: int = 0
var typing_time: float = 0.0
var finished: bool = false

const TYPE_SPEED: float = 40.0


func _ready() -> void:
	visible = true
	set_process(true)
	set_process_input(true)
	queue_redraw()


func _process(delta: float) -> void:
	if finished:
		return

	var current_text: String = str(tutorial_lines[current_index]["text"])

	if visible_characters < current_text.length():
		typing_time += delta
		visible_characters = mini(
			int(typing_time * TYPE_SPEED),
			current_text.length()
		)

	queue_redraw()


func _input(event: InputEvent) -> void:
	if finished:
		return

	var tutorial_type: String = str(tutorial_lines[current_index]["type"])

	match tutorial_type:
		"move":
			if (
				event.is_action_pressed("ui_up")
				or event.is_action_pressed("ui_down")
				or event.is_action_pressed("ui_left")
				or event.is_action_pressed("ui_right")
			):
				_next_tutorial()

		"jump":
			if event.is_action_pressed("ui_accept"):
				_next_tutorial()

		"sprint":
			if event.is_action_pressed("sprint"):
				_next_tutorial()

		"attack":
			if event is InputEventMouseButton:
				var mouse_event := event as InputEventMouseButton
				if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
					_next_tutorial()

		"up_attack":
			if (
				Input.is_action_pressed("ui_up")
				and Input.is_action_pressed("ui_accept")
				and event is InputEventMouseButton
			):
				var mouse_event := event as InputEventMouseButton
				if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
					_next_tutorial()

		"down_attack":
			if (
				Input.is_action_pressed("ui_down")
				and event is InputEventMouseButton
			):
				var mouse_event := event as InputEventMouseButton
				if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
					_next_tutorial()

		"tongue":
			if event is InputEventKey:
				var key_event := event as InputEventKey
				if key_event.pressed and key_event.keycode == KEY_TAB:
					_next_tutorial()


func _next_tutorial() -> void:
	var current_text: String = str(
		tutorial_lines[current_index]["text"]
	)

	if visible_characters < current_text.length():
		visible_characters = current_text.length()
		queue_redraw()
		return

	current_index += 1
	typing_time = 0.0
	visible_characters = 0

	if current_index >= tutorial_lines.size():
		finished = true
		visible = false

	queue_redraw()


func _draw() -> void:
	if finished:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	var box_size := Vector2(600, 70)

	var box_pos := Vector2(
		(viewport_size.x - box_size.x) / 2.0,
		viewport_size.y - 130.0
	)

	draw_panel(box_pos, box_size)

	var key: String = str(tutorial_lines[current_index]["key"])
	var full_text: String = str(tutorial_lines[current_index]["text"])

	var shown_text := full_text.substr(
		0,
		visible_characters
	)

	draw_key_box(
		box_pos + Vector2(14, 15),
		key
	)

	draw_pixel_text(
		box_pos + Vector2(280, 28),
		shown_text,
		2,
		WHITE
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


func draw_key_box(pos: Vector2, key: String) -> void:
	var width: int = get_pixel_text_width(key, 2) + 20
	var size := Vector2(width, 36)

	draw_rect(Rect2(pos, size), SHADOW)

	draw_rect(
		Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)),
		FRAME_LIGHT
	)

	draw_rect(
		Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)),
		Color(0.110, 0.095, 0.070)
	)

	var text_width: int = get_pixel_text_width(key, 2)

	draw_pixel_text(
		pos + Vector2((width - text_width) / 2.0, 11),
		key,
		2,
		CREAM
	)


func draw_pixel_text(
	pos: Vector2,
	text: String,
	scale: int,
	color: Color
) -> void:

	var x_offset: int = 0

	for i in range(text.length()):
		var ch: String = text.substr(i, 1).to_upper()

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
		var ch: String = text.substr(i, 1).to_upper()

		if ch == " ":
			width += 4 * scale
		elif LETTERS.has(ch):
			var rows: Array = LETTERS[ch]
			width += (rows[0].length() + 1) * scale
		else:
			width += 4 * scale

	return width

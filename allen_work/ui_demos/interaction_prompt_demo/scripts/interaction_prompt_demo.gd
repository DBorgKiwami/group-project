extends Node2D

const SHADOW := Color(0.010, 0.012, 0.014)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)

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
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
}

@export var text_scale := 2
@export var height_above_player := 2.2

var time := 0.0
var confirm_time := 0.0
var current_label := "TALK"
var follow_target : Node3D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	visible = false


func show_prompt(label: String = "TALK", target: Node3D = null) -> void:
	current_label = label
	follow_target = target
	visible = true


func hide_prompt() -> void:
	visible = false


func flash_confirm() -> void:
	confirm_time = 0.18


func _process(delta: float) -> void:
	if not visible:
		return
	time += delta
	confirm_time = max(confirm_time - delta, 0.0)
	queue_redraw()


func _get_anchor_pos() -> Vector2:
	if follow_target:
		var camera := get_viewport().get_camera_3d()
		if camera:
			var world_pos := follow_target.global_position + Vector3(0, height_above_player, 0)
			var screen_pos := camera.unproject_position(world_pos)
			return screen_pos
	var size := get_viewport_rect().size
	return Vector2(size.x / 2.0, size.y - 96)


func _draw() -> void:
	draw_interaction_prompt(_get_anchor_pos())


func draw_interaction_prompt(pos: Vector2) -> void:
	var box_width := get_pixel_text_width(current_label, text_scale) + 40 * (text_scale / 1.0)
	var box_height := 24 * text_scale
	var box_pos := pos + Vector2(-box_width / 2, int(sin(time * 4.0) * 3.0) - box_height)
	var glow := 0.0
	if confirm_time > 0.0:
		glow = confirm_time * 2.5

	draw_prompt_box(box_pos, Vector2(box_width, box_height), glow)
	draw_key_box(box_pos + Vector2(6 * text_scale, 5 * text_scale), glow)
	draw_pixel_text(box_pos + Vector2(29 * text_scale, 8 * text_scale), current_label, text_scale, WHITE)
	draw_prompt_tail(box_pos + Vector2(box_width / 2 - 4 * text_scale, box_height - 2))


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

	var s := text_scale
	draw_rect(Rect2(pos, Vector2(17 * s, 14 * s)), SHADOW)
	draw_rect(Rect2(pos + Vector2(2 * s, 2 * s), Vector2(13 * s, 10 * s)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(4 * s, 4 * s), Vector2(9 * s, 6 * s)), fill)
	draw_pixel_text(pos + Vector2(7 * s, 4 * s), "X", s, CREAM)


func draw_prompt_tail(pos: Vector2) -> void:
	var s := text_scale
	var points := PackedVector2Array([pos, pos + Vector2(8 * s, 0), pos + Vector2(4 * s, 6 * s)])
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

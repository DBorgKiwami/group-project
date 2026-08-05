extends Node2D

const BG := Color(0.030, 0.050, 0.052)
const SHADOW := Color(0.010, 0.012, 0.014)
const FRAME := Color(0.350, 0.265, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PANEL := Color(0.085, 0.069, 0.055, 0.94)
const WHITE := Color(0.930, 0.945, 0.900)
const CREAM := Color(0.910, 0.790, 0.550)
const MUTED := Color(0.610, 0.690, 0.630)
const GREEN := Color(0.360, 0.720, 0.420)
const BLUE := Color(0.220, 0.620, 0.760)
const RED := Color(0.620, 0.140, 0.120)

const REWARDS := [
	{"label": "FOUND", "name": "LILY KEY", "icon": "key"},
	{"label": "FOUND", "name": "WATER GEM", "icon": "gem"},
	{"label": "NEW ITEM", "name": "OLD CHARM", "icon": "charm"},
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
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
}

var time := 0.0
var reward_index := 0
var popup_time := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	time += delta
	popup_time += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			popup_time = 0.0
		if event.keycode == KEY_LEFT:
			reward_index = (reward_index + REWARDS.size() - 1) % REWARDS.size()
			popup_time = 0.0
		if event.keycode == KEY_RIGHT:
			reward_index = (reward_index + 1) % REWARDS.size()
			popup_time = 0.0
		if event.keycode == KEY_R:
			reward_index = 0
			popup_time = 0.0


func _draw() -> void:
	draw_clean_background()
	draw_reward_popup()


func draw_clean_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), BG)


func draw_reward_popup() -> void:
	var alpha := get_popup_alpha()
	if alpha <= 0.0:
		return

	var y_offset := get_popup_y_offset()
	var popup_pos := Vector2(100, 76 + y_offset)
	var popup_size := Vector2(184, 64)
	var reward: Dictionary = REWARDS[reward_index]
	var label: String = reward["label"]
	var item_name: String = reward["name"]
	var icon_name: String = reward["icon"]

	draw_popup_box(popup_pos, popup_size, alpha)
	draw_icon_slot(popup_pos + Vector2(14, 12), icon_name, alpha)
	draw_pixel_text(popup_pos + Vector2(62, 14), label, 1, Color(CREAM.r, CREAM.g, CREAM.b, alpha))
	draw_pixel_text(popup_pos + Vector2(62, 32), item_name, 2, Color(WHITE.r, WHITE.g, WHITE.b, alpha))
	draw_small_sparkles(popup_pos, popup_size, alpha)


func get_popup_alpha() -> float:
	if popup_time < 0.12:
		return popup_time / 0.12
	if popup_time < 1.25:
		return 1.0
	if popup_time < 1.75:
		return 1.0 - (popup_time - 1.25) / 0.50
	return 0.0


func get_popup_y_offset() -> int:
	if popup_time < 0.12:
		return int(8.0 - popup_time / 0.12 * 8.0)
	return int(sin(time * 3.0) * 1.0)


func draw_popup_box(pos: Vector2, size: Vector2, alpha: float) -> void:
	draw_rect(Rect2(pos, size), Color(SHADOW.r, SHADOW.g, SHADOW.b, alpha))
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), Color(FRAME.r, FRAME.g, FRAME.b, alpha))
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), Color(FRAME_LIGHT.r, FRAME_LIGHT.g, FRAME_LIGHT.b, alpha))
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), Color(PANEL.r, PANEL.g, PANEL.b, alpha))


func draw_icon_slot(pos: Vector2, icon_name: String, alpha: float) -> void:
	draw_rect(Rect2(pos, Vector2(34, 34)), Color(SHADOW.r, SHADOW.g, SHADOW.b, alpha))
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(30, 30)), Color(FRAME.r, FRAME.g, FRAME.b, alpha))
	draw_rect(Rect2(pos + Vector2(4, 4), Vector2(26, 26)), Color(0.065, 0.075, 0.065, alpha))

	if icon_name == "key":
		draw_key_icon(pos + Vector2(8, 9), alpha)
	elif icon_name == "gem":
		draw_gem_icon(pos + Vector2(8, 6), alpha)
	else:
		draw_charm_icon(pos + Vector2(8, 7), alpha)


func draw_key_icon(pos: Vector2, alpha: float) -> void:
	draw_rect(Rect2(pos + Vector2(0, 6), Vector2(11, 8)), Color(CREAM.r, CREAM.g, CREAM.b, alpha))
	draw_rect(Rect2(pos + Vector2(3, 8), Vector2(5, 4)), Color(PANEL.r, PANEL.g, PANEL.b, alpha))
	draw_rect(Rect2(pos + Vector2(10, 9), Vector2(11, 3)), Color(CREAM.r, CREAM.g, CREAM.b, alpha))
	draw_rect(Rect2(pos + Vector2(18, 12), Vector2(3, 4)), Color(CREAM.r, CREAM.g, CREAM.b, alpha))


func draw_gem_icon(pos: Vector2, alpha: float) -> void:
	var points := PackedVector2Array([
		pos + Vector2(8, 0),
		pos + Vector2(18, 7),
		pos + Vector2(14, 20),
		pos + Vector2(2, 20),
		pos + Vector2(-2, 7),
	])
	draw_colored_polygon(points, Color(BLUE.r, BLUE.g, BLUE.b, alpha))
	draw_rect(Rect2(pos + Vector2(5, 5), Vector2(7, 3)), Color(WHITE.r, WHITE.g, WHITE.b, alpha * 0.75))


func draw_charm_icon(pos: Vector2, alpha: float) -> void:
	draw_rect(Rect2(pos + Vector2(4, 2), Vector2(12, 18)), Color(RED.r, RED.g, RED.b, alpha))
	draw_rect(Rect2(pos + Vector2(2, 6), Vector2(16, 8)), Color(RED.r, RED.g, RED.b, alpha))
	draw_rect(Rect2(pos + Vector2(7, 7), Vector2(6, 6)), Color(CREAM.r, CREAM.g, CREAM.b, alpha))
	draw_rect(Rect2(pos + Vector2(9, 20), Vector2(2, 5)), Color(FRAME_LIGHT.r, FRAME_LIGHT.g, FRAME_LIGHT.b, alpha))


func draw_small_sparkles(pos: Vector2, size: Vector2, alpha: float) -> void:
	var sparkle_alpha := (0.45 + sin(time * 7.0) * 0.25) * alpha
	draw_rect(Rect2(pos + Vector2(size.x - 22, 12), Vector2(3, 3)), Color(CREAM.r, CREAM.g, CREAM.b, sparkle_alpha))
	draw_rect(Rect2(pos + Vector2(size.x - 16, 18), Vector2(2, 2)), Color(CREAM.r, CREAM.g, CREAM.b, sparkle_alpha))
	draw_rect(Rect2(pos + Vector2(10, size.y - 16), Vector2(2, 2)), Color(CREAM.r, CREAM.g, CREAM.b, sparkle_alpha))


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

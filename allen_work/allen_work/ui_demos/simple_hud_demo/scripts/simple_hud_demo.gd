extends Node2D

const PLAYER_PORTRAIT := preload("res://allen_work/ui_demos/simple_hud_demo/assets/ui/player_portrait.png")

const BG := Color(0.020, 0.035, 0.048)
const TILE := Color(0.060, 0.090, 0.110)
const DARK := Color(0.035, 0.043, 0.058)
const FRAME := Color(0.380, 0.280, 0.160)
const FRAME_LIGHT := Color(0.690, 0.560, 0.340)
const PANEL := Color(0.120, 0.145, 0.175)
const PORTRAIT_BG := Color(0.210, 0.340, 0.390)
const HEART_RED := Color(0.920, 0.120, 0.150)
const HEART_EMPTY := Color(0.150, 0.085, 0.095)
const HEART_LIGHT := Color(1.000, 0.470, 0.500)

const MAX_HEALTH := 5
const FLASH_TIME := 0.22
const HEART_ROWS := [
	"01100110",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100",
	"00011000",
]

var health := MAX_HEALTH
var flash_time := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	if flash_time > 0.0:
		flash_time = maxf(flash_time - delta, 0.0)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			take_hit()


func take_hit() -> void:
	if health > 0:
		health -= 1
		flash_time = FLASH_TIME


func _draw() -> void:
	draw_demo_background()
	draw_hud_panel()


func draw_demo_background() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)


func draw_hud_panel() -> void:
	var pos := Vector2(8, 8)
	draw_panel(pos, Vector2(230, 66))
	draw_portrait(pos + Vector2(12, 11))
	draw_hearts(pos + Vector2(72, 26))


func draw_panel(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)), FRAME)
	draw_rect(Rect2(pos + Vector2(4, 4), size - Vector2(8, 8)), FRAME_LIGHT)
	draw_rect(Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)), PANEL)


func draw_portrait(pos: Vector2) -> void:
	draw_rect(Rect2(pos, Vector2(43, 44)), DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(39, 40)), PORTRAIT_BG)
	draw_texture_rect(PLAYER_PORTRAIT, Rect2(pos + Vector2(3, 2), Vector2(37, 40)), false)

	if flash_time > 0.0:
		var alpha := 0.42 * (flash_time / FLASH_TIME)
		draw_rect(Rect2(pos + Vector2(2, 2), Vector2(39, 40)), Color(1.0, 0.05, 0.05, alpha))


func draw_hearts(pos: Vector2) -> void:
	for i in range(MAX_HEALTH):
		var heart_pos := pos + Vector2(i * 29, 0)
		draw_heart(heart_pos, i < health)


func draw_heart(pos: Vector2, is_full: bool) -> void:
	var fill_color := HEART_RED if is_full else HEART_EMPTY
	draw_heart_pixels(pos + Vector2(-2, 0), DARK)
	draw_heart_pixels(pos + Vector2(2, 0), DARK)
	draw_heart_pixels(pos + Vector2(0, -2), DARK)
	draw_heart_pixels(pos + Vector2(0, 2), DARK)
	draw_heart_pixels(pos, fill_color)

	if is_full:
		draw_rect(Rect2(pos + Vector2(6, 6), Vector2(6, 3)), HEART_LIGHT)


func draw_heart_pixels(pos: Vector2, color: Color) -> void:
	var pixel_size := 3
	for y in range(HEART_ROWS.size()):
		var row: String = HEART_ROWS[y]
		for x in range(row.length()):
			if row.substr(x, 1) == "1":
				draw_rect(Rect2(pos + Vector2(x * pixel_size, y * pixel_size), Vector2(pixel_size, pixel_size)), color)

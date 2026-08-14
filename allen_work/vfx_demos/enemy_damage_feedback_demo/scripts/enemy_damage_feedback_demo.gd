extends Node2D

const BG := Color(0.025, 0.040, 0.042)
const TILE := Color(0.045, 0.065, 0.064)
const DARK := Color(0.030, 0.035, 0.045)
const SHADOW := Color(0.010, 0.012, 0.014)
const HIT_RED := Color(1.000, 0.090, 0.070)
const DAMAGE_WHITE := Color(1.000, 0.930, 0.760)
const DAMAGE_RED := Color(0.950, 0.080, 0.080)
const HEART_RED := Color(0.920, 0.120, 0.150)
const HEART_EMPTY := Color(0.150, 0.085, 0.095)
const HEART_LIGHT := Color(1.000, 0.470, 0.500)

const MAX_HEALTH := 5
const FLASH_TIME := 0.18
const DAMAGE_TEXT_TIME := 0.55

const HEART_ROWS := [
	"01100110",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100",
	"00011000",
]

const NUMBER_ROWS := {
	"-": ["000", "000", "111", "000", "000"],
	"0": ["111", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"],
	"5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"],
	"7": ["111", "001", "010", "010", "010"],
	"8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"],
}

var enemy_health := MAX_HEALTH
var enemy_flash_time := 0.0
var damage_text_time := 0.0
var hit_spark_time := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	if enemy_flash_time > 0.0:
		enemy_flash_time = maxf(enemy_flash_time - delta, 0.0)
	if damage_text_time > 0.0:
		damage_text_time = maxf(damage_text_time - delta, 0.0)
	if hit_spark_time > 0.0:
		hit_spark_time = maxf(hit_spark_time - delta, 0.0)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			hit_enemy()
		if event.keycode == KEY_R:
			reset_enemy()


func hit_enemy() -> void:
	if enemy_health <= 0:
		return

	enemy_health -= 1
	enemy_flash_time = FLASH_TIME
	damage_text_time = DAMAGE_TEXT_TIME
	hit_spark_time = 0.16


func reset_enemy() -> void:
	enemy_health = MAX_HEALTH
	enemy_flash_time = 0.0
	damage_text_time = 0.0
	hit_spark_time = 0.0


func _draw() -> void:
	draw_background()
	draw_hit_feedback(Vector2(192, 128))
	draw_enemy_hearts(Vector2(122, 44))
	draw_damage_number(Vector2(192, 94))


func draw_background() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), TILE)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), TILE)


func draw_hit_feedback(center: Vector2) -> void:
	if hit_spark_time > 0.0:
		var spark_alpha := hit_spark_time / 0.16
		draw_hit_sparks(center, spark_alpha)


func draw_hit_sparks(pos: Vector2, alpha: float) -> void:
	var white := Color(DAMAGE_WHITE.r, DAMAGE_WHITE.g, DAMAGE_WHITE.b, alpha)
	var red := Color(DAMAGE_RED.r, DAMAGE_RED.g, DAMAGE_RED.b, alpha)
	draw_rect(Rect2(pos + Vector2(-20, -4), Vector2(40, 8)), Color(HIT_RED.r, HIT_RED.g, HIT_RED.b, 0.20 * alpha))
	draw_rect(Rect2(pos + Vector2(-8, -2), Vector2(28, 4)), white)
	draw_rect(Rect2(pos + Vector2(-2, -14), Vector2(4, 28)), red)
	draw_rect(Rect2(pos + Vector2(12, -12), Vector2(6, 6)), white)
	draw_rect(Rect2(pos + Vector2(-18, 10), Vector2(6, 6)), red)


func draw_enemy_hearts(pos: Vector2) -> void:
	for i in range(MAX_HEALTH):
		draw_heart(pos + Vector2(i * 29, 0), i < enemy_health)


func draw_heart(pos: Vector2, is_full: bool) -> void:
	var fill := HEART_RED if is_full else HEART_EMPTY
	draw_heart_pixels(pos + Vector2(-2, 0), DARK)
	draw_heart_pixels(pos + Vector2(2, 0), DARK)
	draw_heart_pixels(pos + Vector2(0, -2), DARK)
	draw_heart_pixels(pos + Vector2(0, 2), DARK)
	draw_heart_pixels(pos, fill)

	if is_full:
		draw_rect(Rect2(pos + Vector2(6, 6), Vector2(6, 3)), HEART_LIGHT)


func draw_heart_pixels(pos: Vector2, color: Color) -> void:
	var pixel_size := 3
	for y in range(HEART_ROWS.size()):
		var row: String = HEART_ROWS[y]
		for x in range(row.length()):
			if row.substr(x, 1) == "1":
				draw_rect(Rect2(pos + Vector2(x * pixel_size, y * pixel_size), Vector2(pixel_size, pixel_size)), color)


func draw_damage_number(center: Vector2) -> void:
	if damage_text_time <= 0.0:
		return

	var progress := 1.0 - damage_text_time / DAMAGE_TEXT_TIME
	var y_offset := -22.0 * progress
	var alpha := 1.0
	if progress > 0.65:
		alpha = 1.0 - (progress - 0.65) / 0.35

	var pos := center + Vector2(-14, y_offset)
	draw_pixel_number(pos + Vector2(2, 2), "-1", 3, Color(SHADOW.r, SHADOW.g, SHADOW.b, alpha))
	draw_pixel_number(pos, "-1", 3, Color(DAMAGE_RED.r, DAMAGE_RED.g, DAMAGE_RED.b, alpha))
	draw_pixel_number(pos + Vector2(3, 3), "-1", 1, Color(DAMAGE_WHITE.r, DAMAGE_WHITE.g, DAMAGE_WHITE.b, alpha))


func draw_pixel_number(pos: Vector2, text: String, scale: int, color: Color) -> void:
	var x_offset := 0
	for i in range(text.length()):
		var ch := text.substr(i, 1)
		if not NUMBER_ROWS.has(ch):
			x_offset += 4 * scale
			continue

		var rows: Array = NUMBER_ROWS[ch]
		for y in range(rows.size()):
			var row: String = rows[y]
			for x in range(row.length()):
				if row.substr(x, 1) == "1":
					draw_rect(Rect2(pos + Vector2(x_offset + x * scale, y * scale), Vector2(scale, scale)), color)
		x_offset += 4 * scale

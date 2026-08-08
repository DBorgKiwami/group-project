extends Node2D

const PLAYER_TEXTURE := preload("res://allen_work/vfx_demos/tongue_snap_demo/assets/player_reference.png")
const PLAYER_MOUTH_OPEN_TEXTURE := preload("res://allen_work/vfx_demos/tongue_snap_demo/assets/player_reference_mouth_open.png")

var player_pos := Vector2(48, 60)
var mouth_pos := Vector2(90, 120)
var target_pos := Vector2(286, 90)

var is_playing := false
var timer := 0.0
var total_time := 0.55
var droplets := []


func _ready() -> void:
	randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	start_tongue()


func _process(delta: float) -> void:
	if is_playing:
		timer += delta
		if timer > total_time:
			is_playing = false

	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			target_pos = Vector2(286, 90)
			start_tongue()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			target_pos = get_global_mouse_position()
			start_tongue()


func start_tongue() -> void:
	is_playing = true
	timer = 0.0
	make_droplets()


func make_droplets() -> void:
	droplets.clear()
	for i in range(12):
		var droplet = {
			"offset": Vector2(randf_range(-8, 8), randf_range(-6, 6)),
			"speed": Vector2(randf_range(-42, 42), randf_range(-34, 16)),
			"size": randi_range(1, 2)
		}
		droplets.append(droplet)


func _draw() -> void:
	draw_background()
	draw_player()
	draw_target_point()

	if is_playing:
		draw_tongue()


func draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.015, 0.027, 0.052))

	for x in range(0, 384, 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, 216)), Color(0.035, 0.105, 0.135, 0.45))
	for y in range(0, 216, 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(384, 1)), Color(0.035, 0.105, 0.135, 0.45))


func draw_player() -> void:
	if is_mouth_open():
		draw_texture(PLAYER_MOUTH_OPEN_TEXTURE, player_pos)
	else:
		draw_texture(PLAYER_TEXTURE, player_pos)


func is_mouth_open() -> bool:
	return is_playing and timer < 0.38


func draw_target_point() -> void:
	draw_rect(Rect2(target_pos + Vector2(-5, -5), Vector2(10, 10)), Color(0.95, 0.45, 0.52, 0.35))


func draw_tongue() -> void:
	var extend_amount := get_extend_amount()
	var tip_pos := mouth_pos.lerp(target_pos, extend_amount)

	draw_line(mouth_pos, tip_pos, Color(0.03, 0.08, 0.11, 0.90), 9.0)
	draw_line(mouth_pos, tip_pos, Color(0.62, 0.13, 0.17, 1.0), 6.0)
	draw_line(mouth_pos, tip_pos, Color(0.96, 0.43, 0.52, 1.0), 4.0)
	draw_line(mouth_pos + Vector2(0, -1), tip_pos + Vector2(0, -1), Color(1.0, 0.72, 0.78, 0.85), 2.0)

	if timer > 0.08 and timer < 0.34:
		draw_sticky_hit()

	if timer > 0.12:
		draw_droplets()


func get_extend_amount() -> float:
	if timer < 0.11:
		return timer / 0.11

	if timer < 0.22:
		return 1.0

	if timer < 0.38:
		return 1.0 - ((timer - 0.22) / 0.16)

	return 0.0


func draw_sticky_hit() -> void:
	var hit_fade := 1.0
	if timer > 0.22:
		hit_fade = 1.0 - ((timer - 0.22) / 0.12)

	draw_rect(Rect2(target_pos + Vector2(-10, -5), Vector2(20, 10)), Color(0.95, 0.33, 0.43, 0.75 * hit_fade))
	draw_rect(Rect2(target_pos + Vector2(-5, -10), Vector2(11, 20)), Color(1.0, 0.55, 0.62, 0.55 * hit_fade))
	draw_rect(Rect2(target_pos + Vector2(-2, -2), Vector2(4, 4)), Color(1.0, 0.86, 0.86, 0.90 * hit_fade))
	draw_rect(Rect2(target_pos + Vector2(9, -1), Vector2(7, 2)), Color(1.0, 0.72, 0.78, 0.65 * hit_fade))
	draw_rect(Rect2(target_pos + Vector2(-16, -1), Vector2(7, 2)), Color(1.0, 0.72, 0.78, 0.65 * hit_fade))


func draw_droplets() -> void:
	var t := (timer - 0.12) / 0.32
	t = clampf(t, 0.0, 1.0)

	for droplet in droplets:
		var offset: Vector2 = droplet["offset"]
		var speed: Vector2 = droplet["speed"]
		var size: int = droplet["size"]
		var pos := target_pos + offset + speed * t
		var alpha := 1.0 - t
		var color := Color(0.96, 0.38, 0.48, alpha)
		if size == 2:
			color = Color(1.0, 0.68, 0.74, alpha)
		draw_rect(Rect2(pos.floor(), Vector2(size, size)), color)

extends Node2D

const SlashArcVFX := preload("res://scripts/slash_arc_vfx.gd")

const BG := Color(0.015, 0.027, 0.052)
const GRID := Color(0.035, 0.105, 0.135)
const GUIDE := Color(0.150, 0.480, 0.520)

var _shake_time := 0.0
var _shake_strength := 0.0
var _auto_timer := 0.55
var _last_slash_position := Vector2.ZERO


func _ready() -> void:
	randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	get_viewport().size_changed.connect(queue_redraw)
	set_process(true)


func _process(delta: float) -> void:
	_auto_timer -= delta
	if _auto_timer <= 0.0:
		_auto_timer = 1.35
		_spawn_center_slash()

	if _shake_time > 0.0:
		_shake_time -= delta
		var strength := _shake_strength * maxf(_shake_time / 0.10, 0.0)
		position = Vector2(roundf(randf_range(-strength, strength)), roundf(randf_range(-strength, strength)))
	else:
		position = Vector2.ZERO

	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos := get_global_mouse_position()
		_spawn_slash(mouse_pos, Vector2.RIGHT)

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_spawn_center_slash()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	_draw_pixel_grid(size)
	_draw_origin_marker(_demo_slash_position())

	if _last_slash_position != Vector2.ZERO:
		_draw_origin_marker(_last_slash_position)


func _spawn_slash(world_position: Vector2, direction: Vector2) -> void:
	var slash := SlashArcVFX.new()
	add_child(slash)
	slash.global_position = world_position
	slash.rotation = direction.angle()
	slash.trigger()
	_last_slash_position = world_position

	_shake_time = 0.12
	_shake_strength = 2.0


func _spawn_center_slash() -> void:
	_spawn_slash(_demo_slash_position(), Vector2.RIGHT)


func _demo_slash_position() -> Vector2:
	return get_viewport_rect().size * 0.5


func _draw_pixel_grid(size: Vector2) -> void:
	var grid_color := GRID
	grid_color.a = 0.45
	for x in range(0, int(size.x), 24):
		draw_rect(Rect2(Vector2(x, 0), Vector2(1, size.y)), grid_color)
	for y in range(0, int(size.y), 24):
		draw_rect(Rect2(Vector2(0, y), Vector2(size.x, 1)), grid_color)

	var center := size * 0.5
	var guide_color := GUIDE
	guide_color.a = 0.45
	draw_rect(Rect2(Vector2(0, center.y), Vector2(size.x, 1)), guide_color)
	draw_rect(Rect2(Vector2(center.x, 0), Vector2(1, size.y)), guide_color)


func _draw_origin_marker(position: Vector2) -> void:
	var color := Color(0.92, 1.0, 1.0, 0.35)
	draw_rect(Rect2(position + Vector2(-5, 0), Vector2(10, 1)), color)
	draw_rect(Rect2(position + Vector2(0, -5), Vector2(1, 10)), color)

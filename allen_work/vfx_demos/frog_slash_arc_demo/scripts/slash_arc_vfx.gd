extends Node2D

const SLASH_SHEET := preload("res://allen_work/vfx_demos/frog_slash_arc_demo/assets/vfx/slash_arc_sheet.png")
const FRAME_SIZE := Vector2(64.0, 64.0)

@export var frame_count := 6
@export var frame_time := 0.045
@export var lifetime := 0.34

var _elapsed := 0.0
var _shards: Array[Dictionary] = []


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 20


func trigger() -> void:
	_elapsed = 0.0
	_make_shards()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()
	queue_redraw()


func _draw() -> void:
	_draw_slash_frame()
	_draw_hit_pixels()
	_draw_shards()


func _draw_slash_frame() -> void:
	var frame := clampi(int(_elapsed / frame_time), 0, frame_count - 1)
	var fade_start := 0.22
	var alpha := 1.0 - clampf((_elapsed - fade_start) / maxf(lifetime - fade_start, 0.001), 0.0, 1.0)
	var source := Rect2(Vector2(float(frame) * FRAME_SIZE.x, 0.0), FRAME_SIZE)
	var target := Rect2(Vector2(-50.0, -50.0), Vector2(100.0, 100.0))
	draw_texture_rect_region(SLASH_SHEET, target, source, Color(1.0, 1.0, 1.0, alpha))


func _draw_hit_pixels() -> void:
	if _elapsed > 0.13:
		return

	var alpha := 1.0 - _elapsed / 0.13
	var white := Color(0.9, 1.0, 1.0, alpha)
	var red := Color(1.0, 0.2, 0.28, alpha)
	draw_rect(Rect2(Vector2(0, -1), Vector2(8, 2)), white)
	draw_rect(Rect2(Vector2(3, -5), Vector2(2, 10)), white)
	draw_rect(Rect2(Vector2(8, -3), Vector2(4, 2)), red)
	draw_rect(Rect2(Vector2(-5, 3), Vector2(4, 2)), red)


func _make_shards() -> void:
	_shards.clear()
	for i in range(24):
		var angle := randf_range(deg_to_rad(-52.0), deg_to_rad(48.0))
		var origin := Vector2.RIGHT.rotated(angle) * randf_range(14.0, 32.0)
		var velocity := Vector2.RIGHT.rotated(angle + randf_range(-0.30, 0.30)) * randf_range(38.0, 92.0)
		var color := Color(0.30, 0.90, 1.0, 1.0)
		if i % 3 == 0:
			color = Color(1.0, 0.22, 0.30, 1.0)
		elif i % 4 == 0:
			color = Color(0.92, 1.0, 1.0, 1.0)

		_shards.append({
			"origin": origin,
			"velocity": velocity,
			"size": randi_range(1, 3),
			"color": color
		})


func _draw_shards() -> void:
	var shard_progress := clampf((_elapsed - 0.055) / maxf(lifetime - 0.055, 0.001), 0.0, 1.0)
	if shard_progress <= 0.0:
		return

	for shard in _shards:
		var origin: Vector2 = shard["origin"]
		var velocity: Vector2 = shard["velocity"]
		var size: int = shard["size"]
		var color: Color = shard["color"]
		var pos := (origin + velocity * shard_progress).floor()
		var fade := 1.0 - shard_progress

		color.a = 0.9 * fade
		draw_rect(Rect2(pos, Vector2(size, size)), color)

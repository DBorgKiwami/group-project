extends Node

@export var audio_player: AudioStreamPlayer3D
@export var water_audio_player: AudioStreamPlayer3D
@export var lotus_audio_player: AudioStreamPlayer3D
@export var grass_audio_player: AudioStreamPlayer3D
@export var sprite: AnimatedSprite3D
@export_range(0.1, 1.0, 0.01) var step_interval := 0.4
@export_range(0.0, 0.15, 0.01) var pitch_variation := 0.03

# The imported pond water is visual-only geometry, so it cannot be found with
# a physics ray. These 16 small triangles are its X/Z footprint, extracted once
# from redlance_pondside_blender_level_base.glb instead of reading mesh data at
# runtime. The player's origin is about 0.7 m above its feet.
const POND_WATER_PLAYER_MAX_Y := 0.1
const POND_WATER_TRIANGLES := [
	[Vector2(-7.456249, -13.998276), Vector2(-5.456249, 26.001723), Vector2(10.543750, 36.001723)],
	[Vector2(10.543750, 36.001723), Vector2(28.043750, 31.001723), Vector2(35.043751, 12.001725)],
	[Vector2(35.043751, 12.001725), Vector2(30.543750, -7.998276), Vector2(16.043751, -10.998276)],
	[Vector2(16.043751, -10.998276), Vector2(5.543751, -21.998276), Vector2(-7.456249, -13.998276)],
	[Vector2(-7.456249, -13.998276), Vector2(10.543750, 36.001723), Vector2(35.043751, 12.001725)],
	[Vector2(35.043751, 12.001725), Vector2(16.043751, -10.998276), Vector2(-7.456249, -13.998276)],
	[Vector2(-8.956249, 12.001725), Vector2(-7.456249, 52.001722), Vector2(19.043751, 60.001724)],
	[Vector2(19.043751, 60.001724), Vector2(49.043752, 53.001726), Vector2(56.543752, 28.001724)],
	[Vector2(56.543752, 28.001724), Vector2(52.543751, -17.998275), Vector2(40.043751, -27.998275)],
	[Vector2(29.543751, -23.998277), Vector2(23.043750, -42.998278), Vector2(6.043751, -47.998278)],
	[Vector2(56.543752, 28.001724), Vector2(40.043751, -27.998275), Vector2(29.543751, -23.998277)],
	[Vector2(-8.956249, 12.001725), Vector2(19.043751, 60.001724), Vector2(56.543752, 28.001724)],
	[Vector2(-7.456249, -37.998275), Vector2(-12.956249, -13.998276), Vector2(-8.956249, 12.001725)],
	[Vector2(29.543751, -23.998277), Vector2(6.043751, -47.998278), Vector2(-7.456249, -37.998275)],
	[Vector2(-8.956249, 12.001725), Vector2(56.543752, 28.001724), Vector2(29.543751, -23.998277)],
	[Vector2(29.543751, -23.998277), Vector2(-7.456249, -37.998275), Vector2(-8.956249, 12.001725)],
]

@onready var player: Player3D = get_parent() as Player3D

var _time_until_next_step := 0.0
var _was_walking := false
var _high_step := false
var _forced_grass_surfaces: Array[VisualInstance3D] = []


func _process(delta: float) -> void:
	if player == null or audio_player == null or sprite == null:
		return

	var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	var is_walking := (
		horizontal_speed > 0.1
		and player.is_on_floor()
		and not player.grappling
		and String(sprite.animation).to_lower().ends_with("walk")
	)

	if not is_walking:
		_was_walking = false
		_time_until_next_step = 0.0
		return

	if not _was_walking:
		_was_walking = true
		_play_step()
		_time_until_next_step = _current_step_interval()
		return

	_time_until_next_step -= delta
	if _time_until_next_step <= 0.0:
		_play_step()
		_time_until_next_step += _current_step_interval()


func _current_step_interval() -> float:
	# The walk sprites animate faster while sprinting, so the sound cadence follows
	# the visible foot motion instead of remaining at the normal walking tempo.
	return step_interval / maxf(sprite.speed_scale, 0.1)


func _play_step() -> void:
	var active_audio_player := _get_surface_audio_player()
	if active_audio_player == null:
		return

	var pitch_offset := pitch_variation if _high_step else -pitch_variation
	active_audio_player.pitch_scale = 1.0 + pitch_offset
	_high_step = not _high_step
	active_audio_player.play()


func play_surface_step() -> void:
	_play_step()
	_was_walking = true
	_time_until_next_step = _current_step_interval()


func set_forced_grass_surfaces(surfaces: Array[Node3D]) -> void:
	_forced_grass_surfaces.clear()
	for surface in surfaces:
		if surface is VisualInstance3D:
			_forced_grass_surfaces.append(surface as VisualInstance3D)


func _get_surface_audio_player() -> AudioStreamPlayer3D:
	var surface_kind := _surface_below_player()
	if surface_kind == &"lotus" and lotus_audio_player != null:
		return lotus_audio_player
	if surface_kind == &"grass" and grass_audio_player != null:
		return grass_audio_player
	if surface_kind == &"water" and water_audio_player != null:
		return water_audio_player
	return audio_player


func _surface_below_player() -> StringName:
	# Some imported review-level lily meshes create their physics bodies at
	# runtime. Their mesh bounds are the authoritative grass regions, so check
	# them before the generic pond/water fallback can override the result.
	if _is_over_forced_grass_surface():
		return &"grass"

	# Hand-authored pond geometry can opt in through groups. Imported Blender/GLB
	# geometry is identified from node names such as Lily_Pad_* and Pond_Water_*.
	var grouped_surface := _surface_from_groups()
	if grouped_surface != &"ground":
		return grouped_surface

	var collision_surface := _surface_from_floor_collision()
	if collision_surface != &"ground":
		return collision_surface

	var query := PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP * 0.2,
		player.global_position + Vector3.DOWN * 1.5,
		player.collision_mask,
		[player.get_rid()]
	)
	query.hit_from_inside = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return &"water" if _is_in_pond_water() else &"ground"

	var collider := hit.get("collider") as Node
	var surface_kind := _surface_from_node(collider)
	if surface_kind == &"lotus" or surface_kind == &"grass":
		return surface_kind

	if _is_in_pond_water():
		return &"water"

	if surface_kind != &"ground":
		return surface_kind

	if collider is CollisionObject3D:
		var collision_object := collider as CollisionObject3D
		var shape_index := int(hit.get("shape", -1))
		if shape_index >= 0:
			var owner_id := collision_object.shape_find_owner(shape_index)
			if owner_id >= 0:
				return _surface_from_node(
					collision_object.shape_owner_get_owner(owner_id) as Node
				)

	return &"ground"


func _is_over_forced_grass_surface() -> bool:
	return is_position_over_forced_grass_surface(player.global_position)


func is_position_over_forced_grass_surface(world_position: Vector3) -> bool:
	for surface in _forced_grass_surfaces:
		if not is_instance_valid(surface):
			continue
		var bounds := _world_aabb_for_surface(surface).grow(0.25)
		var bounds_end := bounds.position + bounds.size
		if (
			world_position.x >= bounds.position.x
			and world_position.x <= bounds_end.x
			and world_position.z >= bounds.position.z
			and world_position.z <= bounds_end.z
		):
			return true
	return false


func _world_aabb_for_surface(surface: VisualInstance3D) -> AABB:
	var local_bounds := surface.get_aabb()
	var local_end := local_bounds.position + local_bounds.size
	var corners := [
		Vector3(local_bounds.position.x, local_bounds.position.y, local_bounds.position.z),
		Vector3(local_end.x, local_bounds.position.y, local_bounds.position.z),
		Vector3(local_bounds.position.x, local_end.y, local_bounds.position.z),
		Vector3(local_end.x, local_end.y, local_bounds.position.z),
		Vector3(local_bounds.position.x, local_bounds.position.y, local_end.z),
		Vector3(local_end.x, local_bounds.position.y, local_end.z),
		Vector3(local_bounds.position.x, local_end.y, local_end.z),
		Vector3(local_end.x, local_end.y, local_end.z),
	]
	var world_min: Vector3 = surface.global_transform * corners[0]
	var world_max := world_min
	for corner in corners:
		var world_corner: Vector3 = surface.global_transform * corner
		world_min = Vector3(
			minf(world_min.x, world_corner.x),
			minf(world_min.y, world_corner.y),
			minf(world_min.z, world_corner.z)
		)
		world_max = Vector3(
			maxf(world_max.x, world_corner.x),
			maxf(world_max.y, world_corner.y),
			maxf(world_max.z, world_corner.z)
		)
	return AABB(world_min, world_max - world_min)


func _surface_from_floor_collision() -> StringName:
	for collision_index in range(player.get_slide_collision_count()):
		var collision := player.get_slide_collision(collision_index)
		if collision.get_normal().dot(Vector3.UP) < 0.5:
			continue
		var surface_kind := _surface_from_node(collision.get_collider() as Node)
		if surface_kind != &"ground":
			return surface_kind
	return &"ground"


func _is_in_pond_water() -> bool:
	if player.global_position.y > POND_WATER_PLAYER_MAX_Y:
		return false
	var player_point := Vector2(player.global_position.x, player.global_position.z)
	for triangle in POND_WATER_TRIANGLES:
		if _point_in_triangle(player_point, triangle[0], triangle[1], triangle[2]):
			return true
	return false


func _point_in_triangle(
	point: Vector2,
	a: Vector2,
	b: Vector2,
	c: Vector2
) -> bool:
	var sign_ab := _triangle_sign(point, a, b)
	var sign_bc := _triangle_sign(point, b, c)
	var sign_ca := _triangle_sign(point, c, a)
	var has_negative := sign_ab < 0.0 or sign_bc < 0.0 or sign_ca < 0.0
	var has_positive := sign_ab > 0.0 or sign_bc > 0.0 or sign_ca > 0.0
	return not (has_negative and has_positive)


func _triangle_sign(point_a: Vector2, point_b: Vector2, point_c: Vector2) -> float:
	return (
		(point_a.x - point_c.x) * (point_b.y - point_c.y)
		- (point_b.x - point_c.x) * (point_a.y - point_c.y)
	)


func _surface_from_groups() -> StringName:
	# Lotus leaves overlap the pond, so they must take priority over water.
	if _is_inside_surface_group(&"footstep_lotus"):
		return &"lotus"
	if _is_inside_surface_group(&"footstep_grass"):
		return &"grass"
	if _is_inside_surface_group(&"footstep_water"):
		return &"water"
	return &"ground"


func _surface_from_node(node: Node) -> StringName:
	var current := node
	for _index in range(5):
		if current == null:
			break
		if current.is_in_group(&"footstep_lotus"):
			return &"lotus"
		if current.is_in_group(&"footstep_grass"):
			return &"grass"
		if current.is_in_group(&"footstep_water"):
			return &"water"

		var surface_name := String(current.name).to_lower()
		if "lily" in surface_name or "lotus" in surface_name:
			return &"lotus"
		if "water" in surface_name or "pond" in surface_name:
			return &"water"
		current = current.get_parent()
	return &"ground"


func _is_inside_surface_group(group_name: StringName) -> bool:
	for surface in get_tree().get_nodes_in_group(group_name):
		if surface is Node3D:
			var local_position := (surface as Node3D).to_local(player.global_position)
			if Vector2(local_position.x, local_position.z).length_squared() <= 1.0:
				return true
	return false

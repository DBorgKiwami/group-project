extends Node3D

const GROUND_STEP_SOUND := preload("res://audio/music/step.ogg")
const GRASS_STEP_SOUND := preload("res://audio/music/stepongrass.ogg")
const GRASS_MATERIAL := preload("res://sprites/textures/leaf.tres")
const LOTUS_PROP_ROOT_NAMES: Array[StringName] = [
	&"LotusAndLilypads",
	&"LotusAndLilypads005",
	&"LotusAndLilypads004",
	&"LotusAndLilypads001_RedCircle",
	&"LotusAndLilypads003",
]
const STONE_PROP_ROOT_NAME := &"WeedsAndStones"
const GENERATED_COLLISION_BODY_NAME := &"GeneratedPondPropBody"

@export var add_simple_collision := true
@export var snap_player_to_spawn := true
@export var use_preview_camera := false

@onready var level_base: Node3D = $LevelBase
@onready var player: Node3D = $"3Dplatformingcharacter"
@onready var footstep_controller: Node = player.get_node("FootstepController")
@onready var regular_footstep_audio: AudioStreamPlayer3D = player.get_node("FootstepAudio")
@onready var water_footstep_audio: AudioStreamPlayer3D = player.get_node("WaterFootstepAudio")
@onready var landing_audio: AudioStreamPlayer3D = player.get_node("LandingSfx2")
@onready var grass_footstep_audio: AudioStreamPlayer3D = player.get_node("GrassFootstepAudio")

var _grass_surfaces: Array[Node3D] = []

func _ready() -> void:
	grass_footstep_audio.stream = GRASS_STEP_SOUND
	water_footstep_audio.stream = GROUND_STEP_SOUND
	water_footstep_audio.volume_db = -10.0
	_grass_surfaces.clear()
	if add_simple_collision:
		add_collision(level_base)
		_add_pond_prop_collisions()
	collect_grass_visuals(self)
	if footstep_controller.has_method("set_forced_grass_surfaces"):
		footstep_controller.set_forced_grass_surfaces(_grass_surfaces)
	_enforce_grass_audio()


func _process(_delta: float) -> void:
	_enforce_grass_audio()


func _enforce_grass_audio() -> void:
	var on_grass: bool = footstep_controller.is_position_over_forced_grass_surface(
		player.global_position
	)
	var required_stream: AudioStream = GRASS_STEP_SOUND if on_grass else GROUND_STEP_SOUND
	_set_audio_stream(regular_footstep_audio, required_stream)
	_set_audio_stream(water_footstep_audio, required_stream)
	_set_audio_stream(landing_audio, required_stream)


func _set_audio_stream(audio_player: AudioStreamPlayer3D, required_stream: AudioStream) -> void:
	if audio_player.stream == required_stream:
		return
	if audio_player.playing:
		audio_player.stop()
	audio_player.stream = required_stream
	if snap_player_to_spawn:
		call_deferred("_snap_player_to_ground")


func _snap_player_to_ground() -> void:
	await get_tree().physics_frame
	if player == null:
		return

	var ray_start: Vector3 = player.global_position + Vector3.UP * 4.0
	var ray_end: Vector3 = player.global_position + Vector3.DOWN * 6.0
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return

	var ground_position: Vector3 = hit["position"]
	player.global_position.y = ground_position.y + 0.62
	if player is CharacterBody3D:
		(player as CharacterBody3D).velocity = Vector3.ZERO


func add_collision(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_name := String(child.name).to_lower()
			var is_backdrop_rock: bool = String(child.get_path()).to_lower().contains("optional_backdrop_rock_walls")
			if should_make_solid(mesh_name) and not is_backdrop_rock and has_geometry(child) and not has_collision(child):
				child.create_trimesh_collision()
			if mesh_name.contains("lily"):
				child.add_to_group(&"footstep_grass")
				for collision_child in child.get_children():
					if collision_child is CollisionObject3D:
						collision_child.add_to_group(&"footstep_grass")
			set_collision_layer(child)

		add_collision(child)


func collect_grass_visuals(node: Node, inherited_grass := false) -> void:
	# Most of this scene's green platforms are separate FadingPlatform instances.
	# Detect the shared leaf material directly so every platform is covered, even
	# when its scene root was not manually assigned to the footstep_grass group.
	var uses_grass_material := _uses_grass_material(node)
	var is_grass := (
		inherited_grass
		or node.is_in_group(&"footstep_grass")
		or uses_grass_material
	)
	if uses_grass_material:
		_mark_collision_ancestor_as_grass(node)
	if is_grass and node is VisualInstance3D:
		var surface := node as Node3D
		if not _grass_surfaces.has(surface):
			_grass_surfaces.append(surface)
	for child in node.get_children():
		collect_grass_visuals(child, is_grass)


func _uses_grass_material(node: Node) -> bool:
	if not node is CSGPolygon3D:
		return false
	var material: Material = (node as CSGPolygon3D).material
	if material == null:
		return false
	return material == GRASS_MATERIAL or material.resource_path.ends_with("leaf.tres")


func _mark_collision_ancestor_as_grass(node: Node) -> void:
	var ancestor := node.get_parent()
	while ancestor != null and ancestor != self:
		if ancestor is CollisionObject3D:
			ancestor.add_to_group(&"footstep_grass")
			return
		ancestor = ancestor.get_parent()


func _add_pond_prop_collisions() -> void:
	for root_name in LOTUS_PROP_ROOT_NAMES:
		var lotus_root := get_node_or_null(NodePath(root_name)) as Node3D
		if lotus_root != null:
			_add_lotus_group_collisions(lotus_root)

	var stone_root := get_node_or_null(NodePath(STONE_PROP_ROOT_NAME)) as Node3D
	if stone_root != null:
		_add_stone_collisions(stone_root)


func _add_lotus_group_collisions(lotus_root: Node3D) -> void:
	var flower_bounds := AABB()
	var has_flower_bounds := false
	var root_inverse := lotus_root.global_transform.affine_inverse()

	for node in lotus_root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if not has_geometry(mesh_instance):
			continue
		var mesh_name := String(mesh_instance.name).to_lower()
		if _is_lily_pad_mesh(mesh_name):
			_add_box_collision(mesh_instance, mesh_instance.get_aabb(), 0.18, 0.92, true)
		elif _is_lotus_flower_mesh(mesh_name):
			var relative_transform := root_inverse * mesh_instance.global_transform
			var mesh_bounds := relative_transform * mesh_instance.get_aabb()
			flower_bounds = mesh_bounds if not has_flower_bounds else flower_bounds.merge(mesh_bounds)
			has_flower_bounds = true

	if has_flower_bounds:
		_add_box_collision(lotus_root, flower_bounds, 0.30, 0.90, false)


func _add_stone_collisions(stone_root: Node3D) -> void:
	for node in stone_root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		var mesh_name := String(mesh_instance.name).to_lower()
		if mesh_name.contains("colorstone") and has_geometry(mesh_instance):
			_add_box_collision(mesh_instance, mesh_instance.get_aabb(), 0.24, 0.92, false)


func _add_box_collision(
	parent: Node3D,
	bounds: AABB,
	minimum_height: float,
	horizontal_scale: float,
	is_grass_surface: bool
) -> void:
	if parent.get_node_or_null(NodePath(GENERATED_COLLISION_BODY_NAME)) != null:
		return

	var body := StaticBody3D.new()
	body.name = GENERATED_COLLISION_BODY_NAME
	body.collision_layer = 1
	body.collision_mask = 1
	if is_grass_surface:
		body.add_to_group(&"footstep_grass")
	parent.add_child(body)

	var shape := BoxShape3D.new()
	var shape_size := bounds.size
	shape_size.x = maxf(shape_size.x * horizontal_scale, 0.12)
	shape_size.z = maxf(shape_size.z * horizontal_scale, 0.12)
	shape_size.y = maxf(shape_size.y, minimum_height)
	shape.size = shape_size

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = &"GeneratedPondPropShape"
	collision_shape.shape = shape
	var shape_position := bounds.get_center()
	if bounds.size.y < minimum_height:
		shape_position.y = bounds.end.y - minimum_height * 0.5
	collision_shape.position = shape_position
	body.add_child(collision_shape)


func _is_lily_pad_mesh(mesh_name: String) -> bool:
	var is_pad := (
		mesh_name.contains("lilypad")
		or mesh_name.contains("lily_pad")
		or mesh_name.contains("lotuspad")
	)
	return is_pad and not mesh_name.contains("vein") and not mesh_name.contains("stem")


func _is_lotus_flower_mesh(mesh_name: String) -> bool:
	return (
		mesh_name.contains("petal")
		or mesh_name.contains("receptacle")
		or mesh_name.contains("stamen")
	)


func has_collision(mesh_instance: MeshInstance3D) -> bool:
	for child in mesh_instance.get_children():
		if child is StaticBody3D:
			return true
	return false


func has_geometry(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.mesh == null:
		return false
	if mesh_instance.mesh.get_surface_count() == 0:
		return false
	for surface_index in mesh_instance.mesh.get_surface_count():
		if mesh_instance.mesh.surface_get_primitive_type(surface_index) != Mesh.PRIMITIVE_TRIANGLES:
			return false
		var surface_arrays: Array = mesh_instance.mesh.surface_get_arrays(surface_index)
		if surface_arrays.size() <= Mesh.ARRAY_VERTEX:
			return false
		var vertices_value: Variant = surface_arrays[Mesh.ARRAY_VERTEX]
		if not vertices_value is PackedVector3Array:
			return false
		var vertices: PackedVector3Array = vertices_value
		if vertices.size() < 3:
			return false
	return true


func set_collision_layer(mesh_instance: MeshInstance3D) -> void:
	for child in mesh_instance.get_children():
		if child is StaticBody3D:
			child.collision_layer = 1
			child.collision_mask = 1


func should_make_solid(mesh_name: String) -> bool:
	return (
		mesh_name.contains("land")
		or mesh_name.contains("mud")
		or mesh_name.contains("rock")
		or mesh_name.contains("cliff")
	)

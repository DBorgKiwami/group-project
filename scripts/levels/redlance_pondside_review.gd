extends Node3D

@export var add_simple_collision := true
@export var snap_player_to_spawn := true
@export var use_preview_camera := false

@onready var level_base: Node3D = $LevelBase
@onready var player: Node3D = $"3Dplatformingcharacter"

func _ready() -> void:
	if add_simple_collision:
		add_collision(level_base)
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
			if should_make_solid(mesh_name) and has_geometry(child) and not has_collision(child):
				child.create_trimesh_collision()
			set_collision_layer(child)

		add_collision(child)


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

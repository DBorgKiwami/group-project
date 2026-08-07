@tool
extends Node3D

const POND_WATER_MATERIAL := preload("res://materials/redlance_pond_water.tres")
const POND_WATER_SCALE := Vector3(1.12, 1.0, 1.10)

@export var add_simple_collision := true
@export var snap_player_to_spawn := true
@export var use_preview_camera := false

@onready var level_base: Node3D = $LevelBase
@onready var preview_camera: Camera3D = $PreviewCamera
@onready var player: Node3D = $"3Dplatformingcharacter"
@onready var player_camera: Camera3D = $"3Dplatformingcharacter/Node3D/Camera3D"
@onready var player_camera_pivot: Node3D = $"3Dplatformingcharacter/Node3D"
@onready var player_spawn: Marker3D = $GameplayPlan/PlayerSpawn
@onready var checkpoint_01: Marker3D = $GameplayPlan/Checkpoint_01


func _ready() -> void:
	setup_pond_water()
	if Engine.is_editor_hint():
		return

	if add_simple_collision:
		add_collision(level_base)
		var external_rocks := get_node_or_null("ExternalRockScatter")
		if external_rocks:
			add_collision(external_rocks)

	if snap_player_to_spawn:
		place_player_at_spawn()
		call_deferred("place_player_on_ground")

	sync_player_camera()

	if use_preview_camera:
		preview_camera.current = true
		preview_camera.look_at(player_spawn.global_position, Vector3.UP)
	else:
		preview_camera.current = false
		player_camera.current = true


func setup_pond_water() -> void:
	var water := level_base.find_child("Pond_Water_Main_Transparent", true, false) as MeshInstance3D
	if water:
		water.material_override = POND_WATER_MATERIAL
		water.scale = POND_WATER_SCALE

	var pond_bed := level_base.find_child("Pond_Bed_Deep", true, false) as MeshInstance3D
	if pond_bed:
		pond_bed.scale = POND_WATER_SCALE

	var water_area := get_node_or_null("GameplayTriggers/WaterAreaPlaceholder") as Area3D
	if water_area:
		water_area.scale = POND_WATER_SCALE

	var white_water_panel := level_base.find_child("Pond_Shallow_Edge_Glow", true, false) as MeshInstance3D
	if white_water_panel:
		white_water_panel.visible = false


func add_collision(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_name := String(child.name).to_lower()
			if should_make_solid(mesh_name):
				add_mesh_collision(child)

		add_collision(child)


func add_mesh_collision(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return

	var mesh_faces: PackedVector3Array = mesh_instance.mesh.get_faces()
	if mesh_faces.is_empty():
		return

	var parent := mesh_instance.get_parent()
	var collision_name := mesh_instance.name + "_MeshCollision"
	if parent.get_node_or_null(collision_name):
		return

	var body := StaticBody3D.new()
	body.name = collision_name
	parent.add_child(body)
	body.global_transform = mesh_instance.global_transform

	var shape_node := CollisionShape3D.new()
	var mesh_shape := ConcavePolygonShape3D.new()
	mesh_shape.set_faces(mesh_faces)
	shape_node.shape = mesh_shape
	body.add_child(shape_node)


func should_make_solid(mesh_name: String) -> bool:
	return (
		mesh_name.contains("land")
		or mesh_name.contains("rock")
		or mesh_name.contains("cliff")
	)


func place_player_at_spawn() -> void:
	player.global_position = player_spawn.global_position
	sync_player_camera()


func place_player_on_ground() -> void:
	await get_tree().physics_frame

	var space_state := get_world_3d().direct_space_state
	var ray_start := player_spawn.global_position + Vector3.UP * 4.0
	var ray_end := player_spawn.global_position + Vector3.DOWN * 6.0
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = 1

	var hit := space_state.intersect_ray(query)
	if hit:
		var pos := player.global_position
		pos.x = player_spawn.global_position.x
		pos.z = player_spawn.global_position.z
		pos.y = hit.position.y + get_spawn_offset()
		player.global_position = pos
		var player_body := player as Player3D
		if player_body:
			player_body.velocity = Vector3.ZERO
		sync_player_camera()


func get_spawn_offset() -> float:
	return 0.75 * abs(player.scale.y) + 0.15


func sync_player_camera() -> void:
	player_camera_pivot.global_position = player.global_position


func _on_checkpoint_01_area_entered(area: Area3D) -> void:
	var player_body := area.get_parent() as Player3D
	if player_body:
		player_spawn.global_position = checkpoint_01.global_position

extends Node3D

@export var add_simple_collision := true
@export var snap_player_to_spawn := true
@export var use_preview_camera := false

@onready var level_base: Node3D = $LevelBase
@onready var preview_camera: Camera3D = $PreviewCamera
@onready var player: Node3D = $"3Dplatformingcharacter"
@onready var player_camera: Camera3D = $"3Dplatformingcharacter/Node3D/Camera3D"
@onready var player_camera_pivot: Node3D = $"3Dplatformingcharacter/Node3D"
@onready var player_spawn: Marker3D = $GameplayPlan/PlayerSpawn


func _ready() -> void:
	if add_simple_collision:
		add_collision(level_base)

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


func add_collision(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_name := String(child.name).to_lower()
			if should_make_solid(mesh_name):
				child.create_trimesh_collision()

		add_collision(child)


func should_make_solid(mesh_name: String) -> bool:
	return (
		mesh_name.contains("land")
		or mesh_name.contains("mud")
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

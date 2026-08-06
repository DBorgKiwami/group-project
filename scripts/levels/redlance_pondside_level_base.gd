extends Node3D

@onready var player: Player3D = $"3Dplatformingcharacter"
@onready var player_camera: Camera3D = $"3Dplatformingcharacter/Node3D/Camera3D"
@onready var player_camera_pivot: Node3D = $"3Dplatformingcharacter/Node3D"
@onready var player_spawn: Marker3D = $GameplayPlan/PlayerSpawn
@onready var checkpoint: Marker3D = $GameplayPlan/Checkpoint_01


func _ready() -> void:
	player.global_position = player_spawn.global_position
	player_camera.current = true
	player_camera_pivot.global_position = player.global_position
	call_deferred("snap_player_to_ground")


func snap_player_to_ground() -> void:
	await get_tree().physics_frame

	var query := PhysicsRayQueryParameters3D.create(
		player_spawn.global_position + Vector3.UP * 3.0,
		player_spawn.global_position + Vector3.DOWN * 3.0
	)
	query.collision_mask = 1

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit:
		var position := player.global_position
		position.y = hit.position.y + 0.75 * abs(player.scale.y) + 0.15
		player.global_position = position
		player.velocity = Vector3.ZERO
		player_camera_pivot.global_position = player.global_position


func _on_checkpoint_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player3D:
		player_spawn.global_position = checkpoint.global_position

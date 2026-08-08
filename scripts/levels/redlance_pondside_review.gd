extends Node3D

@export var add_simple_collision := true
@export var snap_player_to_spawn := true
@export var use_preview_camera := false

@onready var level_base: Node3D = $LevelBase
@onready var player: Node3D = $"3Dplatformingcharacter"

func _ready() -> void:
	if add_simple_collision:
		add_collision(level_base)


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
		or mesh_name.contains("lily")
		or mesh_name.contains("rock")
		or mesh_name.contains("cliff")
	)

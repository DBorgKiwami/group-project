extends Node3D

@export var add_simple_collision := true

@onready var level_base: Node3D = $LevelBase
@onready var preview_camera: Camera3D = $PreviewCamera


func _ready() -> void:
	preview_camera.current = true
	preview_camera.look_at(Vector3(1.6, 0.45, 1.8), Vector3.UP)

	if add_simple_collision:
		add_collision(level_base)


func add_collision(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_name := String(child.name).to_lower()
			if mesh_name.contains("land") or mesh_name.contains("mud") or mesh_name.contains("lily"):
				child.create_trimesh_collision()

		add_collision(child)

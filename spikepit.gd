extends Area3D

@export var respawnPoint : Node3D
@export var DEFAULT : Vector3 = Vector3.ZERO
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	print("spikepit.gd loaded")

func _physics_process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if _is_player_in_pit(player):
			print("Player near spikes, respawning")
			if respawnPoint:
				player.global_position = respawnPoint.global_position
			else:
				player.global_position = DEFAULT
	else:
		print("No player found in group")

func _is_player_in_pit(player: Node3D) -> bool:
	if not collision_shape or not collision_shape.shape is BoxShape3D:
		return false

	var box: BoxShape3D = collision_shape.shape
	var local_pos = collision_shape.global_transform.affine_inverse() * player.global_position
	var half_size = box.size / 2.0

	return abs(local_pos.x) < half_size.x \
		and abs(local_pos.y) < half_size.y \
		and abs(local_pos.z) < half_size.z

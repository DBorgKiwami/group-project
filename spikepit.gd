extends Area3D
@export var respawnPoint : Node3D
@export var DEFAULT : Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player3D:
		if respawnPoint:
			body.global_position = respawnPoint.global_position
		else:
			body.global_position = DEFAULT
	pass # Replace with function body.

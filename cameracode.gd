extends Node3D

var playerReference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerReference = get_tree().get_first_node_in_group("Player")
	print(playerReference)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

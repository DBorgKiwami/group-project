extends Area3D
class_name EnemyHitbox

signal on_hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_on_hit(damage: Variant) -> void:
	print(damage)
	pass # Replace with function body.

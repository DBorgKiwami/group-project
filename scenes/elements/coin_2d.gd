extends RigidBody3D

var spawn_impulse : Vector3
@export var collection_area : Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass


#Replace this with an animation eventually
func _on_area_3d_area_entered(area: Area3D) -> void:
	PersistentData.coincount += 1
	queue_free()

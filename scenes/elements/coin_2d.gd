extends RigidBody3D
var spawn_impulse : Vector3
@export var collection_area : Area3D
@export var collect_sfx : AudioStreamPlayer
@export var fling_x : float = 5
@export var fling_y : float = 10
var flyout = false
var _collected := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flyout:
		apply_impulse(Vector3(randf_range(-fling_x,fling_x),randf_range(0,fling_y),0))
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	pass
#Replace this with an animation eventually
func _on_area_3d_area_entered(area: Area3D) -> void:
	if _collected:
		return
	_collected = true
	PersistentData.coincount += 1
	collection_area.set_deferred("monitoring", false)
	freeze = true
	$Sprite3D.visible = false
	if collect_sfx:
		collect_sfx.pitch_scale = randf_range(0.97, 1.04)
		collect_sfx.play()
		await collect_sfx.finished
	queue_free()

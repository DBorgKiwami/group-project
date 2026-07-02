extends Node3D

@export var cameraLerpSpeed = 5.0
@export var cameraSpeed = 0.005
var playerReference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerReference = get_tree().get_first_node_in_group("Player")
	print(playerReference)
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerReference:
		position = position.lerp(playerReference.position, delta * cameraLerpSpeed)
	pass

func _physics_process(delta: float) -> void:
	var camera_dir := Input.get_vector("camera_left","camera_right","camera_up","camera_down")
	camera_dir = Input.get_last_mouse_screen_velocity()
	
	if camera_dir:
		rotation.y -= deg_to_rad(camera_dir.x * cameraSpeed)
		rotation_degrees.x = clampf(rotation_degrees.x - (camera_dir.y  * cameraSpeed), -90, 90)

extends Node3D

@export var target : Node3D
@export var mouse_sensitivity = 0.005
@export var follow_speed = 8.0
@export var min_pitch = -60.0  # degrees, how far you can look down
@export var max_pitch = 10.0   # degrees, how far you can look up

var yaw = 0.0
var pitch = -30.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	if event.is_action_pressed("ui_cancel"):
		# Press Esc to release the mouse, click to recapture
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)
	rotation.y = yaw
	rotation.x = pitch

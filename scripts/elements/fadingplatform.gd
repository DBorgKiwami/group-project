extends StaticBody3D
class_name FadingPlatform

@export var linger_time := 5.0
@export var respawn_time := 5.0
var active = false
var respawning = false
var timer = 0.0
var respawn_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func startFade():
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if respawn_timer > respawn_time:
		active = false
		respawning = false
		respawn_timer = 0.0
		set_collision_layer_value(1, true)
	if timer > linger_time:
		active = false
		respawning = true
		set_collision_layer_value(1, false)
		timer = 0.0
	if active:
		timer += delta
	if respawning:
		respawn_timer += delta
	

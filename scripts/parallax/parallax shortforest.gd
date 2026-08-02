extends Node3D

## How much this layer scrolls relative to the camera.
## 0.0 = completely static (feels infinitely far away)
## 1.0 = moves exactly with the camera (feels like it's right at camera depth)
## Typical values: distant sky/mountains ~0.1-0.2, mid treeline ~0.3-0.5,
## close foreground details ~0.6-0.8. Leave your actual gameplay layer (ground,
## platforms, enemies) unscripted - only background dressing needs this.
@export var parallax_factor: float = 0.7
@export var camera: Camera3D

var base_position: Vector3

func _ready() -> void:
	base_position = position

func _process(_delta: float) -> void:
	if not camera:
		return
	# Only offset on the horizontal axis the camera pans along (X here,
	# matching a side-scroller). The layer's own base Z depth is untouched.
	position.x = base_position.x + camera.global_position.x * parallax_factor

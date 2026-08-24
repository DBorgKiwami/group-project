extends StaticBody3D
class_name BouncePad

@export var bounce_strength := 10.0
@export var bounce_anim :AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_bounce_anim():
	bounce_anim.play("mushroombounce")
	pass

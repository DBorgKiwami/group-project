extends CanvasLayer
#https://www.youtube.com/watch?v=m4PfHg3hmSo
#Referenced from this tutorial
#No point re-inventing wheels
signal loading_screen_ready

@export var animationControler: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await animationControler.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(new_value: float) -> void:
	pass

func _on_load_finished() -> void:
#	We will probably change this code later, but we just want this to work for now
	animationControler.play_backwards("transition")
	await animationControler.animation_finished
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

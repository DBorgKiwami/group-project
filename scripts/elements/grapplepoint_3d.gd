class_name GrapplePoint3D
extends Area3D

@export var animationController : AnimationPlayer

var camera_reference : Camera3D
var within_range = false
var highlighted = false

#func _ready() -> void:
	#camera_reference = get_tree().get_first_node_in_group("Player_Camera")

#func _input(event: InputEvent) -> void:
	#if !within_range:
		#return

func highlight():
	within_range = true;
	animationController.play("highlight")
	pass

func unhighlight():
	within_range = false;
	animationController.play("unhighlight")
	pass

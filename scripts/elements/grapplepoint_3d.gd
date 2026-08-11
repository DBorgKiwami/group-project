class_name GrapplePoint3D
extends Area3D

@export var animationController : AnimationPlayer

var highlighted = false

func highlight():
	highlighted = true;
	animationController.play("highlight")
	pass

func unhighlight():
	highlighted = false;
	animationController.play("unhighlight")
	pass

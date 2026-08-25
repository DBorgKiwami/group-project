extends State

@export var player_reference : CharacterBody3D

func update(_delta: float):
	pass

func physicsUpdate(_delta: float):
	pass

func enter():
	player_reference.animationController.stop()
	player_reference.animationController.play("dead")
	player_reference.velocity = Vector3.ZERO

func exit():
	pass

func input(_input: InputEvent):
	pass

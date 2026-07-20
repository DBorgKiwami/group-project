extends State

@export var player_reference : Player2D

func update(_delta: float):
	pass

func physicsUpdate(_delta: float):
	pass

func enter():
	player_reference.sprite.play("dead")

func exit():
	pass

func input(_input: InputEvent):
	pass

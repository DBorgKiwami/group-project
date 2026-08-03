extends State
class_name DragonflyIdle

@export var idle_length : float = 5.0
var timer = 0

func enter():
	timer = 0
	pass

func exit():
	pass

func physicsUpdate(delta: float):
	timer += delta
	if timer > idle_length:
		Transitioned.emit(self, "dragonflyswoop")
	pass

func update(_delta: float):
	pass

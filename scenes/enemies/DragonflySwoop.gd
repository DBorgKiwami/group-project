extends State
class_name DragonflySwoop

@export var animation_player : AnimationPlayer
@export var animation_speed : float = 1
@export var sprite : AnimatedSprite3D
@export var enemey_reference : CharacterBody3D
@export var number_of_swoops : int = 1
var dir = -1
var swoops = 0
var neutral_y
var neutral_x
var swooping = false

func enter():
	swoops = 0
	neutral_y = enemey_reference.position.y
	neutral_x = enemey_reference.position.x
	
	swoop()

func swoop():
	swooping = true
#	Tweak these numbers as needed later
	var swoopTween = get_tree().create_tween()
	swoopTween.set_parallel(true)
	swoopTween.tween_property(enemey_reference, "velocity:y", -1, 2.5)
	swoopTween.tween_property(enemey_reference, "velocity:y", 1, 2.5).set_delay(2.5)
	swoopTween.tween_property(enemey_reference, "velocity:y", 0, 2.5).set_delay(5)
	swoopTween.tween_property(enemey_reference, "velocity:x", animation_speed * dir, 3.625)
	swoopTween.tween_property(enemey_reference, "velocity:x", 0, 2.5).set_delay(3.625)
	swoopTween.finished.connect(animation_complete)

func exit():
	enemey_reference.position.x = neutral_x
	enemey_reference.position.y = neutral_y
	pass

func physicsUpdate(delta: float):
	#if enemey_reference.position.y > neutral_y and swooping:
		#var decel = get_tree().create_tween()
		#decel.tween_property(enemey_reference, "velocity:y", 0, 0.2)
	pass

func update(_delta: float):
	pass

func animation_complete():
	dir = dir * -1
	if swoops >= number_of_swoops:
		Transitioned.emit(self, "dragonflyidle")
		return
	swoops += 1
	swoop()
	pass

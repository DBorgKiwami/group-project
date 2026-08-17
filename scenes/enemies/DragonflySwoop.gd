extends State
class_name DragonflySwoop

@export var animation_player : AnimationPlayer
@export var animation_speed : float = 5
@export var sprite : AnimatedSprite3D
@export var enemey_reference : CharacterBody3D
@export var number_of_swoops : int = 1
var dir = -1
var swoops = 0
var neutral_y
var neutral_x
var swooping = false
var swoop_tween : Tween

func enter():
	swoops = 0
	neutral_y = enemey_reference.position.y
	neutral_x = enemey_reference.position.x
	
	swoop()

func swoop():
	swooping = true
#	Tweak these numbers as needed later
	_stop_swoop_tween()
	swoop_tween = get_tree().create_tween()
	swoop_tween.set_parallel(true)
	swoop_tween.tween_property(enemey_reference, "velocity:y", -4, 0.75)
	swoop_tween.tween_property(enemey_reference, "velocity:y", 0, 1.25).set_delay(0.75)
	swoop_tween.tween_property(enemey_reference, "velocity:y", 4, 0.75).set_delay(3.5)
	swoop_tween.tween_property(enemey_reference, "velocity:y", 0, 1.25).set_delay(4.25)
	swoop_tween.tween_property(enemey_reference, "velocity:x", animation_speed * dir, 3)
	swoop_tween.tween_property(enemey_reference, "velocity:x", 0, 2.5).set_delay(3)
	swoop_tween.finished.connect(animation_complete)

func exit():
	_stop_swoop_tween()
	swooping = false
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


func _stop_swoop_tween() -> void:
	if is_instance_valid(swoop_tween) and swoop_tween.is_valid():
		swoop_tween.kill()

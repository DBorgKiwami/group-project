extends State
class_name DragonflyProjectile

@export var sprite : AnimatedSprite3D
@export var enemey_reference : CharacterBody3D
@export var number_of_projectiles : int = 1
@export var projectile_scene : PackedScene
var dir = -1
var swoops = 0
var neutral_y
var neutral_x
var swooping = false

func enter():
	swoops = 0
	neutral_y = enemey_reference.position.y
	neutral_x = enemey_reference.position.x
	

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

extends State
class_name DragonflyProjectile

@export var sprite : AnimatedSprite3D
@export var enemey_reference : CharacterBody3D
@export var number_of_projectiles : int = 4
@export var projectile_scene : PackedScene
@export var fire_interval : float = 3.0
@export var fire_distance : float = 10.0

var timer
var projectiles_fired = 0
var neutral_y
var neutral_x
var swooping = false

func enter():
	timer = 0
	projectiles_fired = 0
	pass

func exit():
	pass

func fire():
	var newInstance = projectile_scene.instantiate()
	newInstance.position = enemey_reference.position
	if newInstance.position.x < 0:
		newInstance.position.x -= fire_distance
	else:
		newInstance.position.x += fire_distance
		newInstance.flip = true
	get_tree().root.add_child(newInstance)

func physicsUpdate(delta: float):
	timer = timer + delta
	if timer > fire_interval:
		fire()
		timer = 0
		projectiles_fired += 1
	if projectiles_fired >= number_of_projectiles:
		Transitioned.emit(self, "dragonflyidle")
	#if enemey_reference.position.y > neutral_y and swooping:
		#var decel = get_tree().create_tween()
		#decel.tween_property(enemey_reference, "velocity:y", 0, 0.2)
	pass

func update(_delta: float):
	pass

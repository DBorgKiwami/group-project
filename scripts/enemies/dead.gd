extends State
class_name EnemyDead

@export var enemy_body : CharacterBody3D

func enter():
	enemy_body.velocity = Vector3.ZERO
	print("Enemy Died")
	enemy_body.die()

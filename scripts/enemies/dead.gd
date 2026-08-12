extends State
class_name EnemyDead

@export var enemy_body : CharacterBody3D

func enter():
	print("Enemy Died")
	enemy_body.die()

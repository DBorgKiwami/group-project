extends State
class_name EnemyDead
@export var enemy_body : CharacterBody3D

func enter():
	enemy_body.velocity = Vector3.ZERO
	print("Enemy Died")
	enemy_body.die()
	
	await get_tree().create_timer(2.0).timeout  # let death animation/effects play out
	get_tree().change_scene_to_file("res://scenes/levels/end_cutscene.tscn")

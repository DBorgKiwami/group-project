extends State
class_name enemyWalk

@export var hflip = 1.0
@export var move_speed := 1.0
@export var enemy_body : CharacterBody3D
@export var enemy_sprite : AnimatedSprite3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	pass

func physicsUpdate(delta: float) -> void:
	if enemy_body.is_on_wall():
		hflip = -hflip
		if enemy_sprite:
			enemy_sprite.flip_h = !enemy_sprite.flip_h
	if enemy_body:
		enemy_body.velocity.x = move_speed * hflip

func exit():
	if enemy_body:
		enemy_body.velocity.x = 0

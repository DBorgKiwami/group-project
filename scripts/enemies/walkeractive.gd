extends State
class_name enemyWalk
@export var hflip = 1.0
@export var move_speed := 1.0
@export var enemy_body : CharacterBody3D
@export var enemy_sprite : AnimatedSprite3D
@export var flip_cooldown_time := 0.3

var flip_cooldown := 0.0

func enter() -> void:
	flip_cooldown = 0.0

func update(delta: float) -> void:
	pass

func physicsUpdate(delta: float) -> void:
	if not enemy_body:
		return

	if flip_cooldown > 0.0:
		flip_cooldown -= delta

	enemy_body.velocity.x = move_speed * hflip

	if flip_cooldown <= 0.0:
		for i in range(enemy_body.get_slide_collision_count()):
			var collision := enemy_body.get_slide_collision(i)
			var normal := collision.get_normal()
			if absf(normal.x) > 0.5:
				hflip = -hflip
				flip_cooldown = flip_cooldown_time
				if enemy_sprite:
					enemy_sprite.flip_h = hflip > 0
				break

func exit():
	if enemy_body:
		enemy_body.velocity.x = 0

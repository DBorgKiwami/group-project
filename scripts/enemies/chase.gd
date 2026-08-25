extends State
class_name CrawfishChase

@export var enemy_body: CrawfishEnemy
@export var speed: float = 0.5
@export var stop_distance: float = 2.0


func physicsUpdate(delta):
	if enemy_body.knockback_timer > 0:
		return

	if not enemy_body.chase_target:
		return

	var direction = enemy_body.chase_target.global_position - enemy_body.global_position
	direction.y = 0

	var distance = direction.length()

	if distance <= stop_distance:
		enemy_body.velocity.x = 0
		enemy_body.velocity.z = 0
		return

	direction = direction.normalized()

	enemy_body.velocity.x = direction.x * speed
	enemy_body.velocity.z = direction.z * speed

	if direction.x != 0:
		enemy_body.enemy_sprite.flip_h = direction.x > 0

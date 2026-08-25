extends CharacterBody3D
class_name CrawfishEnemy

signal defeated

@export var state_machine: State_Machine
@export var hitbox: EnemyHitbox
@export var hurtbox: Area3D
@export var animationControler: AnimationPlayer
@export var enemy_sprite: AnimatedSprite3D
@export var vision_area: Area3D

@export var max_health: int = 3
@export var damage: int = 1

@export var drop: PackedScene
@export var dropamount: int = 3

@export var defeat_sfx: AudioStreamPlayer

@export var flicker_count: int = 4
@export var flicker_time: float = 0.05

@export var knockback_force: float = 4.0
@export var knockback_duration: float = 0.15

var health: int
var _is_defeated := false
var flickering := false
var chase_target: Node3D = null

var knockback_timer: float = 0.0
var knockback_velocity: Vector3 = Vector3.ZERO


func _ready() -> void:
	health = max_health

	if hitbox:
		if not hitbox.on_hit.is_connected(hitbox_hit):
			hitbox.on_hit.connect(hitbox_hit)

	if vision_area:
		if not vision_area.body_entered.is_connected(_on_vision_body_entered):
			vision_area.body_entered.connect(_on_vision_body_entered)

		if not vision_area.body_exited.is_connected(_on_vision_body_exited):
			vision_area.body_exited.connect(_on_vision_body_exited)

		if not vision_area.area_entered.is_connected(_on_vision_area_entered):
			vision_area.area_entered.connect(_on_vision_area_entered)

		if not vision_area.area_exited.is_connected(_on_vision_area_exited):
			vision_area.area_exited.connect(_on_vision_area_exited)
	else:
		print("WARNING: vision_area is not assigned!")


func _on_vision_body_entered(body: Node3D) -> void:
	if _is_defeated:
		return

	print("Vision detected body: ", body.name)

	var player := _find_player_from_body(body)

	if player:
		print("Crawfish detected Player: ", player.name)

		chase_target = player

		if state_machine and state_machine.current_state:
			state_machine.on_child_transition(
				state_machine.current_state,
				"Chase"
			)


func _on_vision_body_exited(body: Node3D) -> void:
	if _is_defeated:
		return

	var player := _find_player_from_body(body)

	if player and player == chase_target:
		print("Player left Crawfish vision")

		chase_target = null

		if state_machine and state_machine.current_state:
			state_machine.on_child_transition(
				state_machine.current_state,
				"enemyWalk"
			)


func _on_vision_area_entered(area: Area3D) -> void:
	if _is_defeated:
		return

	print("Vision detected area: ", area.name)

	var player := _find_player_from_body(area)

	if player:
		print("Crawfish detected Player through Area: ", player.name)

		chase_target = player

		if state_machine and state_machine.current_state:
			state_machine.on_child_transition(
				state_machine.current_state,
				"Chase"
			)


func _on_vision_area_exited(area: Area3D) -> void:
	if _is_defeated:
		return

	var player := _find_player_from_body(area)

	if player and player == chase_target:
		print("Player left Crawfish vision through Area")

		chase_target = null

		if state_machine and state_machine.current_state:
			state_machine.on_child_transition(
				state_machine.current_state,
				"enemyWalk"
			)


func _find_player_from_body(body: Node3D) -> Node3D:
	var current: Node = body

	while current != null:
		if current.is_in_group("Player"):
			return current as Node3D

		current = current.get_parent()

	return null


func die() -> void:
	if _is_defeated:
		return

	_is_defeated = true

	if defeat_sfx:
		defeat_sfx.pitch_scale = randf_range(0.96, 1.04)
		defeat_sfx.play()

	if hurtbox:
		hurtbox.set_deferred("monitorable", false)
		hurtbox.set_deferred("monitoring", false)

	if vision_area:
		vision_area.set_deferred("monitorable", false)
		vision_area.set_deferred("monitoring", false)

	defeated.emit()

	if animationControler:
		animationControler.play("die")
		await animationControler.animation_finished

	if drop:
		for i in dropamount:
			var newInstance = drop.instantiate()
			newInstance.position = position
			newInstance.flyout = true
			get_tree().root.add_child(newInstance)

	call_deferred("queue_free")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if knockback_timer > 0:
		knockback_timer -= delta

		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z

	move_and_slide()


func hitbox_hit(damage_received: Variant) -> void:
	if _is_defeated:
		return

	var actual_damage: int = int(damage_received)

	health -= actual_damage

	print("Crawfish took ", actual_damage, " damage!")
	print("Crawfish health: ", health, "/", max_health)

	apply_knockback()
	damage_flicker()

	if health <= 0:
		state_machine.on_child_transition(
			state_machine.current_state,
			"Dead"
		)


func apply_knockback() -> void:
	if not chase_target:
		return

	var direction := global_position - chase_target.global_position
	direction.y = 0

	if direction.length_squared() == 0:
		return

	direction = direction.normalized()

	knockback_velocity = direction * knockback_force
	knockback_timer = knockback_duration


func damage_flicker() -> void:
	if enemy_sprite == null:
		print("ERROR: Enemy Sprite is not assigned!")
		return

	if flickering:
		return

	flickering = true

	for i in range(flicker_count):
		enemy_sprite.visible = false
		await get_tree().create_timer(flicker_time).timeout

		enemy_sprite.visible = true
		await get_tree().create_timer(flicker_time).timeout

	enemy_sprite.visible = true
	flickering = false


func _on_enemy_hurtbox_area_entered(area: Area3D) -> void:
	print("Gottem")

	if area is PlayerHitbox:
		area.emit_signal("on_hit", damage)

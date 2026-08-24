extends CharacterBody3D

signal defeated

@export var state_machine: State_Machine
@export var hitbox: EnemyHitbox
@export var hurtbox: Area3D
@export var animationControler: AnimationPlayer
@export var enemy_sprite: AnimatedSprite3D

# Enemy stats
@export var max_health: int = 3
@export var damage: int = 1

# Drops
@export var drop: PackedScene
@export var dropamount: int = 3

# Audio
@export var defeat_sfx: AudioStreamPlayer

# Damage flicker
@export var flicker_count: int = 4
@export var flicker_time: float = 0.05

var health: int
var _is_defeated := false
var flickering := false


func _ready() -> void:
	health = max_health

	if hitbox:
		if not hitbox.on_hit.is_connected(hitbox_hit):
			hitbox.on_hit.connect(hitbox_hit)


func die() -> void:
	if _is_defeated:
		return

	_is_defeated = true

	if defeat_sfx:
		defeat_sfx.pitch_scale = randf_range(0.96, 1.04)
		defeat_sfx.play()

	if hurtbox:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)

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

	move_and_slide()


func hitbox_hit(damage_received: Variant) -> void:
	if _is_defeated:
		return

	var actual_damage: int = int(damage_received)

	health -= actual_damage

	print("Crawfish took ", actual_damage, " damage!")
	print("Crawfish health: ", health, "/", max_health)

	damage_flicker()

	if health <= 0:
		state_machine.on_child_transition(
			state_machine.current_state,
			"Dead"
		)


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

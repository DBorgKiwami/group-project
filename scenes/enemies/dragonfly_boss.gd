extends CharacterBody3D

signal defeated

@export var state_machine : State_Machine
@export var hitbox : EnemyHitbox
@export var hurtbox : Area3D
@export var animationControler : AnimationPlayer
@export var sprite : AnimatedSprite3D
@export var ground_reference : Node3D

@export var contactDamage : int = 1
@export var health : int = 10

@export_range(0.0, 1.0, 0.05) var perch_chance : float = 0.45
@export var player_awareness_distance : float = 7.0
@export var perch_visual_drop_limit : float = 5.0
@export var idle_sprite_bottom_extent : float = 1.2
@export var death_sprite_bottom_extent : float = 0.69
@export var perch_ground_clearance : float = 2.0
@export var death_ground_clearance : float = 0.0
@export var death_knockback_distance : float = 1.2
@export var death_fall_duration : float = 0.85
@export var death_recoil_upward_speed : float = 2.0
@export var death_gravity : float = 12.0

# Damage flicker
@export var flicker_count : int = 4
@export var flicker_time : float = 0.05

var _last_state_name := ""
var _visual_generation := 0
var _sprite_anchor := Vector3.ZERO
var _perch_tween : Tween
var _perched := false
var _dying := false
var _death_sequence_started := false
var _death_falling := false
var _death_landing_x := 0.0
var _death_landing_y := 0.0
var _death_velocity := Vector3.ZERO
var _rng := RandomNumberGenerator.new()

var flickering := false


func _ready():
	print("hello")

	if hitbox:
		hitbox.connect("on_hit", hitbox_hit)

	_sprite_anchor = sprite.position
	_rng.randomize()


func _process(_delta: float) -> void:
	if _dying or not is_instance_valid(state_machine.current_state):
		return

	var state_name := state_machine.current_state.name.to_lower()

	if state_name != _last_state_name:
		_last_state_name = state_name
		_begin_visual_state(state_name)

	if _perched and _is_player_near():
		_wake_from_perch()


func die():
	if _death_sequence_started:
		return

	_death_sequence_started = true
	_dying = true
	_visual_generation += 1
	velocity = Vector3.ZERO

	_stop_perch_tween()

	sprite.position = _sprite_anchor

	hitbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)

	sprite.play(&"defeated")
	_start_death_fall()

	await sprite.animation_finished

	sprite.play(&"death")

	# Keep any original death animation if one is added to this scene later.
	if animationControler.has_animation(&"die"):
		animationControler.play(&"die")
		await animationControler.animation_finished


func _physics_process(delta: float) -> void:
	if _dying:
		if _death_falling:
			_update_death_fall(delta)
		else:
			velocity = Vector3.ZERO

		return

	move_and_slide()


func _on_hurtbox_area_entered(area: Area3D) -> void:
	print("Gottem")

	if area is PlayerHitbox:
		area.emit_signal("on_hit", contactDamage)


func hitbox_hit(damage_received: Variant) -> void:
	if _dying:
		return

	var actual_damage: int = int(damage_received)

	health -= actual_damage

	print("Dragonfly took ", actual_damage, " damage!")
	print("Dragonfly health: ", health)

	# Flash when damaged.
	damage_flicker()

	if health <= 0:
		_dying = true
		defeated.emit()

		state_machine.on_child_transition(
			state_machine.current_state,
			"enemydead"
		)


func damage_flicker() -> void:
	if sprite == null:
		print("ERROR: Dragonfly sprite is not assigned!")
		return

	if flickering:
		return

	flickering = true

	for i in range(flicker_count):
		sprite.visible = false
		await get_tree().create_timer(flicker_time).timeout

		sprite.visible = true
		await get_tree().create_timer(flicker_time).timeout

	sprite.visible = true
	flickering = false


func _begin_visual_state(state_name: String) -> void:
	_visual_generation += 1

	var request_id := _visual_generation

	_perched = false
	_stop_perch_tween()

	sprite.position = _sprite_anchor

	match state_name:
		"dragonflyidle":
			_play_idle_visual(request_id)

		"dragonflyswoop":
			_play_swoop_visual(request_id)

		"dragonflyprojectile":
			sprite.play(&"flight")

		_:
			sprite.play(&"flight")


func _play_idle_visual(request_id: int) -> void:
	if _rng.randf() > perch_chance:
		sprite.play(&"flight")
		return

	sprite.play(&"idle_prepare")

	await get_tree().create_timer(0.2, false).timeout

	if not _visual_request_is_current(request_id, "dragonflyidle"):
		return

	if _is_player_near():
		sprite.play(&"flap")
		return

	sprite.play(&"idle")

	var perch_target = _find_visual_perch_target()

	if perch_target == null:
		_perched = true
		return

	_perch_tween = create_tween()
	_perch_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_perch_tween.tween_property(
		sprite,
		"position",
		perch_target,
		0.25
	)

	await _perch_tween.finished

	if not _visual_request_is_current(request_id, "dragonflyidle"):
		return

	_perched = true


func _play_swoop_visual(request_id: int) -> void:
	sprite.play(&"swoop_prepare")

	await get_tree().create_timer(0.5, false).timeout

	if _visual_request_is_current(request_id, "dragonflyswoop"):
		sprite.play(&"swoop")


func _wake_from_perch() -> void:
	_perched = false

	_stop_perch_tween()

	sprite.play(&"flap")

	_perch_tween = create_tween()
	_perch_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_perch_tween.tween_property(
		sprite,
		"position",
		_sprite_anchor,
		0.12
	)


func _find_visual_perch_target():
	var surface_y = _find_ground_y_at(global_position, 12.0)

	if surface_y == null:
		return null

	var desired_center_y := (
		float(surface_y)
		+ idle_sprite_bottom_extent
		+ perch_ground_clearance
	)

	var local_drop := (
		desired_center_y
		- global_position.y
		- _sprite_anchor.y
	)

	local_drop = clampf(
		local_drop,
		-perch_visual_drop_limit,
		0.0
	)

	if absf(local_drop) < 0.25:
		return null

	var target := _sprite_anchor
	target.y += local_drop

	return target


func _start_death_fall() -> void:
	var start_position := global_position

	# Always recoil toward the arena centre.
	_death_landing_x = move_toward(
		start_position.x,
		0.0,
		death_knockback_distance
	)

	var landing_probe := Vector3(
		_death_landing_x,
		start_position.y,
		start_position.z
	)

	var surface_y = _find_ground_y_at(
		landing_probe,
		30.0
	)

	_death_landing_y = start_position.y - 6.0

	if surface_y != null:
		_death_landing_y = (
			float(surface_y)
			+ death_sprite_bottom_extent
			+ death_ground_clearance
			- _sprite_anchor.y
		)

	_death_velocity = Vector3(
		(_death_landing_x - start_position.x)
		/ maxf(death_fall_duration, 0.1),
		death_recoil_upward_speed,
		0.0
	)

	velocity = Vector3.ZERO
	_death_falling = true


func _update_death_fall(delta: float) -> void:
	velocity = Vector3.ZERO

	_death_velocity.y -= death_gravity * delta

	global_position += _death_velocity * delta

	if (
		(_death_velocity.x < 0.0
		and global_position.x <= _death_landing_x)
		or
		(_death_velocity.x > 0.0
		and global_position.x >= _death_landing_x)
	):
		global_position.x = _death_landing_x
		_death_velocity.x = 0.0

	if (
		global_position.y <= _death_landing_y
		and _death_velocity.y <= 0.0
	):
		global_position.x = _death_landing_x
		global_position.y = _death_landing_y

		_death_velocity = Vector3.ZERO
		velocity = Vector3.ZERO
		_death_falling = false


func _find_surface_y(max_distance: float):
	return _find_surface_y_at(
		global_position,
		max_distance
	)


func _find_ground_y_at(
	world_position: Vector3,
	max_distance: float
):
	if is_instance_valid(ground_reference):
		return ground_reference.global_position.y

	return _find_surface_y_at(
		world_position,
		max_distance
	)


func _find_surface_y_at(
	world_position: Vector3,
	max_distance: float
):
	var query := PhysicsRayQueryParameters3D.create(
		world_position + Vector3.UP * 0.25,
		world_position + Vector3.DOWN * max_distance
	)

	query.exclude = [get_rid()]
	query.collide_with_areas = false

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	return float(result["position"].y)


func _is_player_near() -> bool:
	var player := _find_player()

	return (
		is_instance_valid(player)
		and
		global_position.distance_to(
			player.global_position
		) <= player_awareness_distance
	)


func _find_player() -> Node3D:
	var player := get_tree().get_first_node_in_group("Player") as Node3D

	if (
		not is_instance_valid(player)
		and
		is_instance_valid(get_tree().current_scene)
	):
		player = get_tree().current_scene.find_child(
			"Player",
			true,
			false
		) as Node3D

	return player


func _visual_request_is_current(
	request_id: int,
	expected_state: String
) -> bool:
	return (
		not _dying
		and
		request_id == _visual_generation
		and
		_last_state_name == expected_state
	)


func _stop_perch_tween() -> void:
	if (
		is_instance_valid(_perch_tween)
		and
		_perch_tween.is_valid()
	):
		_perch_tween.kill()

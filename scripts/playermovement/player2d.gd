extends CharacterBody3D
class_name Player2D
@export var hitboxFront : Area3D
@export var hitboxUp : Area3D
@export var hitboxDown : Area3D
@export var animationController : AnimationPlayer
@export var player_hitbox : Area3D
@export var player_camera : Camera3D
@export var sprite : AnimatedSprite3D
@export var state_machine : State_Machine
@export var footstep_sfx : AudioStreamPlayer
@export var jump_sfx : AudioStreamPlayer
@export var landing_sfx : AudioStreamPlayer
@export var hud : Node2D
@export var death_screen : Node2D
@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var normal_anim_speed := 1.0
@export var sprint_anim_speed := 1.6
@export var anim_speed_ramp := 3.0
var current_anim_speed := 1.0
@export var JUMP_VELOCITY = 4.5
@export var camera_x_bound = 1.0
@export var camera_y_bound = 1.0
@export var camera_y_offset = 0.5
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var damage = 10
@export var max_health = 5
@export_range(0.1, 1.0, 0.01) var footstep_interval := 0.4
@export_range(0.0, 0.2, 0.01) var footstep_pitch_variation := 0.04
@export var attack_tongue : Sprite3D
@export var tongue_hitbox : Area3D
@export var tongue_attack_range := 3.0
@export var tongue_attack_speed := 0.15
@export var tongue_attack_damage := 1
var tongue_attacking := false

var health
var can_jump = false
var blocking = false
var block_timer = 0.0
var block_cooldown = 0.0
var jump_timer = jump_timer_max
var jump_buffer = 0
var clipping = false
var is_attacking = false
var _time_until_next_step := 0.0
var _was_walking := false
var _footstep_high_pitch := false
var _has_been_airborne := false
var _physics_started := false
var _just_landed := false

func _ready() -> void:
	health = max_health
	if player_hitbox:
		player_hitbox.connect("on_hit", _on_player_hit)
	if animationController:
		animationController.animation_finished.connect(_on_attack_animation_finished)
	
func _on_attack_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack", "attack_up", "attack_down"]:
		is_attacking = false

func _on_player_hit(damage) -> void:
	if blocking:
		print("Damage blocked!")
		return
	print("I've been hit for " + str(damage) + "!")
	health = health - 1
	animationController.play("hit")
	if hud:
		hud.take_hit()
	if health <= 0:
		print("I'm fuckin dead!")
		sprite.play("dead")
		state_machine.on_child_transition(state_machine.current_state, "dead")
		if hud:
			hud.visible = false
		if death_screen:
			death_screen.show_death_screen()
			death_screen.retry_pressed.connect(_on_retry_pressed)
			death_screen.return_pressed.connect(_on_return_pressed)
func _on_retry_pressed() -> void:
	print("Retry handler fired")
	get_tree().reload_current_scene()

func _on_return_pressed() -> void:
	Scenecontroler.load_scene_with_position("res://scenes/menu/main_menu.tscn", Vector3.ZERO)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_swap_level"):
		Scenecontroler.load_scene_with_position("res://scenes/levels/3d/testlevel.tscn", Vector3(1,1,1))
	if event.is_action_pressed("tongue_attack") and not is_attacking and not tongue_attacking:
		tongue_attack()
	pass
	
func _physics_process(delta: float) -> void:
	position.z = 0
	if block_cooldown > 0:
		block_cooldown -= delta
	if blocking:
		block_timer -= delta
		if block_timer <= 0:
			blocking = false
	move_and_slide()
	_update_landing_sound()
	_update_footsteps(delta)

func _update_landing_sound() -> void:
	_just_landed = false
	var on_floor_now := is_on_floor()

	if not _physics_started:
		_physics_started = true
		_has_been_airborne = not on_floor_now
		return

	if not on_floor_now:
		_has_been_airborne = true
	elif _has_been_airborne:
		if landing_sfx:
			landing_sfx.play()
		_has_been_airborne = false
		_just_landed = true

func _update_footsteps(delta: float) -> void:
	if footstep_sfx == null:
		return

	var is_walking := absf(velocity.x) > 0.1 and is_on_floor() and not blocking
	if not is_walking:
		_was_walking = false
		_time_until_next_step = 0.0
		return

	# The landing sound already uses the step sample, so do not double it with
	# an immediate walking step on the same physics frame.
	if _just_landed:
		_was_walking = true
		_time_until_next_step = footstep_interval
		return

	if not _was_walking:
		_was_walking = true
		_play_footstep()
		_time_until_next_step = footstep_interval
		return

	_time_until_next_step -= delta
	if _time_until_next_step <= 0.0:
		_play_footstep()
		_time_until_next_step += footstep_interval

func _play_footstep() -> void:
	var pitch_offset := (
		footstep_pitch_variation
		if _footstep_high_pitch
		else -footstep_pitch_variation
	)
	footstep_sfx.pitch_scale = 1.0 + pitch_offset
	_footstep_high_pitch = not _footstep_high_pitch
	footstep_sfx.play()

func _on_front_attack_hitbox_area_entered(area: Area3D) -> void:
	print("Entered front")
	if area is EnemyHitbox:
		print("Enemy")
		area.emit_signal("on_hit",damage)
	pass # Replace with function body.
func _on_up_attack_hurtbox_area_entered(area: Area3D) -> void:
	print("Entered up")
	if area is EnemyHitbox:
		print("Enemy")
		area.emit_signal("on_hit",damage)
	pass # Replace with function body.
func _on_down_attack_hurtbox_area_entered(area: Area3D) -> void:
	print("Entered down")
	if area is EnemyHitbox:
		print("Enemy")
		area.emit_signal("on_hit",damage)
		Hitstopmanager.hit_stop(0.05)
		velocity.y = maxf(JUMP_VELOCITY, velocity.y + JUMP_VELOCITY)
	pass # Replace with function body.
	
func _on_semi_solid_clip_area_body_entered(body: Node3D) -> void:
	print("Hello")
	clipping = true
	pass # Replace with function body.
func _on_semi_solid_clip_area_body_exited(body: Node3D) -> void:
	clipping = false
	pass # Replace with function body.
	
func tongue_attack() -> void:
	if tongue_attacking or not attack_tongue:
		return
	tongue_attacking = true
	attack_tongue.visible = true

	var facing_dir := -1.0 if sprite.flip_h else 1.0
	attack_tongue.flip_h = facing_dir < 0
	attack_tongue.rotation = Vector3.ZERO
	attack_tongue.scale = Vector3(0.01, 1.0, 1.0)
	attack_tongue.position = Vector3.ZERO
	if tongue_hitbox:
		tongue_hitbox.position = Vector3.ZERO

	var extend_tween := get_tree().create_tween()
	extend_tween.set_parallel(true)
	extend_tween.tween_property(attack_tongue, "scale:x", tongue_attack_range, tongue_attack_speed)
	extend_tween.tween_property(attack_tongue, "position:x", facing_dir * tongue_attack_range / 2.0, tongue_attack_speed)
	if tongue_hitbox:
		extend_tween.tween_property(tongue_hitbox, "position:x", facing_dir * tongue_attack_range, tongue_attack_speed)

	var retract_tween := get_tree().create_tween()
	retract_tween.set_parallel(true)
	retract_tween.tween_property(attack_tongue, "scale:x", 0.01, tongue_attack_speed).set_delay(tongue_attack_speed)
	retract_tween.tween_property(attack_tongue, "position:x", 0.0, tongue_attack_speed).set_delay(tongue_attack_speed)
	if tongue_hitbox:
		retract_tween.tween_property(tongue_hitbox, "position:x", 0.0, tongue_attack_speed).set_delay(tongue_attack_speed)
	retract_tween.tween_callback(_end_tongue_attack).set_delay(tongue_attack_speed * 2.0)
	
func _end_tongue_attack() -> void:
	tongue_attacking = false
	if attack_tongue:
		attack_tongue.visible = false

func _on_tongue_hitbox_area_entered(area: Area3D) -> void:
	if area is EnemyHitbox:
		area.emit_signal("on_hit", tongue_attack_damage)
		

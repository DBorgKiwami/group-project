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

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var camera_x_bound = 1.0
@export var camera_y_bound = 1.0
@export var camera_y_offset = 0.5
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var damage = 10
@export var max_health = 3
@export_range(0.1, 1.0, 0.01) var footstep_interval := 0.4
@export_range(0.0, 0.2, 0.01) var footstep_pitch_variation := 0.04
var health
var can_jump = false
var blocking = false
var block_timer = 0.0
var block_cooldown = 0.0
var jump_timer = jump_timer_max
var jump_buffer = 0
var _time_until_next_step := 0.0
var _was_walking := false
var _footstep_high_pitch := false

func _ready() -> void:
	health = max_health
	if player_hitbox:
		player_hitbox.connect("on_hit", _on_player_hit)

func _on_player_hit(damage) -> void:
	if blocking:
		print("Damage blocked!")
		return
	print("I've been hit for " + str(damage) + "!")
	health = health - damage
	if health <= 0:
		print("I'm fuckin dead!")
		state_machine.on_child_transition(state_machine.current_state, "dead")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_swap_level"):
		Scenecontroler.load_scene_with_position("res://scenes/levels/3d/testlevel.tscn", Vector3(1,1,1))
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
	_update_footsteps(delta)

func _update_footsteps(delta: float) -> void:
	if footstep_sfx == null:
		return

	var is_walking := absf(velocity.x) > 0.1 and is_on_floor() and not blocking
	if not is_walking:
		_was_walking = false
		_time_until_next_step = 0.0
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

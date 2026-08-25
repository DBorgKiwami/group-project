extends CharacterBody3D
class_name Player3D

@export var sprite : AnimatedSprite3D
@export var grappleArea : Area3D
@export var animationControler : AnimationPlayer
@export var player_camera : Camera3D
@export var camera_pivot : Node3D

@export var jump_sfx : AudioStreamPlayer3D
@export var landing_sfx : AudioStreamPlayer3D
@export var grapple_sfx : AudioStreamPlayer3D
@export var grapple_notification_sfx : AudioStreamPlayer
@export var footstep_sfx : AudioStreamPlayer3D
@export var grapple_point_calc : Node3D
@export var tongue : MeshInstance3D
@export var tongue_snap_flash : Node3D

@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_DISTANCE_FROM_GROUND = 1.0
@export var CAMERA_SPEED = 0.5
@export var CAMERA_PAN_SPEED = 5.0
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var grapple_time = 0.3
@export var bob_amplitude = 0.08
@export var bob_speed = 8.0
@export var normal_anim_speed := 1.0
@export var sprint_anim_speed := 1.6
@export var anim_speed_ramp := 3.0
@export var footstep_pitch_variation: float = 0.04

var can_jump = false
var jump_timer = jump_timer_max
var jump_buffer = 0
var grappleTween : Tween
var grappling = false
var inDialogue = false
var lastDirection = Vector3(0,0,-1)
var bob_time = 0.0
var sprite_base_y = 0.0
var animationdirection = "south"
var was_walking = false
var next_footstep_phase = PI
var footstep_high_pitch = false
var has_been_airborne = false
var physics_started = false
var grapplearealist = []
var current_anim_speed := 1.0
var grapple_target := Vector3.ZERO
@onready var footstep_controller: Node = get_node_or_null("FootstepController")
var just_landed = false


func bounce(bounce_height):
	velocity.y = bounce_height
	set_collision_mask_value(7, false)


func _ready():
	print(global_position)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# F9 will release the mouse for editing purposes
	SignalBus.display_dialogue.connect(_on_dialogue_display)
	SignalBus.dialogue_done.connect(_on_dialogue_done)

	if Scenecontroler._check_start_position():
		print("WAHWHAWHWAHAWHWAHAWH")
		global_position = Scenecontroler.start_position_value

	sprite_base_y = sprite.position.y


func _on_dialogue_display(_dialogue):
	inDialogue = true
	print("Dialogue started, inDialogue=", inDialogue)


func _on_dialogue_done():
	inDialogue = false
	print("Dialogue done, inDialogue=", inDialogue)


# Written as a function because of Godot's "Call Method" track in AnimationPlayer.
func grapple():
	var areaPosition = grapplearealist[0].global_position
	grapple_target = areaPosition
	grappling = true

	if grapple_sfx:
		grapple_sfx.play()

	if tongue:
		tongue.visible = true

	_play_tongue_snap_flash()

	grappleTween = get_tree().create_tween()

	grappleTween.tween_property(
		self,
		"position",
		areaPosition,
		grapple_time
	).set_trans(Tween.TRANS_SINE)

	grappleTween.tween_callback(endGrapple)


func endGrapple():
	grappling = false

	if tongue:
		tongue.visible = false


func _play_tongue_snap_flash() -> void:
	if tongue_snap_flash == null:
		return

	tongue_snap_flash.visible = true
	tongue_snap_flash.scale = Vector3(0.05, 0.05, 0.05)

	var snap_tween := get_tree().create_tween()

	snap_tween.tween_property(
		tongue_snap_flash,
		"scale",
		Vector3(0.35, 0.35, 0.35),
		0.05
	)

	snap_tween.tween_property(
		tongue_snap_flash,
		"scale",
		Vector3.ZERO,
		0.12
	)

	snap_tween.tween_callback(_hide_tongue_snap_flash)


func _hide_tongue_snap_flash() -> void:
	if tongue_snap_flash:
		tongue_snap_flash.visible = false


func _update_tongue() -> void:
	if not tongue:
		return

	var start := global_position
	var end := grapple_target
	var dist := start.distance_to(end)

	if dist < 0.001:
		return

	var mid := start.lerp(end, 0.5)

	tongue.global_position = mid
	tongue.look_at(end, Vector3.UP)
	tongue.rotate_object_local(Vector3.RIGHT, PI / 2.0)
	tongue.scale = Vector3(0.4, dist, 0.4)


func _input(event: InputEvent) -> void:
	grapplearealist.sort_custom(custom_sorter)

	if !grapplearealist.is_empty():
		grapplearealist[0].highlight()

		for i in range(1, grapplearealist.size()):
			grapplearealist[i].unhighlight()

	var camera_dir := Input.get_vector(
		"camera_left",
		"camera_right",
		"camera_up",
		"camera_down"
	)

	camera_dir = Input.get_last_mouse_screen_velocity()

	if camera_dir and !inDialogue and event is InputEventMouseMotion:
		var yRotation = deg_to_rad(event.relative.x * CAMERA_SPEED)

		rotation.y -= yRotation
		camera_pivot.rotation.y -= yRotation

		camera_pivot.rotation_degrees.x = clampf(
			camera_pivot.rotation_degrees.x
			- (event.relative.y * CAMERA_SPEED),
			-90,
			90
		)

	camera_dir = Input.get_last_mouse_screen_velocity()

	if event.is_action_pressed("grapple") and !inDialogue:
		if grappleArea.has_overlapping_areas() and !grappling:
			grapple()

	if event.is_action_pressed("debug_swap_level"):
		Scenecontroler.load_scene_with_transition_sound(
			"res://scenes/levels/2d/testlevel2d.tscn"
		)


func _physics_process(delta: float) -> void:
	#print("PHYSICS: inDialogue=", inDialogue, " input_dir=", Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
	#_update_grapple_notification()
	if jump_buffer > 0:
		jump_buffer -= delta

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		if velocity.y <= 0:
			set_collision_mask_value(7, true)

		# Decrease jump timer whilst not on the floor
		jump_timer -= delta

	if grappling:
		_update_tongue()

	# If you're on the floor, you can jump
	if is_on_floor():
		can_jump = true
		jump_timer = jump_timer_max

	# If the jump timer has run out, you cannot jump
	if jump_timer < 0:
		can_jump = false

	if Input.is_action_pressed("ui_accept") and !inDialogue:
		jump_buffer = jump_buffer_len

	# Handle jump.
	if jump_buffer > 0 and can_jump:
		jump_buffer = 0
		velocity.y = JUMP_VELOCITY

		set_collision_mask_value(7, false)

		if jump_sfx:
			jump_sfx.play()

		can_jump = false

	if Input.is_action_just_released("ui_accept"):
		velocity.y = minf(0, velocity.y)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var current_speed : float = (
		SPRINT_SPEED
		if Input.is_action_pressed("sprint")
		else SPEED
	)

	camera_pivot.global_position = camera_pivot.global_position.lerp(
		position + Vector3(0, CAMERA_DISTANCE_FROM_GROUND, 0),
		delta * CAMERA_PAN_SPEED
	)

	if direction:
		lastDirection = direction
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			current_speed
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			current_speed
		)

	move_and_slide()

	just_landed = false

	var on_floor_now := is_on_floor()

	if physics_started:
		if not on_floor_now:
			has_been_airborne = true

		elif has_been_airborne:

			if (
				footstep_controller != null
				and footstep_controller.has_method("play_surface_step")
			):
				footstep_controller.play_surface_step()

			elif landing_sfx:
				landing_sfx.play()

			has_been_airborne = false
			just_landed = true

	else:
		physics_started = true
		has_been_airborne = not on_floor_now


	# Check what we last collided with
	var last_collision = get_last_slide_collision()

	if last_collision:

		# If it's a bounce pad, bounce!
		if last_collision.get_collider() is BouncePad:
			bounce(
				last_collision.get_collider().bounce_strength
			)

		if last_collision.get_collider() is FadingPlatform:
			last_collision.get_collider().startFade()


func _update_grapple_notification() -> void:
	if grapple_notification_sfx == null:
		return

	var grapple_available := (
		grappleArea.has_overlapping_areas()
		and not grappling
		and not inDialogue
	)

	if grapple_available:
		if not grapple_notification_sfx.playing:
			grapple_notification_sfx.play()
	elif grapple_notification_sfx.playing:
		grapple_notification_sfx.stop()

func _play_footstep() -> void:
	if not footstep_sfx:
		return

	var pitch_offset: float = (
		footstep_pitch_variation
		if footstep_high_pitch
		else -footstep_pitch_variation
	)

	footstep_sfx.pitch_scale = 1.0 + pitch_offset
	footstep_high_pitch = !footstep_high_pitch
	footstep_sfx.play()


func _process(delta: float) -> void:

	# --- Sprite bob ---
	var horizontal_speed = Vector2(
		velocity.x,
		velocity.z
	).length()

	var is_walking = (
		horizontal_speed > 0.1
		and is_on_floor()
		and !grappling
		and !inDialogue
	)

	if is_walking:

		if not was_walking:
			if not just_landed:
				_play_footstep()

			next_footstep_phase = PI

		bob_time += delta * bob_speed

		sprite.position.y = (
			sprite_base_y
			+ sin(bob_time) * bob_amplitude
		)

		while bob_time >= next_footstep_phase:
			_play_footstep()
			next_footstep_phase += PI

	else:
		bob_time = 0.0
		next_footstep_phase = PI

		sprite.position.y = move_toward(
			sprite.position.y,
			sprite_base_y,
			delta * 2.0
		)

	was_walking = is_walking
	just_landed = false


	# Sprite Rotation Code

	var camera_pos = -player_camera.global_basis.z

	var player_east = lastDirection.rotated(
		Vector3(0, 1, 0),
		deg_to_rad(90)
	)

	var north_dot = lastDirection.dot(camera_pos)
	var east_dot = player_east.dot(camera_pos)

	var is_moving = horizontal_speed > 0.1

	if north_dot > 0.6:
		if east_dot < -0.5:
			animationdirection = "northwest"
		elif east_dot > 0.5:
			animationdirection = "northeast"
		else:
			animationdirection = "north"

	elif north_dot < -0.6:
		if east_dot < -0.5:
			animationdirection = "southwest"
		elif east_dot > 0.5:
			animationdirection = "southeast"
		else:
			animationdirection = "south"

	elif east_dot < 0:
		animationdirection = "west"

	else:
		animationdirection = "east"


	# Sprint animation speed ramp
	var target_anim_speed := (
		sprint_anim_speed
		if Input.is_action_pressed("sprint")
		else normal_anim_speed
	)

	current_anim_speed = move_toward(
		current_anim_speed,
		target_anim_speed,
		anim_speed_ramp * delta
	)

	sprite.speed_scale = current_anim_speed

	sprite.play(
		animationdirection
		+ ("walk" if is_moving else "idle")
	)


# This is for Grappling
func _on_area_3d_area_entered(area: Area3D) -> void:

	if area is not GrapplePoint3D:
		return

	grapplearealist = grappleArea.get_overlapping_areas()

	grapplearealist.sort_custom(custom_sorter)

	if !grapplearealist.is_empty():
		grapplearealist[0].highlight()

		for i in range(1, grapplearealist.size()):
			grapplearealist[i].unhighlight()


# This is for Grappling
func _on_area_3d_area_exited(area: Area3D) -> void:

	if area is not GrapplePoint3D:
		return

	area.unhighlight()

	grapplearealist = grappleArea.get_overlapping_areas()


var home_pos = 0


func custom_sorter(a, b) -> bool:
	if (
		a.global_position.distance_squared_to(
			grapple_point_calc.global_position
		)
		<
		b.global_position.distance_squared_to(
			grapple_point_calc.global_position
		)
	):
		return true

	return false

extends CharacterBody3D
class_name Player3D

@export var sprite : AnimatedSprite3D
@export var grappleArea : Area3D
@export var animationControler : AnimationPlayer
@export var player_camera : Camera3D
@export var camera_pivot : Node3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SPEED = 0.5
@export var CAMERA_PAN_SPEED = 5.0
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var grapple_time = 0.3
@export var bob_amplitude = 0.08
@export var bob_speed = 8.0
var can_jump = false
var jump_timer = jump_timer_max
var jump_buffer = 0
var grappleTween : Tween
var grappling = false
var inDialogue = false
var lastDirection = Vector3(0,0,-1)
var bob_time = 0.0
var sprite_base_y = 0.0


func bounce(bounce_height):
	velocity.y = bounce_height
	set_collision_mask_value(7, false)
	pass

func _ready():
	print(global_position)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#F9 will release the mouse for editing purposes
	SignalBus.display_dialogue.connect(_on_dialogue_display)
	SignalBus.dialogue_done.connect(_on_dialogue_done)
	if Scenecontroler._check_start_position():
		print("WAHWHAWHWAHAWHWAHAWH")
		global_position = Scenecontroler.start_position_value
	sprite_base_y = sprite.position.y

func _on_dialogue_display(_dialogue):
	inDialogue = true

func _on_dialogue_done():
	inDialogue = false


#Written as a function because of Godot's "Call Method" track in animation player. This means instead of having to time everything using code alone, we can do it in the animation player!
#Except right now its just done in code anyways because im lazy
#This is just a proof of concept for the mechanic and is in need of polish
func grapple():
	var areaPosition = grappleArea.get_overlapping_areas()[0].global_position
	#if areaPosition < position:
		#sprite.flip_h = true
	#else:
		#sprite.flip_h = false
	#Tweens are for when animations are too static. They're good for stuff like this, where the grapple point at the end is never guaranteed
	grappling = true;
	grappleTween = get_tree().create_tween()
	grappleTween.tween_property(self, "position", areaPosition, grapple_time).set_trans(Tween.TRANS_SINE)
	grappleTween.tween_callback(endGrapple)

func endGrapple():
	grappling = false

func _input(event: InputEvent) -> void:
	var camera_dir := Input.get_vector("camera_left","camera_right","camera_up","camera_down")
	camera_dir = Input.get_last_mouse_screen_velocity()
	if camera_dir and !inDialogue and event is InputEventMouseMotion:
		var yRotation = deg_to_rad(event.relative.x * CAMERA_SPEED)
		
		rotation.y -= yRotation
		camera_pivot.rotation.y -= yRotation
		camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x - (event.relative.y  * CAMERA_SPEED), -90, 90)
		#pass
	camera_dir = Input.get_last_mouse_screen_velocity()
	if event.is_action_pressed("grapple") and !inDialogue:
		#print(grappleArea.get_overlapping_areas())
		if grappleArea.has_overlapping_areas() and !grappling:
			grapple()
	if event.is_action_pressed("debug_swap_level"):
		Scenecontroler.load_scene("res://scenes/levels/2d/testlevel2d.tscn")

func _physics_process(delta: float) -> void:
	if jump_buffer > 0:
		jump_buffer -= delta
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y <= 0:
			set_collision_mask_value(7, true)
		#Decrease jump timer whilst not on the floor
		jump_timer -= delta;
	
	#If you're on the floor, you can jump
	if is_on_floor():
		can_jump = true;
		jump_timer = jump_timer_max
	
	#If the jump timer has run out, you cannot jump
	if jump_timer < 0:
		can_jump = false;
	if Input.is_action_pressed("ui_accept") and !inDialogue:
		jump_buffer = jump_buffer_len
	# Handle jump.
	if jump_buffer > 0 and can_jump:
		jump_buffer = 0
		velocity.y = JUMP_VELOCITY
		set_collision_mask_value(7, false)
		#If you've just pressed the jump button, you cannot jump
		can_jump = false
	if Input.is_action_just_released("ui_accept"):
		#If you've let go of the jump button, choose the lower number between 0 and player velocity and set velocity to that number (If you just set it to 0, you can basically spam spacebar to cancel the effect of gravity)
		velocity.y = minf(0, velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	camera_pivot.global_position = camera_pivot.global_position.lerp(position, delta * CAMERA_PAN_SPEED)
	if direction and !inDialogue:
		lastDirection = direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		#Deceleration towards a velocity of 0x and 0z
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#if !grappling:
		#if velocity.x < 0:
			#sprite.flip_h = true;
		#elif velocity.x > 0:
			#sprite.flip_h = false;
	#print(velocity)
	move_and_slide()
	
	
	
#	Check what we last collided with
	var last_collision = get_last_slide_collision()
	if last_collision:
#		If its a bounce pad, bounce!
#		For performance reasons it may be precient to change this to run on area instead. Instead of calling this function every second, it would only call on entry to a specific area, improving framerates
		if last_collision.get_collider() is BouncePad:
			bounce(last_collision.get_collider().bounce_strength)
		if last_collision.get_collider() is FadingPlatform:
			last_collision.get_collider().startFade()

func _process(delta: float) -> void:
	# --- Sprite bob ---
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0.1 and is_on_floor() and !grappling:
		bob_time += delta * bob_speed
		sprite.position.y = sprite_base_y + sin(bob_time) * bob_amplitude
	else:
		bob_time = 0.0
		sprite.position.y = move_toward(sprite.position.y, sprite_base_y, delta * 2.0)

	#Sprite Rotation Code
	#Ok so this is a lot of math. Im going to try and explain it best I can
	
	#Basis is basically the values of the 3 axis arrows that you'd see in the editor when moving an object
#	In this case, we're using it to know what way an object is facing.
#   By getting the Vector value of the Z arrow of the camera, we know where its facing (negated because godot cameras are reversed for some reason)
	var camera_pos = -player_camera.global_basis.z
	
#	Last direction (declared in physics process) gives us an idea of where the player character is "Facing"
#	Rotate it 90 degrees along the Y axis, we get an idea of the player character's east, as opposed to their north
	var player_east = lastDirection.rotated(Vector3(0, 1, 0), deg_to_rad(90))
	
#	The dot product is some math matrix multiplication bullshit. The short of it is: It calculates how similar two directions are to one another
#	1 if its an exact match, -1 if its an exact opposite
#	By doing the dot product with the camera position, we can get an idea of whether the sprite is facing us or facing away from us
#	Do the same with the east to know whether we're seeing the characters left or right side
	var north_dot = lastDirection.dot(camera_pos)
	var east_dot = player_east.dot(camera_pos)
	
#	Which value is larger overall? This lets us know which side of the character we're seeing
#	If the absolute value of north is higher than the absolute value of east, we must be seeing the front or back of our character
#	Otherwise, we're seeing the left or right side
	var is_moving = horizontal_speed > 0.1
	
	if abs(north_dot) > abs(east_dot):
		if north_dot > 0:
			sprite.play("backwalk" if is_moving else "backidle")
		else:
			sprite.play("frontwalk" if is_moving else "frontidle")
	else:
		if east_dot > 0:
			sprite.play("rightwalk" if is_moving else "rightidle")
		else:
			sprite.play("leftwalk" if is_moving else "leftidle")
	
	#print(north_dot)
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is GrapplePoint3D:
		area.highlight()
	pass # Replace with function body.


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area is GrapplePoint3D:
		area.unhighlight()
	pass # Replace with function body.

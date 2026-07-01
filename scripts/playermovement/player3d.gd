extends CharacterBody3D

@export var sprite : AnimatedSprite3D
@export var grappleArea : Area3D
@export var animationControler : AnimationPlayer
@export var player_camera : Camera3D
@export var camera_pivot : Node3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SPEED = 0.05
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var grapple_time = 0.3
var can_jump = false
var jump_timer = jump_timer_max
var jump_buffer = 0
var grappleTween : Tween
var grappling = false
var inDialogue = false
var lastDirection = Vector2.ZERO

func _ready():
	SignalBus.display_dialogue.connect(_on_dialogue_display)
	SignalBus.dialogue_done.connect(_on_dialogue_done)
	if Scenecontroler._check_start_position():
		global_position = Scenecontroler.start_position_value

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
		#If you've just pressed the jump button, you cannot jump
		can_jump = false
	if Input.is_action_just_released("ui_accept"):
		#If you've let go of the jump button, choose the lower number between 0 and player velocity and set velocity to that number (If you just set it to 0, you can basically spam spacebar to cancel the effect of gravity)
		velocity.y = minf(0, velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var camera_dir := Input.get_vector("camera_left","camera_right","camera_up","camera_down")
	camera_dir = Input.get_last_mouse_velocity()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if camera_dir and !inDialogue:
		rotation_degrees.y += camera_dir.x * CAMERA_SPEED
		camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x + (camera_dir.y  * CAMERA_SPEED), -90, 90)
		pass
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

	move_and_slide()#


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is GrapplePoint3D:
		area.highlight()
	pass # Replace with function body.


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area is GrapplePoint3D:
		area.unhighlight()
	pass # Replace with function body.

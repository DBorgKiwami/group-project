extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
var can_jump = false
var jump_timer = jump_timer_max
var jump_buffer = 0

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
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
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
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

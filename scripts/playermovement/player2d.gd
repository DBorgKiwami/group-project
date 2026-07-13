extends CharacterBody3D

@export var hitboxFront : Area3D
@export var hitboxUp : Area3D
@export var hitboxDown : Area3D
@export var animationController : AnimationPlayer
@export var player_hitbox : Area3D

@export var sprite : AnimatedSprite3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
var can_jump = false
var jump_timer = jump_timer_max
var jump_buffer = 0

func _ready() -> void:
	if player_hitbox:
		player_hitbox.connect("on_hit", _on_player_hit)

func _on_player_hit(damage) -> void:
	print("I've been hit for " + str(damage) + "!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		print("Attacking")
		#Using Godot's animation player, we can program the frames of the attack from the editor instead of purely in code!
		animationController.play("attack")
	if event.is_action_pressed("debug_swap_level"):
		Scenecontroler.load_scene_with_position("res://scenes/levels/3d/testlevel.tscn", Vector3(1,1,1))
	pass

func _physics_process(delta: float) -> void:
	#Reduce the jump buffer if its still running
	if jump_buffer > 0:
		jump_buffer -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		set_collision_mask_value(7, false)
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
	if Input.is_action_pressed("ui_accept"):
		#Reset the jump buffer
		jump_buffer = jump_buffer_len
	#If the jump buffer is higher than 0, the player is trying to jump
	if jump_buffer > 0 and can_jump:
		jump_buffer = 0
		velocity.y = JUMP_VELOCITY
		if velocity.y <= 0:
			set_collision_mask_value(7, true)
		#If you've just pressed the jump button, you cannot jump
		can_jump = false
	if Input.is_action_just_released("ui_accept"):
		#If you've let go of the jump button, choose the lower number between 0 and player velocity and set velocity to that number (If you just set it to 0, you can basically spam spacebar to cancel the effect of gravity)
		velocity.y = minf(0, velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		#Flip character depending on their direction
		if direction < 0:
			hitboxFront.rotation_degrees = Vector3(0, 180, 0)
			sprite.flip_h = true;
		else:
			hitboxFront.rotation_degrees = Vector3(0, 0, 0)
			sprite.flip_h = false;
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_front_attack_hitbox_area_entered(area: Area3D) -> void:
	print("Entered")
	if area is EnemyHitbox:
		print("Enemy")
		area.emit_signal("on_hit",10)
	pass # Replace with function body.

extends State
@export var player_reference : Player2D
@export var block_length : float
@export var block_cooldown : float
func update(_delta: float):
	if player_reference.player_camera:
		var x_diff = player_reference.position.x - player_reference.player_camera.global_position.x 
		if abs(x_diff) > player_reference.camera_x_bound:
			if x_diff>0:
				player_reference.player_camera.global_position.x += x_diff - player_reference.camera_x_bound
			else:
				player_reference.player_camera.global_position.x += x_diff + player_reference.camera_x_bound
		player_reference.player_camera.global_position.y = player_reference.position.y + player_reference.camera_y_offset
func physicsUpdate(delta: float):
	if player_reference.velocity.y > 0 or Input.is_action_pressed("ui_down") or player_reference.clipping:
		#print("No Semi-Solid")
		player_reference.set_collision_mask_value(7, false)
	else:
		player_reference.set_collision_mask_value(7, true)
	#print(player_reference.velocity.y)
	
	#Reduce the jump buffer if its still running
	if player_reference.jump_buffer > 0:
		player_reference.jump_buffer -= delta
	
	# Add the gravity.
	if not player_reference.is_on_floor():
		player_reference.velocity += player_reference.get_gravity() * delta
		#Decrease jump timer whilst not on the floor
		player_reference.jump_timer -= delta;
	
	#If you're on the floor, you can jump
	if player_reference.is_on_floor():
		player_reference.can_jump = true;
		player_reference.jump_timer = player_reference.jump_timer_max
	
	#If the jump timer has run out, you cannot jump
	if player_reference.jump_timer < 0:
		player_reference.can_jump = false;
	
	# Handle jump.
	if Input.is_action_pressed("ui_accept"):
		#Reset the jump buffer
		player_reference.jump_buffer = player_reference.jump_buffer_len
	#If the jump buffer is higher than 0, the player is trying to jump
	if player_reference.jump_buffer > 0 and player_reference.can_jump:
		player_reference.jump_buffer = 0
		player_reference.velocity.y = player_reference.JUMP_VELOCITY
		#If you've just pressed the jump button, you cannot jump
		player_reference.can_jump = false
	if Input.is_action_just_released("ui_accept"):
		#If you've let go of the jump button, choose the lower number between 0 and player velocity and set velocity to that number (If you just set it to 0, you can basically spam spacebar to cancel the effect of gravity)
		player_reference.velocity.y = minf(0, player_reference.velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		#Flip character depending on their direction
		if direction < 0:
			player_reference.hitboxFront.rotation_degrees = Vector3(0, 180, 0)
			player_reference.sprite.flip_h = true;
		else:
			player_reference.hitboxFront.rotation_degrees = Vector3(0, 0, 0)
			player_reference.sprite.flip_h = false;
		player_reference.velocity.x = direction * player_reference.SPEED
		if not player_reference.is_attacking:
			player_reference.sprite.play("walk")
	else:
		player_reference.velocity.x = move_toward(player_reference.velocity.x, 0, player_reference.SPEED)
		if not player_reference.is_attacking:
			player_reference.sprite.play("idle")
func enter():
	pass
func exit():
	pass
func input(event: InputEvent):
	if event.is_action_pressed("attack") and Input.is_action_pressed("ui_down"):
		print("Down")
		player_reference.is_attacking = true
		player_reference.animationController.play("attack_down")
		return
	if event.is_action_pressed("attack") and Input.is_action_pressed("ui_up"):
		print("Up")
		player_reference.is_attacking = true
		player_reference.animationController.play("attack_up")
		return
	if event.is_action_pressed("attack"):
		print("Attacking")
		#Using Godot's animation player, we can program the frames of the attack from the editor instead of purely in code!
		player_reference.is_attacking = true
		player_reference.animationController.play("attack")
	if event.is_action_pressed("grapple") and player_reference.block_cooldown < 0:
		player_reference.blocking = !player_reference.blocking
		player_reference.block_cooldown = block_cooldown
		player_reference.block_timer = block_length

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
@export var hud : Node2D
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var camera_x_bound = 1.0
@export var camera_y_bound = 1.0
@export var camera_y_offset = 0.5
@export var jump_timer_max = 0.2
@export var jump_buffer_len = 0.12
@export var damage = 10
@export var max_health = 5
var health
var can_jump = false
var blocking = false
var block_timer = 0.0
var block_cooldown = 0.0
var jump_timer = jump_timer_max
var jump_buffer = 0
var clipping = false
var is_attacking = false
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
	if hud:
		hud.take_hit()
	if health <= 0:
		print("I'm fuckin dead!")
		sprite.play("dead")
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

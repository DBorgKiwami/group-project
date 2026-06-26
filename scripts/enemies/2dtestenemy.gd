extends CharacterBody3D

@export var state_machine : State_Machine
@export var hitbox : EnemyHitbox
@export var animationControler : AnimationPlayer

func _ready():
	hitbox.connect("on_hit", hitbox_hit)

func die():
	animationControler.play("die")
	await animationControler.animation_finished
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func hitbox_hit(damage: Variant) -> void:
	state_machine.on_child_transition(state_machine.current_state, "Dead")
	pass # Replace with function body.

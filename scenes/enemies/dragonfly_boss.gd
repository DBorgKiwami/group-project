extends CharacterBody3D

@export var state_machine : State_Machine
@export var hitbox : EnemyHitbox
@export var hurtbox : Area3D
@export var animationControler : AnimationPlayer
@export var contactDamage : int = 1
@export var health : int = 50

func _ready():
	print("hello")
	hitbox.connect("on_hit", hitbox_hit)

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_hurtbox_area_entered(area: Area3D) -> void:
	print("Gottem")
	if area is PlayerHitbox:
		area.emit_signal("on_hit", contactDamage)
	pass # Replace with function body.

func hitbox_hit(damage: Variant) -> void:
	health -= damage
	if health <= 0:
		state_machine.on_child_transition(state_machine.current_state, "dead")
	pass # Replace with function body.

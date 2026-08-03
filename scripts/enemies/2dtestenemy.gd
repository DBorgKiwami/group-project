extends CharacterBody3D

signal defeated

@export var state_machine : State_Machine
@export var hitbox : EnemyHitbox
@export var hurtbox : Area3D
@export var animationControler : AnimationPlayer
@export var damage : int = 1
@export var drop : PackedScene
@export var dropamount : int = 3

var dead = false

func _ready():
	hitbox.connect("on_hit", hitbox_hit)

func die():
	if dead:
		return
	dead = true
	defeated.emit()
	animationControler.play("die")
	await animationControler.animation_finished
	if drop:
		for i in dropamount:
			var newInstance = drop.instantiate()
			newInstance.position = position
			newInstance.flyout = true
			get_tree().root.add_child(newInstance)
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func hitbox_hit(damage: Variant) -> void:
	state_machine.on_child_transition(state_machine.current_state, "Dead")
	pass # Replace with function body.


func _on_enemy_hurtbox_area_entered(area: Area3D) -> void:
	print("Gottem")
	if area is PlayerHitbox:
		area.emit_signal("on_hit", damage)
	pass # Replace with function body.

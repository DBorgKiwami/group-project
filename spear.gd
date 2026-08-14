extends CharacterBody3D

@export var lifetime : float = 5.0
@export var speed : float = 1.0
@export var flip : bool = false
@export var damage : int = 1
var overall_lifetime = 0

func _enter_tree() -> void:
	if flip:
		velocity.x = -speed
	else:
		velocity.x = speed
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	overall_lifetime += delta
	if overall_lifetime > lifetime:
		call_deferred("queue_free")


func _on_hurtbox_area_entered(area: Area3D) -> void:
	print("Gottem")
	if area is PlayerHitbox:
		area.emit_signal("on_hit", damage)

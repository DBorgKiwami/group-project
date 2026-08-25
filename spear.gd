extends CharacterBody3D

@export var lifetime : float = 5.0
@export var speed : float = 1.0
@export var flip : bool = false
@export var damage : int = 1
@export var projectile_sprite : Sprite3D
@export var hurtbox : Area3D
@export var impact_texture : Texture2D
@export var impact_duration : float = 0.35
@export var emergence_duration : float = 0.12
@export var emergence_start_scale : float = 0.35

var overall_lifetime := 0.0
var target_direction := Vector3.ZERO
var _impacted := false


func _ready() -> void:
	if not is_instance_valid(projectile_sprite):
		return
	var final_scale := projectile_sprite.scale
	projectile_sprite.scale = final_scale * emergence_start_scale
	var emergence_tween := create_tween()
	emergence_tween.tween_property(projectile_sprite, "scale", final_scale, emergence_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func set_target_position(target_position: Vector3) -> void:
	target_direction = (target_position - position).normalized()
	target_direction.z = 0.0


func _enter_tree() -> void:
	var travel_direction := target_direction
	if travel_direction.is_zero_approx():
		travel_direction = Vector3.LEFT if flip else Vector3.RIGHT
	travel_direction = travel_direction.normalized()
	velocity = travel_direction * speed
	if is_instance_valid(projectile_sprite):
		projectile_sprite.rotation.z = atan2(travel_direction.y, travel_direction.x)


func _physics_process(delta: float) -> void:
	if not _impacted:
		move_and_slide()
	overall_lifetime += delta
	if overall_lifetime > lifetime:
		call_deferred("queue_free")


func _on_hurtbox_area_entered(area: Area3D) -> void:
	if _impacted:
		return
	print("Gottem")
	if area is PlayerHitbox:
		area.emit_signal("on_hit", damage)
		_show_impact()


func _show_impact() -> void:
	_impacted = true
	velocity = Vector3.ZERO
	hurtbox.set_deferred("monitoring", false)
	if is_instance_valid(projectile_sprite) and is_instance_valid(impact_texture):
		projectile_sprite.texture = impact_texture
	await get_tree().create_timer(impact_duration, false).timeout
	queue_free()

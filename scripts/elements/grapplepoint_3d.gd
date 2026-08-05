class_name GrapplePoint3D
extends Area3D

@export var icon_sprite : Sprite3D
@export var idle_icon : Texture2D
@export var grapple_icon : Texture2D

var highlighted = false
var is_grappled = false
var idle_tween : Tween
var normal_scale = Vector3.ONE


func _ready():
	if icon_sprite:
		normal_scale = icon_sprite.scale
		icon_sprite.texture = idle_icon
		start_idle_pulse()


func highlight():
	highlighted = true;
	pass

func unhighlight():
	highlighted = false;
	pass


func start_grapple():
	is_grappled = true
	stop_idle_pulse()
	if icon_sprite:
		icon_sprite.texture = grapple_icon
		icon_sprite.scale = normal_scale * 1.1


func end_grapple():
	is_grappled = false
	if icon_sprite:
		icon_sprite.texture = idle_icon
		icon_sprite.scale = normal_scale
	start_idle_pulse()


func start_idle_pulse():
	if icon_sprite == null:
		return

	stop_idle_pulse()
	idle_tween = create_tween()
	idle_tween.set_loops()
	idle_tween.tween_property(icon_sprite, "scale", normal_scale * 1.12, 0.45)
	idle_tween.tween_property(icon_sprite, "scale", normal_scale, 0.45)


func stop_idle_pulse():
	if idle_tween:
		idle_tween.kill()
		idle_tween = null

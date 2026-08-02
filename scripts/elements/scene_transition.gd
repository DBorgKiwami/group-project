extends Area3D

@export var scene : String = ""
@export var spawnposition : Vector3
var active = false


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not active and not has_overlapping_areas():
		return

	if scene == "":
		return

	print("Loading scene: " + scene)
	if spawnposition != Vector3.ZERO:
		Scenecontroler.load_scene_with_position(scene, spawnposition)
	else:
		Scenecontroler.load_scene(scene)


func _on_area_entered(area: Area3D) -> void:
	active = true


func _on_area_exited(area: Area3D) -> void:
	active = false

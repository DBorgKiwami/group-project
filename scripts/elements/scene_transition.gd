extends Area3D
@export var scene : String = ""
@export var spawnposition : Vector3
@export var interact_distance := 2.0
@export var prompt : Node2D
@export var prompt_label : String = "ENTER"
var active = false

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not active and not has_overlapping_areas() and not player_is_close():
		return
	if scene == "":
		return
	if prompt:
		prompt.flash_confirm()
	print("Loading scene: " + scene)
	if spawnposition != Vector3.ZERO:
		Scenecontroler.load_scene_with_position(scene, spawnposition)
	else:
		Scenecontroler.load_scene(scene)

func _on_area_entered(area: Area3D) -> void:
	active = true
	if prompt:
		var player = get_tree().get_first_node_in_group("Player")
		prompt.show_prompt(prompt_label, player)

func _on_area_exited(area: Area3D) -> void:
	active = false
	if prompt:
		prompt.hide_prompt()

func player_is_close() -> bool:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return false
	return global_position.distance_to(player.global_position) <= interact_distance

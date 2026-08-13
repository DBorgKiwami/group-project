extends Area3D
@export var scene : String = ""
@export var spawnposition : Vector3
@export var interact_distance := 6.0
@export var prompt : Node2D
@export var prompt_label : String = "ENTER"
var player_in_range = false

func _physics_process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		if player_in_range:
			player_in_range = false
			if prompt:
				prompt.hide_prompt()
		return

	var close_now := global_position.distance_to(player.global_position) <= interact_distance

	if close_now and not player_in_range:
		player_in_range = true
		if prompt:
			prompt.show_prompt(prompt_label, player)
	elif not close_now and player_in_range:
		player_in_range = false
		if prompt:
			prompt.hide_prompt()

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not player_in_range:
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

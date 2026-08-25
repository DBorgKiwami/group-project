extends Node3D

@export var interact_distance := 3.0
@export var prompt: Node2D
@export var prompt_label: String = "TALK"
@export var dialogue_id: String = "elder_intro"
@export var dialogue_player: CanvasLayer

var player_in_range := false


func _physics_process(_delta: float) -> void:
	#print(dialogue_id + " " + str(player_in_range))
	
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		if player_in_range:
			player_in_range = false

			if prompt:
				prompt.hide_prompt()

		return

	var close_now := self.global_position.distance_to(
		player.global_position
	) <= interact_distance

	if close_now and not player_in_range:
		player_in_range = true

		if prompt:
			prompt.show_prompt(prompt_label, self)

	elif not close_now and player_in_range:
		player_in_range = false

		if prompt:
			prompt.hide_prompt()


func _input(event: InputEvent) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	
	if not event.is_action_pressed("talk"):
		return

	if not self.global_position.distance_to(player.global_position) <= interact_distance:
		return

	if prompt:
		prompt.flash_confirm()

	SignalBus.emit_signal(
		"display_dialogue",
		dialogue_id
	)


func is_talking_to_me() -> bool:
	return (
		dialogue_player != null
		and dialogue_player.dialogueDisplaying
	)

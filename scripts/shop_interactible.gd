extends Area3D

@export var shop_id: String = ""

var active := false
var is_shop_open := false
var interaction_prompt: Node = null

func _ready() -> void:
	_find_interaction_prompt()


func _find_interaction_prompt() -> void:
	var root := get_tree().current_scene

	if root == null:
		return

	var nodes := root.find_children("*", "Node", true, false)

	for node in nodes:
		if node == self:
			continue

		if node.has_method("show_prompt") and node.has_method("hide_prompt"):
			interaction_prompt = node
			interaction_prompt.hide_prompt()
			return


func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed("interact") and !is_shop_open:
		SignalBus.open_shop.emit(shop_id)
		is_shop_open = true
	elif active and event.is_action_pressed("interact") and is_shop_open:
		SignalBus.shop_done.emit()
		is_shop_open = false

	if interaction_prompt:
		if interaction_prompt.has_method("flash_confirm"):
			interaction_prompt.flash_confirm()

		interaction_prompt.hide_prompt()

	queue_free()

func _on_area_entered(area: Area3D) -> void:
	active = true

	if interaction_prompt:
		interaction_prompt.show_prompt("PICK UP", self)


func _on_area_exited(area: Area3D) -> void:
	active = false

	if interaction_prompt:
		interaction_prompt.hide_prompt()

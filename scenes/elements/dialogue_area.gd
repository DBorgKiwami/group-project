extends Area3D

@export var dialogue : Array[String] = [""]
var active = false

func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed("interact"):
		SignalBus.emit_signal("display_dialogue", dialogue)

func _on_area_entered(area: Area3D) -> void:
	active = true

func _on_area_exited(area: Area3D) -> void:
	active = false

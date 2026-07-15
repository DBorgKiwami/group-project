extends Area3D

var active = false

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if PersistentData.has_data_value(get_path(), "collected"):
		queue_free()

func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed("interact"):
		_collect_item()

func _collect_item():
	PersistentData.store_data_value(get_path(), "collected", true)
	queue_free()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	active = true


func _on_area_exited(area: Area3D) -> void:
	active = false

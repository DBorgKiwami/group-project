extends Node
signal display_dialogue(dialogue)
signal dialogue_done
signal open_shop(shop_id)
signal shop_done

func _ready() -> void:
	display_dialogue.connect(_debug_log_display)

func _debug_log_display(dialogue) -> void:
	print("SIGNALBUS: display_dialogue emitted with: ", dialogue, " | Stack: ", get_stack())

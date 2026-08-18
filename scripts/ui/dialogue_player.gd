extends CanvasLayer

@export_file("*json") var scene_text_file: String
@export var speaker_name: String = "SPEAKER"

@onready var visual: Node2D = $DialogueVisual

var dialogueFile: Dictionary = {}
var playingDialogue: Array = []
var dialogueIndex: int = 0
var dialogueDisplaying: bool = false


func _ready() -> void:
	visible = false

	if FileAccess.file_exists(scene_text_file):
		var file := FileAccess.open(scene_text_file, FileAccess.READ)
		var test_json_conv := JSON.new()
		var parse_result: Error = test_json_conv.parse(file.get_as_text())

		if parse_result == OK:
			dialogueFile = test_json_conv.get_data()

	SignalBus.connect("display_dialogue", _on_display_dialogue)

	if visual:
		visual.speaker_name = speaker_name


func _on_display_dialogue(dialogue) -> void:
	if not dialogueDisplaying:
		if not dialogueFile.has(dialogue):
			return

		visible = true
		playingDialogue = dialogueFile[dialogue]
		dialogueDisplaying = true
		dialogueIndex = 0

		if visual:
			visual.start_line(playingDialogue[dialogueIndex])

		return

	# First press finishes the typewriter effect.
	if visual and visual.current_line != "":
		var visible_letters: int = int(visual.time * 30.0)

		if visible_letters < visual.current_line.length():
			visual.time = float(visual.current_line.length()) / 30.0
			visual.queue_redraw()
			return

	# Next press advances to the next dialogue line.
	dialogueIndex += 1

	if dialogueIndex >= playingDialogue.size():
		dialogueDisplaying = false
		visible = false
		call_deferred("_emit_dialogue_done")
	else:
		if visual:
			visual.start_line(playingDialogue[dialogueIndex])


func _emit_dialogue_done() -> void:
	SignalBus.emit_signal("dialogue_done")


func force_close_dialogue() -> void:
	if dialogueDisplaying:
		dialogueDisplaying = false
		visible = false
		call_deferred("_emit_dialogue_done")

extends CanvasLayer

@export_file("*json") var scene_text_file: String
@export var speaker_name: String = "SPEAKER"

@onready var visual: Node2D = $DialogueVisual

const MAX_CHARS_PER_LINE: int = 32
const MAX_LINES_PER_PAGE: int = 3

var dialogueFile: Dictionary = {}
var playingDialogue: Array[String] = []
var dialogueIndex: int = 0
var dialogueDisplaying: bool = false


func _ready() -> void:
	visible = false

	if FileAccess.file_exists(scene_text_file):
		var file := FileAccess.open(scene_text_file, FileAccess.READ)
		var json := JSON.new()
		var parse_result: Error = json.parse(file.get_as_text())

		if parse_result == OK:
			dialogueFile = json.get_data()

	SignalBus.connect("display_dialogue", _on_display_dialogue)

	if visual:
		visual.speaker_name = speaker_name


func _on_display_dialogue(dialogue) -> void:
	if not dialogueDisplaying:
		if not dialogueFile.has(dialogue):
			return

		visible = true
		dialogueDisplaying = true
		dialogueIndex = 0

		playingDialogue = _build_dialogue_pages(dialogueFile[dialogue])

		if playingDialogue.is_empty():
			_end_dialogue()
			return

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

	# Once the current line is fully visible, advance.
	dialogueIndex += 1

	if dialogueIndex >= playingDialogue.size():
		_end_dialogue()
	else:
		if visual:
			visual.start_line(playingDialogue[dialogueIndex])


func _build_dialogue_pages(raw_dialogue) -> Array[String]:
	var pages: Array[String] = []

	if not raw_dialogue is Array:
		return pages

	for raw_line in raw_dialogue:
		var line: String = str(raw_line)

		if line.strip_edges() == "":
			continue

		var wrapped_lines: Array[String] = _wrap_text(
			line,
			MAX_CHARS_PER_LINE
		)

		var page_text: String = ""
		var line_count: int = 0

		for wrapped_line in wrapped_lines:
			if line_count >= MAX_LINES_PER_PAGE:
				pages.append(page_text)
				page_text = ""
				line_count = 0

			if page_text == "":
				page_text = wrapped_line
			else:
				page_text += "\n" + wrapped_line

			line_count += 1

		if page_text != "":
			pages.append(page_text)

	return pages


func _wrap_text(text: String, max_chars: int) -> Array[String]:
	var words: PackedStringArray = text.split(" ")
	var lines: Array[String] = []
	var current_line: String = ""

	for word in words:
		if current_line == "":
			current_line = word
			continue

		var test_line: String = current_line + " " + word

		if test_line.length() > max_chars:
			lines.append(current_line)
			current_line = word
		else:
			current_line = test_line

	if current_line != "":
		lines.append(current_line)

	return lines


func _end_dialogue() -> void:
	dialogueDisplaying = false
	visible = false
	playingDialogue.clear()
	dialogueIndex = 0

	if visual:
		visual.start_line("")

	call_deferred("_emit_dialogue_done")


func _emit_dialogue_done() -> void:
	SignalBus.emit_signal("dialogue_done")


func force_close_dialogue() -> void:
	if dialogueDisplaying:
		_end_dialogue()

extends CanvasLayer

@export_file("*json") var scene_text_file: String
@export var speaker_name: String = "MERCHANT"

@onready var visual: Node2D = get_node_or_null("DialogueVisual")

const MAX_LINES_PER_PAGE := 5
const MAX_TEXT_WIDTH := 500


var dialogueFile: Dictionary = {}
var playingDialogue: Array[String] = []
var dialogueIndex: int = 0
var dialogueDisplaying: bool = false


func _ready() -> void:
	visible = false

	if visual == null:
		push_error("DialogueVisual node could not be found.")
		return

	if FileAccess.file_exists(scene_text_file):
		var file := FileAccess.open(scene_text_file, FileAccess.READ)
		var json := JSON.new()

		if json.parse(file.get_as_text()) == OK:
			dialogueFile = json.get_data()

	SignalBus.connect("display_dialogue", _on_display_dialogue)

	visual.speaker_name = speaker_name


func _on_display_dialogue(
	dialogue: String,
	npc_name: String = "MERCHANT"
) -> void:

	if visual == null:
		return

	if not dialogueDisplaying:
		if not dialogueFile.has(dialogue):
			print("Dialogue ID not found: ", dialogue)
			return

		visual.speaker_name = npc_name
		visual.queue_redraw()

		playingDialogue = _create_pages(dialogueFile[dialogue])

		if playingDialogue.is_empty():
			return

		dialogueIndex = 0
		dialogueDisplaying = true
		visible = true

		_show_current_page()
		return


	var full_length: int = visual.current_line.length()
	var visible_length: int = int(visual.time * 30.0)

	if visible_length < full_length:
		visual.time = float(full_length) / 30.0
		visual.queue_redraw()
		return

	dialogueIndex += 1

	if dialogueIndex >= playingDialogue.size():
		_end_dialogue()
	else:
		_show_current_page()


func _show_current_page() -> void:
	if visual == null:
		return

	if dialogueIndex < 0:
		return

	if dialogueIndex >= playingDialogue.size():
		return

	visual.start_line(playingDialogue[dialogueIndex])


func _create_pages(raw_dialogue) -> Array[String]:
	var pages: Array[String] = []

	if not raw_dialogue is Array:
		return pages

	for entry in raw_dialogue:
		var text: String = str(entry).strip_edges()

		if text == "":
			continue

		var sentences: Array[String] = _split_sentences(text)

		var current_page: String = ""
		var current_lines: int = 0

		for sentence in sentences:
			var sentence_lines: Array[String] = _wrap_sentence(sentence)

			var sentence_line_count: int = sentence_lines.size()

			if sentence_line_count > MAX_LINES_PER_PAGE:
				if current_page != "":
					pages.append(current_page)
					current_page = ""
					current_lines = 0

				var line_index: int = 0

				while line_index < sentence_lines.size():
					var chunk: String = ""
					var lines_added: int = 0

					while (
						line_index < sentence_lines.size()
						and lines_added < MAX_LINES_PER_PAGE
					):
						if chunk == "":
							chunk = sentence_lines[line_index]
						else:
							chunk += "\n" + sentence_lines[line_index]

						line_index += 1
						lines_added += 1

					pages.append(chunk)

				continue

			if current_lines + sentence_line_count <= MAX_LINES_PER_PAGE:
				if current_page == "":
					current_page = sentence
				else:
					current_page += " " + sentence

				current_lines += sentence_line_count

			else:
				if current_page != "":
					pages.append(current_page)

				current_page = sentence
				current_lines = sentence_line_count

		if current_page != "":
			pages.append(current_page)

	return pages


func _split_sentences(text: String) -> Array[String]:
	var sentences: Array[String] = []
	var current: String = ""

	for i in range(text.length()):
		var character: String = text.substr(i, 1)

		current += character

		if (
			character == "."
			or character == "!"
			or character == "?"
		):
			sentences.append(current.strip_edges())
			current = ""

	if current.strip_edges() != "":
		sentences.append(current.strip_edges())

	return sentences


func _wrap_sentence(sentence: String) -> Array[String]:
	var lines: Array[String] = []

	var words: PackedStringArray = sentence.split(" ")
	var current: String = ""

	for word in words:
		if current == "":
			current = word
			continue

		var test: String = current + " " + word

		if _text_fits(test):
			current = test
		else:
			lines.append(current)
			current = word

	if current != "":
		lines.append(current)

	return lines


func _text_fits(text: String) -> bool:
	var width: int = 0
	var scale: int = 2

	# Approximate width calculation.
	# This deliberately does NOT access visual.LETTERS,
	# so DialogueVisual being missing can never crash this.
	for i in range(text.length()):
		var character: String = text.substr(i, 1)

		if character == " ":
			width += 8
		else:
			width += 12

	return width <= MAX_TEXT_WIDTH


func _end_dialogue() -> void:
	dialogueDisplaying = false
	visible = false

	playingDialogue.clear()
	dialogueIndex = 0

	if visual != null:
		visual.start_line("")

	call_deferred("_emit_dialogue_done")


func _emit_dialogue_done() -> void:
	SignalBus.emit_signal("dialogue_done")


func force_close_dialogue() -> void:
	if dialogueDisplaying:
		_end_dialogue()

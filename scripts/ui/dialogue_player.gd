extends CanvasLayer

@export_file("*json") var scene_text_file : String
var dialogueDisplaying = false
var dialogueFile = {}
var playingDialogue = []
@onready var textBox = $RichTextLabel
var dialogueIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		dialogueFile = test_json_conv.get_data()
		print(dialogueFile["fish_intro"])
	SignalBus.connect("display_dialogue", _on_display_dialogue)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_display_dialogue(dialogue) -> void:
	if !dialogueDisplaying:
		visible = true
		playingDialogue = dialogueFile[dialogue]
		dialogueDisplaying = true
		dialogueIndex = 0
		textBox.text = playingDialogue[dialogueIndex]
	elif dialogueDisplaying:
		dialogueIndex += 1
		if dialogueIndex >= playingDialogue.size():
			dialogueDisplaying = false
			visible = false
			SignalBus.emit_signal("dialogue_done")
		else:
			textBox.text = playingDialogue[dialogueIndex]
	

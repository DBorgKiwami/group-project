extends CanvasLayer

var dialogueDisplaying = false
var dialogueBox = []
@onready var textBox = $RichTextLabel
var dialogueIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	SignalBus.connect("display_dialogue", _on_display_dialogue)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_display_dialogue(dialogue) -> void:
	if !dialogueDisplaying:
		visible = true
		dialogueBox = dialogue
		dialogueDisplaying = true
		dialogueIndex = 0
		textBox.text = dialogueBox[dialogueIndex]
	elif dialogueDisplaying:
		dialogueIndex += 1
		if dialogueIndex >= dialogueBox.size():
			dialogueDisplaying = false
			visible = false
			SignalBus.emit_signal("dialogue_done")
		else:
			textBox.text = dialogueBox[dialogueIndex]
	

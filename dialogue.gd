extends RichTextLabel

var dialogues = {
	"intro": [
		"Well.",
		"Look at rookie here.",
		"How much are they paying you to be here, anyway?",
		"If you think you have a chance, then think again.",
		"If you wanna get ranked higher, you gotta perform well.",
		"Or out-perform your coworkers, even.",
		"Well, good luck.",
		"Here's the test track our manager sent you."
	],
	"after_task": [
		"So you're alive?"
	]
}

var current_sequence = []
var current_index = 0

func start_dialogue(key: String):
	if dialogues.has(key):
		current_sequence = dialogues[key]
		current_index = 0
		show_next_line()

func show_next_line():
	if current_index < current_sequence.size():
		text = current_sequence[current_index]
		current_index += 1
	else:
		text = ""
		
func _on_RichTextLabel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		show_next_line()

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
var dialogue_finished = false

func _ready():
	gui_input.connect(_on_gui_input)
	start_dialogue("intro")

func start_dialogue(key: String):
	if dialogues.has(key):
		current_sequence = dialogues[key]
		current_index = 0
		dialogue_finished = false
		show_next_line()

func show_next_line():
	if current_index < current_sequence.size():
		text = current_sequence[current_index]
		current_index += 1
	else:
		text = ""
		dialogue_finished = true
		print("Dialogue finished!")

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if dialogue_finished:
			get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
		else:
			show_next_line()

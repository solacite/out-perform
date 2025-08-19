extends Panel

@onready var text_label: RichTextLabel = $Dialogue

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

var current_sequence: Array = []
var current_index := 0
var dialogue_finished := false
var typing := false
var typing_speed := 0.03

func _ready():
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_STOP

	gui_input.connect(_on_gui_input)
	start_dialogue("intro")

func start_dialogue(key: String):
	if dialogues.has(key):
		current_sequence = dialogues[key]
		current_index = 0
		dialogue_finished = false
		call_deferred("show_next_line")

func show_next_line():
	if current_index < current_sequence.size():
		start_typing(current_sequence[current_index])
	else:
		dialogue_finished = true
		SceneTransition.change_scene_to("res://scenes/gameplay.tscn")

func start_typing(line: String) -> void:
	typing = true
	text_label.text = ""
	await get_tree().process_frame
	for i in range(line.length()):
		if not typing:
			text_label.text = line
			break
		text_label.text += line[i]
		await get_tree().create_timer(typing_speed).timeout
	typing = false

	current_index += 1
	
	if current_index >= current_sequence.size():
		dialogue_finished = true

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if typing:
			typing = false
		elif dialogue_finished:
			SceneTransition.change_scene_to("res://scenes/gameplay.tscn")
		else:
			show_next_line()

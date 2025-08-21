extends Panel

@onready var text_label: RichTextLabel = $Dialogue

var dialogues = {
	"intro": [
		"Well.",
		"Look at rookie here.",
		"How much are they paying you to be here, anyway?",
		"If you think you have a chance, then think again.",
		"To get ranked higher, you gotta perform well.",
		"Or out-perform your coworkers, even.",
		"Well, good luck.",
		"Here's the test track our manager sent you."
	],
	"after_task": [
		"So you're alive?",
		"Isn't that good to hear.",
		"You'll have to master the six colour tracks.",
		"They'll get faster every time.",
		"...",
		"Are you ready to do it again?",
		"Just think of it...as, um...no, just have fun with it.",
		"You won't have time to do anything else, anyways.",
		"Well...",
		"Get on with it, I suppose.",
		"...",
		"Farewell."
	]
}

var current_sequence: Array = []
var current_index := 0
var dialogue_finished := false
var typing := false
var typing_speed := 0.03
var current_dialogue_key := ""

func _ready():
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	
	determine_dialogue_state()

func determine_dialogue_state():
	if GameManager.has_played_before():
		start_dialogue("after_task")
	else:
		start_dialogue("intro")

func start_dialogue(key: String):
	if dialogues.has(key):
		current_dialogue_key = key
		current_sequence = dialogues[key]
		current_index = 0
		dialogue_finished = false
		call_deferred("show_next_line")

func show_next_line():
	if current_index < current_sequence.size():
		start_typing(current_sequence[current_index])
	else:
		dialogue_finished = true
		handle_dialogue_completion()

func handle_dialogue_completion():
	if current_dialogue_key == "intro":
		# First time - go to gameplay
		SceneTransition.change_scene_to("res://scenes/gameplay.tscn")
	elif current_dialogue_key == "after_task":
		# After gameplay - go back to gameplay or lobby
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
			handle_dialogue_completion()
		else:
			show_next_line()

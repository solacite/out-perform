# dialogue functionality
extends Panel

@onready var text_label: RichTextLabel = $Dialogue

# dialogue dictionary
var dialogues = {
	"intro": {
		"lines": [
			"Well.",
			"Look at rookie here.",
			"How much are they paying you to be here, anyway?",
			"If you think you have a chance, then think again.",
			"To get ranked higher, you gotta perform well.",
			"Or out-perform your coworkers, even.",
			"Well, good luck.",
			"Here's the test track our manager sent you."
		],
		"next_scene": "res://scenes/gameplay.tscn"
	},
	"after_intro": {
		"lines": [
			"So you're alive?",
			"Isn't that good to hear.",
			"You'll have to master the six colour tracks.",
			"They'll get faster every time.",
			"...",
			"You know what you're doing this for, right?",
			"Getting a promotion and all that...",
			"Getting more work experience to make your resume all prettied up and attractive...",
			"Haha, I guess that's what it's like to be young.",
			"...",
			"Are you ready to do it again?",
			"Just think of it...as, um...no, just have fun with it.",
			"You won't have time to do anything else, anyways.",
			"Well...",
			"Get on with it, I suppose.",
			"...",
			"Farewell."
		],
		"next_scene": "res://scenes/track_menu.tscn",
		"post_dialogue_action": "mark_second_intro_completed"
	}
}

# state variables
var current_sequence: Array = []
var current_index := 0
var dialogue_finished := false
var typing := false
var typing_speed := 0.03

func _ready():
	# make dialogue box visible + don't track clicks from label
	mouse_filter = Control.MOUSE_FILTER_STOP
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# connect signal
	gui_input.connect(_on_gui_input)
	
	# start dialogue
	start_dialogue()

func start_dialogue():
	var dialogue_branch = GameManager.get_next_dialogue_branch()
	var dialogue_data
	
	if dialogue_branch == "intro":
		dialogue_data = dialogues["intro"]
	elif dialogue_branch == "after_intro":
		dialogue_data = dialogues["after_intro"]
	else:
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")
		return
		
	current_sequence = dialogue_data.lines
	current_index = 0
	dialogue_finished = false
	call_deferred("show_next_line")

func show_next_line():
	if current_index < current_sequence.size():
		start_typing(current_sequence[current_index])
	else:
		dialogue_finished = true

func start_typing(line: String) -> void:
	typing = true
	text_label.text = ""
	
	# make sure text is clear
	await get_tree().process_frame
	
	for i in range(line.length()):
		# skip dialogue
		if not typing:
			text_label.text = line
			break
		text_label.text += line[i]
		await get_tree().create_timer(typing_speed).timeout
	
	typing = false
	current_index += 1

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if typing:
			typing = false
		elif dialogue_finished:
			handle_dialogue_completion()
		else:
			show_next_line()

# post-dialogue
func handle_dialogue_completion():
	var dialogue_branch = GameManager.get_next_dialogue_branch()
	
	if dialogue_branch == "":
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")
		return
	
	if dialogue_branch == "intro":
		SceneTransition.change_scene_to(dialogues["intro"]["next_scene"])
	elif dialogue_branch == "after_intro":
		SceneTransition.change_scene_to(dialogues["after_intro"]["next_scene"])

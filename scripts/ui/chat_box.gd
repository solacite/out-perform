# dialogue functionality
extends Panel

@onready var text_label: RichTextLabel = $Dialogue
@onready var speech_sound: AudioStreamPlayer2D = $"../Speech"

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
var input_locked := false

func _ready():
	# make dialogue box visible + don't track clicks from label
	mouse_filter = Control.MOUSE_FILTER_STOP
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# connect signal
	gui_input.connect(_on_gui_input)
	
	# start dialogue
	start_dialogue()

func start_dialogue():
	MusicManager.play_music("res://audio/dialogue music.mp3", true)
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
	if input_locked:
		return
	if current_index < current_sequence.size():
		start_typing(current_sequence[current_index])
	else:
		handle_dialogue_completion()

func start_typing(line: String) -> void:
	typing = true
	input_locked = true
	text_label.text = ""

	await get_tree().process_frame

	var words = line.split(" ")

	for word in words:
		if not typing:
			text_label.text = line
			break

		text_label.text += word + " "
		play_speech_sound_middle()

		var delay = 0.15 + (word.length() * 0.02)
		if word.ends_with(","):
			delay += 0.15
		elif word.ends_with(".") or word.ends_with("!") or word.ends_with("?"):
			delay += 0.3

		await get_tree().create_timer(delay).timeout

	typing = false
	current_index += 1
	input_locked = false

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if typing:
			# click skips current line
			typing = false
		elif not input_locked:
			show_next_line()

# post-dialogue
func handle_dialogue_completion():
	var dialogue_branch = GameManager.get_next_dialogue_branch()
	
	if dialogue_branch == "intro":
		print("INTRO DIALOGUE DONE")
		SceneTransition.change_scene_to(dialogues["intro"]["next_scene"])
	elif dialogue_branch == "after_intro":
		print("AFTER INTRO DIALOGUE DONE")
		SceneTransition.change_scene_to(dialogues["after_intro"]["next_scene"])
	else:
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")

func play_speech_sound():
	if not speech_sound.stream:
		return

	# random pitch
	speech_sound.pitch_scale = randf_range(0.9, 1.2)

	# restart the sound if still playing
	if speech_sound.playing:
		speech_sound.stop()

	print("playing speech sound! NOW")
	speech_sound.play()

	# cut off quickly so it matches "syllable/char length"
	var cutoff_time = 1
	get_tree().create_timer(cutoff_time).timeout.connect(func():
		if speech_sound.playing:
			speech_sound.stop()
	)
	
func play_speech_sound_middle():
	if not speech_sound.stream:
		return

	speech_sound.pitch_scale = randf_range(0.9, 1.2)

	var total_length = speech_sound.stream.get_length()
	var middle_start = total_length * 0.25
	var middle_end = total_length * 0.75
	var random_start = randf_range(middle_start, middle_end - 0.1)

	if speech_sound.playing:
		speech_sound.stop()

	speech_sound.seek(random_start)
	speech_sound.play()

	var cutoff_time := 0.15
	var timer = get_tree().create_timer(cutoff_time)
	timer.timeout.connect(func():
		if speech_sound.playing:
			speech_sound.stop()
	)

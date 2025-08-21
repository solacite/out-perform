extends Node

@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("Stereo/AudioStreamPlayer2D")
@onready var instructions: Control = $ParallaxBackground/Background/Instructions
@export var orange_audio: AudioStream
@export var frequency_threshold: float = 1.0
@export var arrow_cooldown: float = 0.5
@export var beat_offset: float = 0.5
@export var beat_lookahead: float = 1.6
@export var arrow_scale: float = 0.2

@onready var score_label: RichTextLabel = $ParallaxBackground/Background/CurrentScore

var arrow_textures = {
	"left": preload("res://assets/arrows/left_arrow.png"),
	"down": preload("res://assets/arrows/down_arrow.png"),
	"up": preload("res://assets/arrows/up_arrow.png"),
	"right": preload("res://assets/arrows/right_arrow.png")
}

var current_score: int = 0
var high_score: int = 0
var spectrum: AudioEffectInstance
var last_arrow_time: float = 0
var effect_index: int = -1
var arrow_counter: int = 0

func _ready():
	setup_instructions()
	load_high_score()
	update_score_display()
	
	if audio_player == null:
		print("AudioStreamPlayer2D not found at Stereo/AudioStreamPlayer2D.")
		audio_player = find_child("AudioStreamPlayer2D", true, false) as AudioStreamPlayer2D
		
		if audio_player == null:
			print("No AudioStreamPlayer2D found, creating one...")
			audio_player = AudioStreamPlayer2D.new()
			add_child(audio_player)
	
	if orange_audio != null:
		audio_player.stream = orange_audio
	else:
		var loaded_audio = load("res://audio/orange.mp3")
		if loaded_audio != null:
			audio_player.stream = loaded_audio
		else:
			print("Error: Could not load audio file")
			return
	
	var effect = AudioEffectSpectrumAnalyzer.new()
	effect_index = AudioServer.get_bus_effect_count(0)
	AudioServer.add_bus_effect(0, effect, effect_index)
	spectrum = AudioServer.get_bus_effect_instance(0, effect_index)
	
	if audio_player:
		audio_player.play()
		audio_player.finished.connect(_on_audio_finished)
		print("Audio started playing")

func setup_instructions():
	if instructions == null:
		print("Instructions node not found!")
		return
		
	if not GameManager.has_played_before():
		instructions.modulate.a = 0.0
		instructions.visible = true
		
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(instructions, "modulate:a", 1.0, 1.0)
		
		fade_in_tween.tween_callback(start_fade_out_timer)
	else:
		instructions.visible = false

func start_fade_out_timer():
	await get_tree().create_timer(3.0).timeout
	fade_out_instructions()

func fade_out_instructions():
	if instructions != null:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(instructions, "modulate:a", 0.0, 1.0)
		fade_out_tween.tween_callback(func(): instructions.visible = false)

func _on_audio_finished():
	save_high_score()
	GameManager.mark_gameplay_completed()
	SceneTransition.change_scene_to("res://scenes/dialogue.tscn")

func go_back_to_dialogue():
	GameManager.mark_gameplay_completed()
	SceneTransition.change_scene_to("res://scenes/dialogue.tscn")

func _process(delta):
	if spectrum == null or not audio_player.playing:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time < last_arrow_time + arrow_cooldown:
		return
	
	var bands = {
		"left": get_frequency_band(60, 200),
		"down": get_frequency_band(200, 800),
		"up": get_frequency_band(800, 1500),
		"right": get_frequency_band(1500, 12000)
	}
	
	var directions = ["left", "down", "up", "right"]
	var total_energy = 0.0
	for direction in bands:
		total_energy += bands[direction] * 1000
	
	if total_energy > frequency_threshold:
		var chosen_direction = ""
		var max_energy = 0.0
		
		for direction in bands:
			if bands[direction] > max_energy:
				max_energy = bands[direction]
				chosen_direction = direction
		
		if chosen_direction != "":
			spawn_arrow(chosen_direction)
			last_arrow_time = current_time

func _input(event):
	if event.is_action_pressed("ui_left"):
		check_and_remove_arrow("left")
	if event.is_action_pressed("ui_down"):
		check_and_remove_arrow("down")
	if event.is_action_pressed("ui_up"):
		check_and_remove_arrow("up")
	if event.is_action_pressed("ui_right"):
		check_and_remove_arrow("right")

func get_frequency_band(from_hz: float, to_hz: float) -> float:
	if spectrum == null:
		return 0.0
	return spectrum.get_magnitude_for_frequency_range(from_hz, to_hz).length()

func spawn_arrow(direction: String):
	var arrow = Sprite2D.new()
	add_child(arrow)
	
	arrow.set_meta("direction", direction)
	
	if direction in arrow_textures:
		arrow.texture = arrow_textures[direction]
		arrow.scale = Vector2(arrow_scale, arrow_scale)
	else:
		arrow.queue_free()
		return
	
	var screen_width = get_viewport().get_visible_rect().size.x
	match direction:
		"left":
			arrow.position.x = screen_width * 0.4
		"down":
			arrow.position.x = screen_width * 0.55
		"up":
			arrow.position.x = screen_width * 0.7
		"right":
			arrow.position.x = screen_width * 0.85
	
	arrow.position.y = -100
	
	var fall_distance = get_viewport().get_visible_rect().size.y + 200
	var tween = create_tween()
	tween.tween_property(arrow, "position:y", fall_distance, beat_lookahead)
	tween.tween_callback(arrow_missed.bind(arrow))
	
	arrow.set_meta("tween", tween)

func check_and_remove_arrow(direction: String):
	var arrows = get_children()
	var found_matching_arrow = false
	
	for arrow in arrows:
		if arrow is Sprite2D and arrow.has_meta("direction") and arrow.get_meta("direction") == direction:
			found_matching_arrow = true
			current_score += 1
			
			if arrow.has_meta("tween"):
				var tween = arrow.get_meta("tween")
				if tween and tween.is_valid():
					tween.kill()
			
			arrow.queue_free()
			update_score_display()
			return
	
	if not found_matching_arrow:
		current_score = 0
		update_score_display()

func _exit_tree():
	if effect_index >= 0:
		AudioServer.remove_bus_effect(0, effect_index)
		
func arrow_missed(arrow):
	print("you missed. haha!")
	if is_instance_valid(arrow):
		current_score = 0
		update_score_display()
		arrow.queue_free()

func update_score_display():
	if score_label:
		if current_score > high_score:
			high_score = current_score
			GameManager.set_high_score(high_score)
		
		score_label.text = "high score: " + str(high_score) + "\nscore: " + str(current_score)
	
func load_high_score():
	high_score = GameManager.get_high_score()

func save_high_score():
	if current_score > high_score:
		high_score = current_score
		GameManager.set_high_score(high_score)

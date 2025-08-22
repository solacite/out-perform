extends Node

# nodes + UI
@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("Stereo/AudioStreamPlayer2D")
@onready var instructions: Control = $ParallaxBackground/Background/Instructions
@onready var score_label: RichTextLabel = $ParallaxBackground/Background/CurrentScore

# exports
@export var orange_audio: AudioStream
@export var frequency_threshold: float = 1.0     # energy necessary to spawn arrows
@export var arrow_cooldown: float = 0.5          # delay btwn arrow spawns
@export var beat_lookahead: float = 1.6          # time arrows take to fall
@export var arrow_scale: float = 0.2             # arrow size

# textures
var arrow_textures = {
	"left": preload("res://assets/arrows/left_arrow.png"),
	"down": preload("res://assets/arrows/down_arrow.png"),
	"up": preload("res://assets/arrows/up_arrow.png"),
	"right": preload("res://assets/arrows/right_arrow.png")
}

# gameplay vars
var current_score: int = 0
var high_score: int = 0
var spectrum: AudioEffectInstance
var current_track_color: Color = Color.WHITE
var last_arrow_time: float = 0
var effect_index: int = -1
var flash_layer

# cam zoom
func zoom_effect():
	var camera = $Camera2D
	if not camera: 
		return
	
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.02, 1.02), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(camera, "zoom", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

# initializing
func _ready():
	setup_instructions()
	load_high_score()
	update_score_display()
	add_to_group("gameplay")
	setup_audio()
	setup_flash()
	setup_spectrum()

# audio setup
func setup_audio():
	# check if audio player exists
	if audio_player == null:
		audio_player = $Stereo/AudioStreamPlayer2D
		if audio_player == null:
			print("No AudioStreamPlayer2D found, creating one...")
			audio_player = AudioStreamPlayer2D.new()
			add_child(audio_player)

	# load track
	var track_path = GameManager.selected_track if GameManager.selected_track != "" else "res://audio/orange.mp3"
	var track: AudioStream = load(track_path)

	if track:
		audio_player.stream = track

		# increase volume only for green.mp3
		if track_path.ends_with("green.mp3"):
			audio_player.volume_db = 6
		else:
			audio_player.volume_db = 0

		audio_player.play()
		audio_player.finished.connect(_on_audio_finished)
		print("Audio started:", track_path.get_file())
	else:
		print("Error: Could not load audio file")

# flash overlay
func setup_flash():
	var flash_scene = preload("res://scenes/flash.tscn")
	flash_layer = flash_scene.instantiate()
	add_child(flash_layer)

# beat detection
func setup_spectrum():
	var effect = AudioEffectSpectrumAnalyzer.new()
	effect_index = AudioServer.get_bus_effect_count(0)
	AudioServer.add_bus_effect(0, effect, effect_index)
	spectrum = AudioServer.get_bus_effect_instance(0, effect_index)

# fade functionality
func setup_instructions():
	if instructions == null:
		print("Instructions node not found!")
		return
		
	if not GameManager.has_played_before():
		instructions.modulate.a = 0.0
		instructions.visible = true
		
		var fade_in = create_tween()
		fade_in.tween_property(instructions, "modulate:a", 1.0, 1.0)
		fade_in.tween_callback(start_fade_out_timer)
	else:
		instructions.visible = false

func start_fade_out_timer():
	await get_tree().create_timer(3.0).timeout
	fade_out_instructions()

func fade_out_instructions():
	if instructions:
		var fade_out = create_tween()
		fade_out.tween_property(instructions, "modulate:a", 0.0, 1.0)
		fade_out.tween_callback(func(): instructions.visible = false)

# upon track end
func _on_audio_finished():
	await get_tree().create_timer(1.0).timeout
	save_high_score()
	GameManager.mark_gameplay_completed()
	
	if GameManager.get_times_played() == 1:
		SceneTransition.change_scene_to("res://scenes/dialogue.tscn")
	else:
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")

# beat detection + arrow spawning
func _process(delta):
	if spectrum == null or not audio_player.playing:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time < last_arrow_time + arrow_cooldown:
		return
	
	# split freqs into 4 bands
	var bands = {
		"left": get_frequency_band(0, 150),
		"down": get_frequency_band(150, 400),
		"up": get_frequency_band(400, 800),
		"right": get_frequency_band(800, 12000)
	}
	
	# calc total energy
	var total_energy = 0.0
	for value in bands.values():
		total_energy += value * 1000
	
	# spawn arrow if energy passes given threshold
	if total_energy > frequency_threshold:
		var chosen = ""
		var max_energy = 0.0
		
		for dir in bands:
			if bands[dir] > max_energy:
				max_energy = bands[dir]
				chosen = dir
		
		if chosen != "":
			spawn_arrow(chosen)
			last_arrow_time = current_time

# user input
func _input(event):
	if event.is_action_pressed("ui_left"):  check_and_remove_arrow("left")
	if event.is_action_pressed("ui_down"):  check_and_remove_arrow("down")
	if event.is_action_pressed("ui_up"):    check_and_remove_arrow("up")
	if event.is_action_pressed("ui_right"): check_and_remove_arrow("right")

func get_frequency_band(from_hz: float, to_hz: float) -> float:
	return spectrum.get_magnitude_for_frequency_range(from_hz, to_hz).length() if spectrum != null else 0.0

# spawn arrows
func spawn_arrow(direction: String):
	var arrow = Sprite2D.new()
	add_child(arrow)
	arrow.set_meta("direction", direction)

	# texture + scale
	if direction in arrow_textures:
		arrow.texture = arrow_textures[direction]
		arrow.scale = Vector2(arrow_scale, arrow_scale)
	else:
		arrow.queue_free()
		return
	
	# horizontal placement
	var screen_width = get_viewport().get_visible_rect().size.x
	arrow.position.y = -100
	match direction:
		"left":  arrow.position.x = screen_width * 0.4
		"down":  arrow.position.x = screen_width * 0.55
		"up":    arrow.position.x = screen_width * 0.7
		"right": arrow.position.x = screen_width * 0.85
	
	# falling arrows
	var fall_distance = get_viewport().get_visible_rect().size.y + 200
	var tween = create_tween()
	tween.tween_property(arrow, "position:y", fall_distance, beat_lookahead)
	tween.tween_callback(arrow_missed.bind(arrow))
	arrow.set_meta("tween", tween)

# arrow hit/miss functionality
func check_and_remove_arrow(direction: String):
	for arrow in get_children():
		if arrow is Sprite2D and arrow.get_meta("direction") == direction:
			current_score += 1

			# pick flash color based on current track
			print(GameManager.selected_track.get_file())
			match GameManager.selected_track.get_file():
				"red.mp3":
					flash_layer.flash(Color(1, 0, 0))     # red
				"orange.mp3":
					flash_layer.flash(Color(1, 0.5, 0))   # orange
				"yellow.mp3":
					flash_layer.flash(Color(1, 1, 0))     # yellow
				"green.mp3":
					flash_layer.flash(Color(0, 1, 0))     # green
				"blue.mp3":
					flash_layer.flash(Color(0, 0, 1))     # blue
				"purple.mp3":
					flash_layer.flash(Color(0.5, 0, 0.5)) # purple
				_:
					flash_layer.flash(Color(1, 1, 1))     # default white


			if arrow.has_meta("tween"):
				var tween = arrow.get_meta("tween")
				if tween and tween.is_valid(): 
					tween.kill()
			
			arrow.queue_free()
			update_score_display()
			return
	
	# reset score if no existing arrows that match
	current_score = 0
	update_score_display()

func arrow_missed(arrow):
	if is_instance_valid(arrow):
		current_score = 0
		update_score_display()
		arrow.queue_free()
		print("Missed arrow")

# handle score
func update_score_display():
	if not score_label: 
		return
	
	if current_score > high_score:
		high_score = current_score
		GameManager.set_high_score(high_score)
		
	score_label.text = "high score: %d\nscore: %d" % [high_score, current_score]

func load_high_score():
	high_score = GameManager.get_high_score()

func save_high_score():
	if current_score > high_score:
		high_score = current_score
		GameManager.set_high_score(high_score)

# cleanup
func _exit_tree():
	if effect_index >= 0:
		AudioServer.remove_bus_effect(0, effect_index)

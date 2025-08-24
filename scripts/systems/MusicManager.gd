extends Node

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var current_track: String = ""
var should_loop: bool = true

func _ready():
	add_child(audio_player)
	audio_player.finished.connect(_on_music_finished)

func play_music(file_path: String, loop: bool = true):
	print("requested: ", file_path, " // loop: ", loop)
	print("current track: ", current_track)
	print("currently playing: ", audio_player.playing)
	print("should loop: ", should_loop)
	
	if current_track == file_path and audio_player.playing and should_loop == loop:
		print("already playing correct track, returning")
		return
	
	audio_player.stop()
	print("stopped current music")
	
	# Load new music
	var music = load(file_path) as AudioStream
	if not music:
		push_error("could not load music at: " + file_path)
		print("failed to load music file!")
		return
	
	print("loaded music successfully: ", music)
	
	# Set up the stream with loop setting
	if music is AudioStreamOggVorbis or music is AudioStreamMP3:
		music.loop = loop
		print("Set loop to: ", loop)
	
	audio_player.stream = music
	current_track = file_path
	should_loop = loop
	audio_player.play()
	print("started playing music")

func stop_music():
	audio_player.stop()
	current_track = ""
	should_loop = true

func _on_music_finished():
	if not should_loop:
		current_track = ""

func is_playing() -> bool:
	return audio_player.playing

func get_current_track() -> String:
	return current_track

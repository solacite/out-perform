extends Node

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)

func play_music(file_path: String, loop: bool = true):
	var music = load(file_path) as AudioStream
	if not music:
		push_error("could not load music at: " + file_path)
		return

	# only reload if different
	if audio_player.stream == null or audio_player.stream.resource_path != music.resource_path:
		audio_player.stream = music
		music.loop = loop

	if not audio_player.playing:
		audio_player.play()

func stop_music():
	audio_player.stop()

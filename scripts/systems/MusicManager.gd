extends Node

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)

func play_music(file_path: String, loop: bool = true, restart_if_playing: bool = false):
	var music = load(file_path) as AudioStream
	if not music:
		push_error("Could not load music at: " + file_path)
		return

	if audio_player.stream and audio_player.stream.resource_path == music.resource_path:
		if audio_player.playing and not restart_if_playing:
			return
			
	audio_player.stream = music
	music.loop = loop

	audio_player.play()

func stop_music():
	audio_player.stop()

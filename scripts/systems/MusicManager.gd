extends Node

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)

func play_lobby_music():
	var music = load("res://audio/lobby.mp3") as AudioStream
	if audio_player.stream == null or audio_player.stream.resource_path != music.resource_path:
		audio_player.stream = music
		music.loop = true
	
	if not audio_player.playing:
		print("aUDIO PLAYING NOW!!!")
		audio_player.play()

func stop_lobby_music():
	audio_player.stop()

# main menu stuff
extends Node2D

# setting background music
@export var lobby_audio: AudioStream

# find AudioStreamPlayer nodle
@onready var audio_player: AudioStreamPlayer2D = $"/root/Main/AudioStreamPlayer2D"

# triggered when play button pressed
func _on_button_pressed():
	go_to_gameplay()
	
# decides what scene to load
func go_to_gameplay():
	# go to track menu if intro is done
	if GameManager.has_completed_intro() or GameManager.has_completed_second_intro():
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")
	# or start intro dialogue
	else:
		SceneTransition.change_scene_to("res://scenes/dialogue.tscn")

# runs automatically upon scene load
func _ready():
	# check if audio player exists
	if audio_player == null:
		print("Error: Could not find or create AudioStreamPlayer2D")
		return
		
	# play the audio file
	if lobby_audio != null:
		audio_player.stream = lobby_audio
	else:
		var loaded_audio = load("res://audio/lobby.mp3")
		if loaded_audio != null:
			audio_player.stream = loaded_audio
		else:
			print("Error: Could not load audio file")
			return
			
	# start music!!
	audio_player.play()
	print("Audio started playing")

extends Node2D

@export var lobby_audio: AudioStream

@onready var audio_player: AudioStreamPlayer2D = $"/root/Main/AudioStreamPlayer2D"

func _on_button_pressed():
	go_to_gameplay()
	
func go_to_gameplay():
	if GameManager.has_completed_intro() or GameManager.has_completed_second_intro():
		SceneTransition.change_scene_to("res://scenes/track_menu.tscn")
	else:
		SceneTransition.change_scene_to("res://scenes/dialogue.tscn")

func _ready():
	if audio_player == null:
		print("Error: Could not find or create AudioStreamPlayer2D")
		return
		
	if lobby_audio != null:
		audio_player.stream = lobby_audio
	else:
		var loaded_audio = load("res://audio/lobby.mp3")
		if loaded_audio != null:
			audio_player.stream = loaded_audio
		else:
			print("Error: Could not load audio file")
			return
			
	audio_player.play()
	print("Audio started playing")

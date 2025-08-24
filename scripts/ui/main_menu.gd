# main menu stuff
extends Node2D

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
	print("playing lobby music")
	MusicManager.play_music("res://audio/lobby.mp3")

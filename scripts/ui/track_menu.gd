# track selection menu
extends Node2D

# dictionary
var track_map := {
	"Red": "res://audio/red.mp3",
	"Orange": "res://audio/orange.mp3",
	"Yellow": "res://audio/yellow.mp3",
	"Green": "res://audio/green.mp3",
	"Blue": "res://audio/blue.mp3",
	"Purple": "res://audio/purple.mp3",
}

# runs automatically
func _ready():
	# connect signal
	$ColorRect/Red.pressed.connect(func(): _on_track_pressed("Red"))
	$ColorRect/Orange.pressed.connect(func(): _on_track_pressed("Orange"))
	$ColorRect/Yellow.pressed.connect(func(): _on_track_pressed("Yellow"))
	$ColorRect/Green.pressed.connect(func(): _on_track_pressed("Green"))
	$ColorRect/Blue.pressed.connect(func(): _on_track_pressed("Blue"))
	$ColorRect/Purple.pressed.connect(func(): _on_track_pressed("Purple"))

# triggered by track button
func _on_track_pressed(color: String) -> void:
	# get file path
	var track_path = track_map.get(color)
	
	# check if track exists
	if track_path:
		# set track and change scene
		GameManager.selected_track = track_path
		SceneTransition.change_scene_to("res://scenes/gameplay.tscn")
	else:
		# if track is nonexistent
		print("Error: Track not found for color ", color)

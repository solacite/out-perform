extends Node2D

@onready var red_btn: Button = $ColorRect/Red
@onready var orange_btn: Button = $ColorRect/Orange
@onready var yellow_btn: Button = $ColorRect/Yellow
@onready var green_btn: Button = $ColorRect/Green
@onready var blue_btn: Button = $ColorRect/Blue
@onready var purple_btn: Button = $ColorRect/Purple

var track_map := {
	"Red": "res://audio/red.mp3",
	"Orange": "res://audio/orange.mp3",
	"Yellow": "res://audio/yellow.mp3",
	"Green": "res://audio/green.mp3",
	"Blue": "res://audio/blue.mp3",
	"Purple": "res://audio/purple.mp3",
}

func _ready():
	red_btn.pressed.connect(func(): _on_track_pressed("Red"))
	orange_btn.pressed.connect(func(): _on_track_pressed("Orange"))
	yellow_btn.pressed.connect(func(): _on_track_pressed("Yellow"))
	green_btn.pressed.connect(func(): _on_track_pressed("Green"))
	blue_btn.pressed.connect(func(): _on_track_pressed("Blue"))
	purple_btn.pressed.connect(func(): _on_track_pressed("Purple"))

func _on_track_pressed(color: String) -> void:
	var track_path = track_map[color]

	GameManager.selected_track = track_path

	SceneTransition.change_scene_to("res://scenes/gameplay.tscn")

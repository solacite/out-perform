# track selection menu
extends Node2D

@onready var track_scores_parent = $TrackScores
@onready var track_ranks_parent = $TrackRanks
@onready var button_parent = $ColorRect

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
	GameManager.round_ended.connect(update_track_labels)
	update_track_labels()
	get_average_high_score()
	update_message()
	
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
	
	var high_score = GameManager.high_scores.get(color.to_lower(), 0)
	print("Debug: High score for ", color, " track is ", high_score)
	
	# check if track exists
	if track_path:
		# set track and change scene
		GameManager.selected_track = track_path
		SceneTransition.change_scene_to("res://scenes/gameplay.tscn")
	else:
		# if track is nonexistent
		print("Error: Track not found for color ", color)

func get_rank_from_score(score: int) -> String:
	if score >= 300:
		return "SSS"
	elif score >= 250:
		return "SS"
	elif score >= 200:
		return "S"
	elif score >= 150:
		return "A"
	elif score >= 100:
		return "B"
	elif score >= 50:
		return "C"
	elif score >= 25:
		return "D"
	else:
		return "F"

func update_track_labels():
	print("updating track labels!")
	
	var tracks = ["Red", "Orange", "Yellow", "Green", "Blue", "Purple"]
	
	for track_name in tracks:
		var high_score = int(GameManager.high_scores.get(track_name.to_lower(), 0))
		print("high_score", high_score)
		
		var rank = get_rank_from_score(high_score)
		print("rank", rank)
		
		var score_label = track_scores_parent.get_node(track_name)
		print("score_label", score_label)
		var rank_label = track_ranks_parent.get_node(track_name)
		print("rank_label", rank_label)
		
		if score_label:
			score_label.text = str(high_score)
		
		if rank_label:
			rank_label.text = rank

func get_average_high_score() -> int:
	var total_score = 0
	var track_count = 0
	
	for track in GameManager.high_scores:
		total_score += GameManager.high_scores[track]
		track_count += 1
		
	if track_count > 0:
		return int(total_score / track_count)
	else:
		return 0

func update_message():
	var average_score = get_average_high_score()
	var message_label = get_node_or_null("Message")
	
	if not message_label:
		return
		
	var message = ""
	
	if average_score >= 250:
		message = "will you marry me??? (I'm being fr)"
	elif average_score >= 150:
		message = "that resume's looking pretty attractive, dare I say."
	elif average_score >= 50:
		message = "we might take a look at your resume. then again, we might not."
	else:
		message = "this is quite the disappointing resume."
		
	message_label.text = message

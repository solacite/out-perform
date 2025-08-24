extends Node

# consts
const SAVE_FILE: String = "user://savegame.save"

# vars
var high_scores: Dictionary = {}
var times_played: int = 0
var has_played: bool = false
var intro_completed: bool = false
var second_intro_completed: bool = false
var selected_track: String = ""
var is_first_gameplay: bool = false

signal round_ended

# initialization
func _ready():
	clear_save_file()
	load_game()
	
	print("game manager debug on startup")
	print("intro_completed: ", intro_completed)
	print("second_intro_completed: ", second_intro_completed)
	print("has_played: ", has_played)
	print("times_played: ", times_played)
	print("is_first_gameplay: ", is_first_gameplay)
	
	var tracks = ["red", "orange", "yellow", "green", "blue", "purple"]
	for track in tracks:
		if not high_scores.has(track):
			high_scores[track] = 0

# save/load
func clear_save_file():
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE):
		var err = dir.remove(SAVE_FILE)
		if err == OK:
			print("save deleted ok")
		else:
			print("fail del save, err:", err)
	else:
		print("no save file")

func save_game():
	var save_dict = {
		"high_scores": high_scores,
		"times_played": times_played,
		"has_played": has_played,
		"intro_completed": intro_completed,
		"second_intro_completed": second_intro_completed,
		"selected_track": selected_track
	}
	var save_file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if save_file == null:
		printerr("err: cant open save for write")
		return
	save_file.store_string(JSON.stringify(save_dict))
	save_file.close()

func load_game():
	print("loading game")
	if not FileAccess.file_exists(SAVE_FILE):
		print("no save, using defaults")
		is_first_gameplay = true
		return
	var save_file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if save_file == null:
		printerr("err: cant open save for read")
		return
	var json_string: String = save_file.get_as_text()
	save_file.close()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		printerr("err parse save, code:", parse_result)
		return
	var save_dict: Dictionary = json.data
	high_scores = save_dict.get("high_scores", {})
	times_played = save_dict.get("times_played", 0)
	has_played = save_dict.get("has_played", false)
	intro_completed = save_dict.get("intro_completed", false)
	second_intro_completed = save_dict.get("second_intro_completed", false)
	selected_track = save_dict.get("selected_track", "")

# score
func get_high_score() -> int:
	return high_scores.get(selected_track, 0)

func set_high_score(new_score: int):
	if selected_track.is_empty():
		printerr("error: no track selected to save high score.")
		return
	
	if new_score > high_scores.get(selected_track, 0):
		high_scores[selected_track] = new_score
		save_game()

# gameplay track
func has_played_before() -> bool:
	return has_played

func mark_gameplay_completed():
	print("mark gameplay completed")
	print("before - times_played: ", times_played, " has_played: ", has_played)
	
	times_played += 1
	has_played = true
	
	print("after - times_played: ", times_played, " has_played: ", has_played)
	save_game()
	print("game saved")
	
	times_played += 1
	has_played = true
	save_game()

func get_times_played() -> int:
	return times_played

# intro/story
func mark_intro_completed():
	intro_completed = true
	save_game()

func has_completed_intro() -> bool:
	return intro_completed

func mark_second_intro_completed():
	second_intro_completed = true
	is_first_gameplay = false
	save_game()

func has_completed_second_intro() -> bool:
	return second_intro_completed

func get_next_dialogue_branch() -> String:
	print("get next_dialogue_branch debug")
	print("intro_completed: ", intro_completed)
	print("second_intro_completed: ", second_intro_completed)
	
	if not intro_completed:
		print("returning: intro")
		return "intro"
	elif not second_intro_completed:
		print("returning: after_intro")
		return "after_intro"
	else:
		print("returning: empty string")
		return ""

# debug
func force_save():
	save_game()

	mark_gameplay_completed()

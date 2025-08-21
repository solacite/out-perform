extends Node

const SAVE_FILE = "user://savegame.save"

var high_score: int = 0
var times_played: int = 0
var has_played: bool = false
var intro_completed: bool = false

func _ready():
	clear_save_file()
	load_game()

func clear_save_file():
	var save_path = "user://savegame.save"
	var dir = DirAccess.open("user://")
	if dir:
		if dir.remove(save_path) == OK:
			print("Save file deleted successfully.")
		else:
			print("Failed to delete save file.")
	else:
		print("Failed to open user directory.")

func save_game():
	var save_dict = {
		"high_score": high_score,
		"times_played": times_played,
		"has_played": has_played,
		"intro_completed": intro_completed
	}
	
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if save_file == null:
		print("Error: Could not open save file for writing")
		return
	
	var json_string = JSON.stringify(save_dict)
	save_file.store_string(json_string)
	save_file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		print("Save file doesn't exist, using defaults")
		return
	
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if save_file == null:
		print("Error: Could not open save file for reading")
		return
	
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error: Could not parse save file")
		return
	
	var save_dict = json.data
	high_score = save_dict.get("high_score", 0)
	times_played = save_dict.get("times_played", 0)
	has_played = save_dict.get("has_played", false)
	intro_completed = save_dict.get("intro_completed", false)

func get_high_score() -> int:
	return high_score

func set_high_score(new_score: int):
	if new_score > high_score:
		high_score = new_score
		save_game()

func has_played_before() -> bool:
	return has_played

func mark_gameplay_completed():
	times_played += 1
	has_played = true
	save_game()

func get_times_played() -> int:
	return times_played

func force_save():
	save_game()
	
func mark_intro_completed():
	intro_completed = true
	save_game()

func has_completed_intro() -> bool:
	return intro_completed

extends Node

var saved_high_score: int = 0
var gameplay_completed: bool = false
var times_played: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func has_played_before() -> bool:
	return times_played > 0

func mark_gameplay_completed():
	gameplay_completed = true
	times_played += 1
	print("Gameplay completed. Times played: ", times_played)

func reset_game_state():
	gameplay_completed = false
	times_played = 0

func get_times_played() -> int:
	return times_played

func get_high_score() -> int:
	return saved_high_score

func set_high_score(score: int):
	saved_high_score = score
	print("New high score: " + str(score))

extends Control

@onready var image_display: TextureRect = $Image
@onready var timer: Timer = $Timer

var cutscene_frames = [
	{"path": "res://assets/cutscene/Untitled_Artwork-1.png", "duration": 0.5},
	{"path": "res://assets/cutscene/Untitled_Artwork-2.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-3.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-4.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-5.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-6.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-7.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-8.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-9.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-10.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-11.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-12.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-13.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-14.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-15.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-16.png", "duration": 1},
	{"path": "res://assets/cutscene/Untitled_Artwork-17.png", "duration": 0.75},
	{"path": "res://assets/cutscene/Untitled_Artwork-18.png", "duration": 0.75},
	{"path": "res://assets/cutscene/Untitled_Artwork-19.png", "duration": 0.75},
	{"path": "res://assets/cutscene/Untitled_Artwork-20.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-21.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-22.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-23.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-24.png", "duration": 0.1},
	{"path": "res://assets/cutscene/Untitled_Artwork-25.png", "duration": 0.1}
]

var current_frame_index = 0

func _ready():
	MusicManager.play_music("res://audio/intro.mp3", false)
	$Background.visible = true
	timer.timeout.connect(_on_frame_timer_timeout)
	start_cutscene()

func start_cutscene():
	current_frame_index = 0
	_show_current_frame()

func _show_current_frame():
	if current_frame_index == 16:
		$Background.visible = false
		
		var next_scene_packed = preload("res://scenes/main_menu.tscn")
		
		var next_scene_instance = next_scene_packed.instantiate()
		
		get_tree().root.add_child(next_scene_instance)
	
	if current_frame_index >= cutscene_frames.size():
		_finish_cutscene()
		return

	var frame_data = cutscene_frames[current_frame_index]
	var texture = load(frame_data["path"]) as Texture2D
	
	if texture:
		image_display.texture = texture
		print("Showing frame ", current_frame_index + 1, " for ", frame_data["duration"], " seconds")
		
		timer.wait_time = frame_data["duration"]
		timer.start()
	else:
		print("Failed to load texture: ", frame_data["path"])
		_next_frame()

func _on_frame_timer_timeout():
	_next_frame()

func _next_frame():
	timer.stop()
	current_frame_index += 1
	_show_current_frame()
	
func _finish_cutscene():
	hide()
	queue_free()

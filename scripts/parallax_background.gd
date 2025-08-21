extends ParallaxBackground

@export var lobby_audio: AudioStream
@export var parallax_strength: float = 30.0
@export var smoothing: float = 5.0

@onready var audio_player: AudioStreamPlayer2D = $"/root/Main/AudioStreamPlayer2D"

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2
	
	var offset_x = (mouse_pos.x - screen_center.x) / screen_center.x
	var target_offset = Vector2(offset_x * parallax_strength, 0)
	
	scroll_offset = scroll_offset.lerp(target_offset, smoothing * delta)

func _on_button_pressed():
	go_to_gameplay()
	
func go_to_gameplay():
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

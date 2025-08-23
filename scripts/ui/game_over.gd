extends CanvasLayer

@onready var game_over_image: TextureRect = $Background

var game_over_1_texture = preload("res://assets/game_over/game_over_1.png")
var game_over_2_texture = preload("res://assets/game_over/game_over_2.png")

var is_image_1_active = true
var timer: Timer

func _ready():
	game_over_image.texture = game_over_1_texture
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.timeout.connect(switch_image)
	timer.start()

func switch_image():
	if is_image_1_active:
		game_over_image.texture = game_over_2_texture
	else:
		game_over_image.texture = game_over_1_texture
	is_image_1_active = not is_image_1_active

func fade_in(duration := 1.0):
	print("fading game over in")
	game_over_image.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(game_over_image, "modulate:a", 1.0, duration)

func fade_out(duration := 1.0):
	print("fading game over out")
	game_over_image.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(game_over_image, "modulate:a", 0.0, duration)

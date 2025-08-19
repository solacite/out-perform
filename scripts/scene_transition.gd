extends CanvasLayer

@export var streak_textures: Array[Texture2D] = []  # Keep it empty here
@export var num_streaks: int = 15
var is_transitioning: bool = false

func _ready():
	layer = 100
	streak_textures = [
		load("res://assets/streaks/streak1.png"),
		load("res://assets/streaks/streak2.png"),
		load("res://assets/streaks/streak3.png"),
		load("res://assets/streaks/streak4.png"),
		load("res://assets/streaks/streak5.png")
	]

func change_scene_to(scene_path: String):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Dark gray streaks
	spawn_paint_streaks(Color(0.3, 0.3, 0.3), "in")
	await get_tree().create_timer(0.6).timeout
	
	get_tree().change_scene_to_file(scene_path)
	
	# White streaks
	spawn_paint_streaks(Color.WHITE, "out")
	await get_tree().create_timer(0.6).timeout
	
	is_transitioning = false

func spawn_paint_streaks(color: Color, direction: String):
	for i in num_streaks:
		create_paint_streak(color, direction)

func create_paint_streak(color: Color, direction: String):
	if streak_textures.is_empty():
		return
		
	var streak = Sprite2D.new()
	add_child(streak)

	streak.texture = streak_textures[randi() % streak_textures.size()]
	streak.modulate = color

	streak.scale = Vector2(randf_range(1.0, 1.0), randf_range(1.0, 1.0))
	streak.rotation = randf_range(-0.3, 0.3)

	var screen_size = get_viewport().get_visible_rect().size
	var tween = create_tween()

	if direction == "in":
		streak.position = Vector2(randf_range(-1000, -200), randf_range(-1000, screen_size.y + 200))
		tween.tween_property(streak, "position:x", streak.position.x + screen_size.x + 700, randf_range(0.6, 1.0))
	else: 
		streak.position = Vector2(randf_range(screen_size.x + 200, screen_size.x + 500), randf_range(-200, screen_size.y + 200))
		tween.tween_property(streak, "position:x", streak.position.x - screen_size.x - 700, randf_range(0.6, 1.0))

	tween.tween_callback(streak.queue_free)

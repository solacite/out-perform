extends CanvasLayer

@export var streak_textures: Array[Texture2D] = []
@export var num_streaks: int = 8
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

func spawn_paint_wave():
	var screen_size = get_viewport().get_visible_rect().size
	
	for i in num_streaks:
		var streak = Sprite2D.new()
		add_child(streak)
		
		if not streak_textures.is_empty():
			streak.texture = streak_textures[i % streak_textures.size()]
		
		streak.scale = Vector2(1.5, 1.5)
		streak.position = Vector2(-2000, i * (screen_size.y / num_streaks))
		
		var tween = create_tween()
		
		var duration = 0.8
		tween.tween_property(streak, "position:x", screen_size.x + 300, duration)
		
		tween.parallel().tween_property(streak, "modulate:a", 0.0, 0.3).set_delay(0.5)
		
		tween.tween_callback(streak.queue_free)

func change_scene_to(scene_path: String):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	spawn_paint_wave()
	ResourceLoader.load_threaded_request(scene_path)
	
	await get_tree().create_timer(0.4).timeout
	
	var scene_resource = ResourceLoader.load_threaded_get(scene_path)
	get_tree().change_scene_to_file(scene_path)
	
	is_transitioning = false

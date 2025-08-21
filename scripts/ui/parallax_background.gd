extends ParallaxBackground

@export var parallax_strength: float = 30.0
@export var smoothing: float = 5.0

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2
	
	var offset_x = (mouse_pos.x - screen_center.x) / screen_center.x
	var target_offset = Vector2(offset_x * parallax_strength, 0)
	
	scroll_offset = scroll_offset.lerp(target_offset, smoothing * delta)

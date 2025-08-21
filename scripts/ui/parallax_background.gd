# creates parallax effect upon mvmt of mouse
extends ParallaxBackground

# mouse strength
@export var parallax_strength: float = 30.0

# mvmt speed
@export var smoothing: float = 5.0

# runs every frame
func _process(delta):
	# get center of mouse + screen
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2
	
	# calculate dist btwn mouse + center
	var offset_x = (mouse_pos.x - screen_center.x) / screen_center.x
	
	# calc target pos for obj
	var target_offset = Vector2(offset_x * parallax_strength, 0)
	
	# move obj
	scroll_offset = scroll_offset.lerp(target_offset, smoothing * delta)

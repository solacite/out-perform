# visual flash effect
extends CanvasLayer

# reference panel node
@onready var outline: Panel = $Outline

# create + play effect
func flash():
	# new tween for smooth changes
	var tween = create_tween()
	
	# accesss stylebox to change appeaarance
	var stylebox: StyleBoxFlat = outline.get("theme_override_styles/panel")
	
	# set the border color to white.
	stylebox.border_color = Color.WHITE
	
	# anim the border color to orange
	tween.tween_property(stylebox, "border_color", Color(1.0, 0.6, 0.0), 0.2)
	
	# pause anim
	tween.chain().tween_interval(0.2)
	
	# anim back to transparent
	tween.chain().tween_property(stylebox, "border_color", Color.TRANSPARENT, 0.2)
	
	# sends a zoom_effect command nodes in gameplay group to communicate btwn scenes
	get_tree().call_group("gameplay", "zoom_effect")

# visual flash effect
extends CanvasLayer

@onready var outline: Panel = $Outline

# create + play effect
func flash(track_color: Color):
	var tween = create_tween()
	var stylebox: StyleBoxFlat = outline.get("theme_override_styles/panel")

	# start white for "flash"
	stylebox.border_color = Color.WHITE

	# animate into the track’s color
	tween.tween_property(stylebox, "border_color", track_color, 0.2)
	tween.chain().tween_interval(0.2)
	tween.chain().tween_property(stylebox, "border_color", Color.TRANSPARENT, 0.2)

	get_tree().call_group("gameplay", "zoom_effect")

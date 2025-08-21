extends CanvasLayer
@onready var outline: Panel = $Outline
@onready var gameplay_scene = get_viewport().get_node("res://scenes/gameplay.tscn")

func flash():
	var tween = create_tween()
	var stylebox: StyleBoxFlat = outline.get("theme_override_styles/panel")
	stylebox.border_color = Color.WHITE
	tween.tween_property(stylebox, "border_color", Color(1.0, 0.6, 0.0), 0.2)
	tween.chain().tween_interval(0.2)
	tween.chain().tween_property(stylebox, "border_color", Color.TRANSPARENT, 0.2)
	
	get_tree().call_group("gameplay", "zoom_effect")

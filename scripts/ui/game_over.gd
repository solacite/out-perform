extends CanvasLayer

@onready var overlay: ColorRect = $Background
@onready var game_over_label: RichTextLabel = $GameOver

func fade_in(duration := 1.0):
	overlay.modulate.a = 0.0
	game_over_label.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.8, duration)
	tween.tween_property(game_over_label, "modulate:a", 1.0, duration)

func fade_out(duration := 1.0):
	overlay.modulate.a = 0.8
	game_over_label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	tween.tween_property(game_over_label, "modulate:a", 0.0, duration)

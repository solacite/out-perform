# message.gd (script for message.tscn)
extends Node2D

@onready var message_label: RichTextLabel = $Message

var messages = [
	"okay!",
	"alright!",
	"doing good!",
	"crazy!",
	"yeah!",
	"feelin' it!",
	"nice!",
	"good work!"
]

func _ready():
	fade_in()
	
# fade in
func fade_in(duration: float = 0.5):
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
	
# fade out
func fade_out(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)
	
# update text
func set_message(text: String, color: Color):
	message_label.text = text
	message_label.modulate = color

extends Node2D

var message_label: RichTextLabel
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

func _init():
	# Wait for the scene to be ready, then get the node
	call_deferred("setup_message_label")

func setup_message_label():
	message_label = get_node("Message")

func _ready():
	if message_label == null:
		setup_message_label()
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
	if message_label == null:
		setup_message_label()
	
	if message_label != null:
		message_label.text = text
		message_label.modulate = color
	else:
		print("ERROR: Still couldn't find message_label!")

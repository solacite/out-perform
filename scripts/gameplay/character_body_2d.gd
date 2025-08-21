# control sprite anim
extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# timer nodes
@onready var action_timer = Timer.new()
@onready var flash_timer = Timer.new()

# textures for dff states
@export var idle_texture: Texture2D
@export var left_texture: Texture2D
@export var right_texture: Texture2D
@export var up_texture: Texture2D
@export var down_texture: Texture2D

# keep track of displayed texture
var current_action_texture: Texture2D

# runs automatically when the scene loads
func _ready():
	# add action timer
	add_child(action_timer)
	action_timer.wait_time = 0.2
	action_timer.one_shot = true
	action_timer.connect("timeout", _on_action_timeout)

	# add the flash timer
	add_child(flash_timer)
	flash_timer.wait_time = 0.05
	flash_timer.one_shot = true
	flash_timer.connect("timeout", _on_flash_timeout)

	# set idle texture + anim
	if idle_texture:
		sprite.texture = idle_texture
	anim_player.play("idle")

# detects input from player
func _input(event):
	if event.is_action_pressed("ui_left"):
		handle_input(left_texture)
	elif event.is_action_pressed("ui_right"):
		handle_input(right_texture)
	elif event.is_action_pressed("ui_up"):
		handle_input(up_texture)
	elif event.is_action_pressed("ui_down"):
		handle_input(down_texture)

# handles new input action
func handle_input(new_texture: Texture2D):
	# flash effect to idle
	if current_action_texture == new_texture:
		flash_to_idle_then_back(new_texture)
	# change texture to intended
	else:
		change_sprite(new_texture)

# change texture
func change_sprite(new_texture: Texture2D):
	if new_texture:
		anim_player.stop()
		sprite.texture = new_texture
		current_action_texture = new_texture
	
	action_timer.stop()
	action_timer.start()

# when ActionTimer runs out
func _on_action_timeout():
	# back to idle
	if idle_texture:
		sprite.texture = idle_texture
		current_action_texture = null
	anim_player.play("idle")
	
# flash effect
func flash_to_idle_then_back(target_texture: Texture2D):
	if idle_texture:
		sprite.texture = idle_texture
	current_action_texture = target_texture
	flash_timer.start()

# when FlashTimer runs out
func _on_flash_timeout():
	# back to action texture
	if current_action_texture:
		sprite.texture = current_action_texture
	action_timer.stop()
	action_timer.start()

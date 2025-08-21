extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var action_timer = Timer.new()
@onready var flash_timer = Timer.new()

@export var idle_texture: Texture2D
@export var left_texture: Texture2D
@export var right_texture: Texture2D
@export var up_texture: Texture2D
@export var down_texture: Texture2D

var current_action_texture: Texture2D

func _ready():
	add_child(action_timer)
	action_timer.wait_time = 0.2
	action_timer.one_shot = true
	action_timer.connect("timeout", _on_action_timeout)
	
	add_child(flash_timer)
	flash_timer.wait_time = 0.05
	flash_timer.one_shot = true
	flash_timer.connect("timeout", _on_flash_timeout)
	
	if idle_texture:
		sprite.texture = idle_texture
	anim_player.play("idle")

func _input(event):
	if event.is_action_pressed("ui_left"):
		handle_input(left_texture)
	elif event.is_action_pressed("ui_right"):
		handle_input(right_texture)
	elif event.is_action_pressed("ui_up"):
		handle_input(up_texture)
	elif event.is_action_pressed("ui_down"):
		handle_input(down_texture)

func handle_input(new_texture: Texture2D):
	if current_action_texture == new_texture:
		flash_to_idle_then_back(new_texture)
	else:
		change_sprite(new_texture)

func change_sprite(new_texture: Texture2D):
	if new_texture:
		anim_player.stop()
		sprite.texture = new_texture
		current_action_texture = new_texture
	
	action_timer.stop()
	action_timer.start()

func _on_action_timeout():
	if idle_texture:
		sprite.texture = idle_texture
		current_action_texture = null
	anim_player.play("idle")
	
func flash_to_idle_then_back(target_texture: Texture2D):
	if idle_texture:
		sprite.texture = idle_texture
	current_action_texture = target_texture
	flash_timer.start()

func _on_flash_timeout():
	if current_action_texture:
		sprite.texture = current_action_texture
	action_timer.stop()
	action_timer.start()

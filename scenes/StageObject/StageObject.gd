extends Node2D

var tag: String
var data: Dictionary

onready var sprite: AnimatedSprite = $AnimatedSprite

func _ready():
	#init()
	#sprite.position = Vector2(0, 0)
	#self.position = Vector2(-get_width()/2, 264)
	#sprite.animation = "angry"
	pass

func get_width():
	var sprite = $AnimatedSprite
	return sprite.frames.get_frame(sprite.animation, sprite.frame).get_width()

func get_height():
	var sprite = $AnimatedSprite
	return sprite.frames.get_frame(sprite.animation, sprite.frame).get_height()

func set_flip(horizontal: bool = false, vertical: bool = false):
	var sprite = $AnimatedSprite
	sprite.flip_h = horizontal
	sprite.flip_v = vertical

func flip():
	var sprite = $AnimatedSprite
	sprite.flip_h = !sprite.flip_h

func set_animation(animation_name: String):
	var sprite = $AnimatedSprite
	print("set animation has been called, but will it work?")
	print(sprite.frames.animations)
	for animation in sprite.frames.animations:
		if animation.name == animation_name:
			print("changing this one's animation to ", animation_name)
			sprite.animation = animation_name

func init():
	var sprite = $AnimatedSprite
	init_animations()
	sprite.offset.y = -get_height() / 2
	sprite.position = Vector2(0, 0)

func init_animations():
	var sprite = $AnimatedSprite
	sprite.frames = sprite.frames.duplicate(true)
	sprite.frames.clear_all()
	for state in data.states.keys():
		sprite.frames.add_animation(state)
		for state_sprite in data.states[state]:
			sprite.frames.add_frame(state, load(state_sprite))
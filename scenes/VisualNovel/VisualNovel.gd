extends Control

signal passage_interpreted
signal direction_interpreted

var debug_mode: bool = true
var story_index: int = 0

var stage_objects: Array

enum states{
	MENU,
	NOVEL,
	TYPING,
	CHOICES,
	COMBAT,
	EDITOR
}
export(states) var game_state = states.NOVEL

onready var story: Dictionary = $JsonParser.load_data("res://story/story.json")
onready var actors: Dictionary = $JsonParser.load_data("res://story/actors.json")

onready var stage: TextureRect = $Stage
onready var sound_manager: Node = $SoundManager
onready var text_label: RichTextLabel = $FullEnglish/RichTextLabel
onready var choices_box: VBoxContainer = $ChoicesBox

onready var StageObject: = "res://scenes/StageObject/StageObject.tscn"

func _ready():
	story_index = -1
	advance_story()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("action"):
		if game_state == states.NOVEL:
			advance_story()
		elif game_state == states.TYPING:
			game_state = states.NOVEL

# Realistically, this code is very close to falling apart.
# What must be fixed immediately is decoupling the dialog box
# code from the visual novel code, the input code, the passage
# interpretation code, all of these things need to be decoupled
# lest this code become irreparable.
# Following this correction, ensuring a robust state machine is
# the first order of business. And then making choices and jumping
# work. And then... combat, is it? Or backgrounds, advanced teathrics.
# We'll get there.

func change_state(new_state: int):
	match new_state:
		states.MENU:
			game_state = new_state
		states.NOVEL:
			game_state = new_state
		states.TYPING:
			if new_state == states.NOVEL or new_state == states.MENU:
				game_state = new_state
			else:
				print("illegal state ignored: ", game_state, " to ", new_state)
		states.CHOICES:
			game_state = new_state
		states.COMBAT:
			game_state = new_state
		states.EDITOR:
			game_state = new_state
		_:
			print("illegal state defined: ", new_state)
			game_state = new_state

# Text should be renderable on more than just the fullenglish, I require
# cinematic text at the center on an empty background, for dramatic impact.
func render_text(content: String):
	text_label.bbcode_text = content
	text_label.visible_characters = 0
	game_state = states.TYPING
	yield(get_tree().create_timer(0.1), "timeout")
	for character in text_label.text:
		if game_state == states.TYPING:
			yield(get_tree().create_timer(0.01), "timeout")
			text_label.visible_characters += 1
			match character:
				",":
					sound_manager.speak()
					yield(get_tree().create_timer(0.1), "timeout")
				";":
					sound_manager.speak()
					yield(get_tree().create_timer(0.15), "timeout")
				"-":
					sound_manager.speak()
					yield(get_tree().create_timer(0.2), "timeout")
				"—":
					sound_manager.speak()
					yield(get_tree().create_timer(0.2), "timeout")
				".":
					sound_manager.speak()
					yield(get_tree().create_timer(0.2), "timeout")
				"!":
					sound_manager.speak()
					yield(get_tree().create_timer(0.5), "timeout")
				"?":
					sound_manager.speak()
					yield(get_tree().create_timer(0.5), "timeout")
				"\"", " ":
					pass
				_:
					sound_manager.speak()
			if text_label.visible_characters == text_label.bbcode_text.length():
				game_state = states.NOVEL
	game_state = states.NOVEL
	text_label.visible_characters = text_label.bbcode_text.length()

func interpret_passage(passage_index: int):
	var passage = story.passages[passage_index]
	for direction in passage.directions:
		interpret_direction(direction.tag, direction.arguments)
		# yield(self, "direction_interpreted")
		# print("will we ever know peace from these horrors")
	print_passage(passage_index)
	emit_signal("passage_interpreted")

func interpret_direction(tag: String, arguments: Array):
	match tag:
		"enter_stage":
			if arguments.size() >= 3:
				var actor = arguments[0]
				var origin = arguments[1]
				var mark = Vector2(arguments[2], 264)
				print(actor, " enter from ", origin, " to ", mark)
				stage_enter(actor, origin, mark)
		"exit_stage":
			if arguments.size() >= 2:
				var actor = arguments[0]
				var exit = arguments[1]
				print(actor, " exit to ", exit)
				stage_exit(actor, exit)
		"move":
			if arguments.size() >= 2:
				var actor = arguments[0]
				var mark = Vector2(arguments[1], 264)
				print(actor, " move to ", mark)
				stage_move(actor, mark)
		"face":
			if arguments.size() >= 2:
				var actor = arguments[0]
				var mark = arguments[1]
				print(actor, " face ", mark)
				stage_face(actor, mark)
		"act":
			if arguments.size() >= 2:
				var actor = arguments[0]
				var state = arguments[1]
				print(actor, " acts ", state)
				stage_act(actor, state)
		"add_choice":
			if arguments.size() >= 3:
				var choice_text = arguments[0]
				var choice_type = arguments[1]
				var choice_tag = arguments[2]
				add_choice(choice_text, choice_type, choice_tag)
		"remove_choice":
			if arguments.size() >= 1:
				var choice_tag = arguments[0]
				remove_choice(choice_tag)
		"clear_choices":
			clear_choices()
		"display_choices":
			display_choices()
		"hide_choices":
			hide_choices()
		"jump":
			if arguments.size() >= 1:
				var jump_tag = arguments[0]
				jump(jump_tag)
		"jump_index":
			if arguments.size() >= 1:
				var jump_index = arguments[0]
				jump_index(jump_index)
	# print("we are done with this direction.")
	emit_signal("direction_interpreted")

func print_passage(passage_index: int):
	var text_contents = story.passages[passage_index].text
	render_text(text_contents)

func print_passage_dictionary(passage: Dictionary):
	var text_contents: String
	text_contents = passage.text
	render_text(text_contents)

func advance_story():
	story_index = (story_index + 1) % story.passages.size()
	interpret_passage(story_index)
	if debug_mode: print("story_index: ", story_index)

# Stage Directions: Navigation
func jump(passage_tag):
	for index in story.passages.size():
		if story.passages[index].tag == passage_tag:
			story_index = index
			interpret_passage(story_index)
			break

func jump_index(passage_index):
	if passage_index <= story.passages.size():
		story_index = passage_index
		interpret_passage(story_index)

# Stage Directions: Choices
func add_choice(choice_text: String, choice_type: String, choice_tag: String):
	var new_choice = {
		"text": choice_text,
		"type": choice_type,
		"tag": choice_tag
	}
	choices_box.choices.append(new_choice)
	print(choices_box.choices)

func remove_choice(choice_tag: String):
	if choices_box.choices.size() > 0:
		for choice in choices_box.choices:
			if choice.tag == choice_tag:
				choices_box.choices.erase(choice)

func clear_choices():
	choices_box.choices.clear()

func display_choices():
	if !choices_box.visible and choices_box.choices.size() > 0:
		game_state = states.CHOICES
		choices_box.init()
		choices_box.visible = true
	else:
		print("Invalid choices or choices already visible.")

func hide_choices():
	if choices_box.visible:
		choices_box.visible = false

# Stage Directions: Teathrics
func stage_move(actor_tag: String, mark: Vector2):
	var actor = get_actor_by_tag(actor_tag)
	var tween: Tween = actor.get_node("Tween")
	tween.interpolate_property(
		actor,
		"position",
		actor.position,
		mark,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func stage_enter(actor_tag: String, origin: String, mark: Vector2):
	var actor = get_actor_by_tag(actor_tag)
	var origin_x
	var origin_y = 264
	if not actor:
		actor = load(StageObject).instance()
		actor.tag = actor_tag
		actor.data = actors[actor_tag]
		actor.init()
		stage.add_child(actor)
		actor.name = actor_tag
		actor.add_to_group("actors")
	match origin:
		"left":
			origin_x = -actor.get_width() / 2
		"right":
			origin_x = get_viewport_rect().size.x + actor.get_width() / 2
		"bottom":
			origin_x = mark.x
			origin_y += actor.get_height()
		"instant":
			origin_x = mark.x
		_:
			print("illegal origin!")
			return
	actor.position.x = origin_x
	actor.position.y = origin_y
	stage_move(actor_tag, mark)

func stage_exit(actor_tag: String, exit):
	var actor = get_actor_by_tag(actor_tag)
	var target_x
	var target_y = 264
	if not actor: return
	match exit:
		"right":
			target_x = get_viewport_rect().size.x + actor.get_width() / 2 
		"left":
			target_x = -actor.get_width() / 2
		"bottom":
			target_x = actor.position.x
			target_y = actor.get_height()
		_:
			pass
	stage_move(actor_tag, Vector2(target_x, target_y))
	yield(actor.get_node("Tween"), "tween_completed")
	actor.queue_free()

func stage_face(actor_tag: String, mark):
	var actor = get_actor_by_tag(actor_tag)
	if not actor: return
	match mark:
		"right":
			actor.set_flip(false)
		"left":
			actor.set_flip(true)
		"flip":
			actor.flip()
		_:
			var target_actor = get_actor_by_tag(mark)
			if target_actor:
				actor.set_flip(actor.position.x > target_actor.position.x)

func stage_act(actor_tag: String, state: String):
	var actor = get_actor_by_tag(actor_tag)
	if not actor: return
	print("requesting animation change")
	actor.set_animation(state)

func get_actor_by_tag(actor_tag: String):
	for actor in get_tree().get_nodes_in_group("actors"):
		if actor.tag == actor_tag:
			return actor
	return false
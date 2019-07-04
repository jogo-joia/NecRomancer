extends Control

signal started_typing
signal finished_typing
signal interrupted_typing
signal resume_typing

const default_typing_frequency = 0.025

enum states {
	STANDBY,		# Awaiting input
	TYPING,			# Input transitions to standby
	CHOICETYPING,	# Typing, but ignores input
	SLEEPING		# Ignoring input
} 

export(states) var state = states.STANDBY
var manager: String
var skipping: bool = false

onready var dialog_label: RichTextLabel = $DialogLabel
onready var sound_manager: Node = $SoundManager

func _ready() -> void:
	# works fine without the newlines
	# output("[b]A personable stranger says,[/b]\n\"Hello... I am... the dreaded{;} {s=realization}{>}[b]Necromancer[/b]{<}! I am here today to deliver exposition on a T{;}E{;}R{;}R{;}I{;}B{;}L{;}E{;} subject... it is the:{;}{,} [b]{s=damage}{>}WAR{.} {s=damage}ON{.} {s=damage}DRUGS[/b]{<}.{.} It is destroying this nation.\"")
	pass

func init() -> void:
	pass

func output(message: String):
	var output_stack = process_passage_text(message)
	render_text(output_stack)

func process_passage_text(passage_text: String) -> Array:
	var output_stack: Array = []
	var shortcode_size: int
	var bbcode_size: int
	var is_interpreting_shortcode: bool = false
	var is_interpreting_bbcode: bool = false
	for index in passage_text.length():
		if passage_text[index] == "{":
			var closing_index = passage_text.find("}", index) + 1
			var shortcode: String
			shortcode_size = -1
			is_interpreting_shortcode = true
			for shortcode_index in range(index, closing_index):
				shortcode += passage_text[shortcode_index].to_lower()
				shortcode_size += 1
			output_stack.append(shortcode)
		elif is_interpreting_shortcode:
			shortcode_size -= 1
			if shortcode_size == 0:
				is_interpreting_shortcode = false
		elif passage_text[index] == "[":
			var closing_index = passage_text.find("]", index) + 1
			var bbcode: String
			bbcode_size = -1
			is_interpreting_bbcode = true
			for bbcode_index in range(index, closing_index):
				bbcode += passage_text[bbcode_index].to_lower()
				bbcode_size += 1
			output_stack.append(bbcode)
		elif is_interpreting_bbcode:
			bbcode_size -= 1
			if bbcode_size == 0:
				is_interpreting_bbcode = false
		else:
			output_stack.append(passage_text[index])
	output_stack = process_replacements(output_stack)
	return output_stack

func process_replacements(output_stack: Array) -> Array:
	var new_output_stack: Array = []
	for stack_string in output_stack:
		if stack_string.length() > 1:
			match stack_string[1]:
				"g":
					pass
				"v":
					var requested_variable: String
					var variable_content: String
					for index in range(3, stack_string.length() - 1):
						requested_variable += stack_string[index]
					variable_content = owner.story.variables[int(requested_variable)]
					for index in variable_content.length():
						new_output_stack.append(variable_content[index])
				"n":
					pass
				"p":
					pass
				"c":
					pass
				_:
					new_output_stack.append(stack_string)
		else:
			new_output_stack.append(stack_string)
	return new_output_stack

func interpret_shortcode(shortcode: String):
	yield(get_tree(), "idle_frame")
	if shortcode[0] != "[":
		match shortcode[1]:
			"s": # Plays sound x.
				var requested_sound: String
				for index in range(3, shortcode.length() - 1):
					requested_sound += shortcode[index]
				sound_manager.play_and_forget(requested_sound)
			",": # Wait 0.1 second.
				yield(get_tree().create_timer(0.1), "timeout")
			";": # Wait 0.25 second.
				yield(get_tree().create_timer(0.25), "timeout")
			".": # Wait 1 second.
				yield(get_tree().create_timer(1), "timeout")
			">": # Instantly outputs subsequent text.
				skipping = true
			"<": # Suspends instant output for subsequent text.
				skipping = false
			"^": # Don't wait for input after displaying text.
				pass
			_:
				print("[DialogBox.gd] interpret_shortcode: Invalid shortcode. (", shortcode, ")")
	return

func output_to_string(output_stack: Array) -> String:
	var content: String
	for index in output_stack.size():
		if output_stack[index].length() > 1:
			if output_stack[index][0] == "[":
				content += output_stack[index]
		else:
			content += output_stack[index]
	return content

func render_text(output_stack: Array):
	var content: String = output_to_string(output_stack)
	var typing_frequency: float = default_typing_frequency
	dialog_label.bbcode_text = content
	dialog_label.visible_characters = 0
	content = dialog_label.text
	state = states.TYPING
	yield(get_tree().create_timer(0.1), "timeout")
	for index in output_stack.size():
		if state == states.TYPING and output_stack[index].length() == 1 and output_stack[index] != "\n":
			if not skipping:
				yield(get_tree().create_timer(typing_frequency), "timeout")
			dialog_label.visible_characters += 1
			var is_ending = bool(dialog_label.visible_characters - dialog_label.text.length() == -3)
			if not skipping: match output_stack[index]:
				",":
					sound_manager.speak()
					yield(get_tree().create_timer(0.1), "timeout")
				";":
					sound_manager.speak()
					yield(get_tree().create_timer(0.15), "timeout")
				"-":
					sound_manager.speak()
					yield(get_tree().create_timer(typing_frequency), "timeout")
				"—":
					sound_manager.speak()
					yield(get_tree().create_timer(0.2), "timeout")
				".":
					sound_manager.speak()
					if !is_ending:
						yield(get_tree().create_timer(0.2), "timeout")
				"!":
					sound_manager.speak()
					yield(get_tree().create_timer(0.5), "timeout")
				"?":
					sound_manager.speak()
					yield(get_tree().create_timer(0.5), "timeout")
				"\"":
					sound_manager.speak()
				" ", "	":
					pass
				"\n":
					pass
				_:
					sound_manager.speak()
			if dialog_label.visible_characters == dialog_label.bbcode_text.length():
				state = states.STANDBY
		elif output_stack[index][0] == "{":
			# print("Shortcode triggered: ", output_stack[index])
			yield(interpret_shortcode(output_stack[index]), "completed")
	skipping = false
	state = states.STANDBY
	dialog_label.visible_characters = dialog_label.bbcode_text.length()
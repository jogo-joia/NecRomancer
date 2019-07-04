extends VBoxContainer

const _choice: Dictionary = {"text": "", "type": "", "tag": ""}

var choices: Array = []

onready var ChoiceButton = preload("res://scenes/ChoicesBox/ChoiceButton/ChoiceButton.tscn")

func _ready():
	init()

func init():
	for child in get_children():
		child.queue_free()
	for choice in choices:
		var new_choice_button: Button = ChoiceButton.instance()
		new_choice_button.text = choice.text
		new_choice_button.tag = choice.tag
		add_child(new_choice_button)
		new_choice_button.connect("pressed", self, "_on_option_pressed", [new_choice_button.tag])

func _on_option_pressed(tag: String):
	if tag.length() > 0:
		print("Selected Option: ", tag)
	else:
		print("Invalid button.")

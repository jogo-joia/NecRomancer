extends Control

# const Story: Resource = preload("res://resources/Story.gd")
# const Passage: Resource = preload("res://resources/Passage.gd")
const Story: Dictionary = {
	"title": "",
	"version": "",
	"description": "",
	"id": "",
	"author": "",
	"email": "",
	"website": "",
	"passages": []
}
const Passage: Dictionary = {
	"tag": "",
	"text": "",
	"voice": "",
	"directions": []
}
const Direction: Dictionary = {
	"tag": "",
	"arguments": []
}

var current_passage: int = 0
var current_direction: int = 0
var current_argument: int = 0
var save_or_load: String = "save"
var save_load_path: String

onready var current_story: Dictionary = Story.duplicate(true)
onready var story_editor: Control = $PBg/Parallax/StoryEditor
onready var passage_editor: Control = $PBg/Parallax/PassageEditor
onready var voice_editor: Control = $PBg/Parallax/VoiceEditor
onready var file_dialog: FileDialog = $PBg/Parallax/FileDialog

# StoryEditor node paths
onready var title_edit: LineEdit = $PBg/Parallax/StoryEditor/TitleLineEdit
onready var version_edit: LineEdit = $PBg/Parallax/StoryEditor/VersionLineEdit
onready var description_edit: LineEdit = $PBg/Parallax/StoryEditor/DescriptionLineEdit
onready var id_edit: LineEdit = $PBg/Parallax/StoryEditor/IdLineEdit
onready var author_edit: LineEdit = $PBg/Parallax/StoryEditor/AuthorLineEdit
onready var email_edit: LineEdit = $PBg/Parallax/StoryEditor/EmailLineEdit
onready var website_edit: LineEdit = $PBg/Parallax/StoryEditor/WebsiteLineEdit

# PassageEditor node paths
onready var text_edit: TextEdit = $PBg/Parallax/PassageEditor/TextEdit
onready var passages_list: ItemList = $PBg/Parallax/PassageEditor/PassagesList
onready var tag_edit: LineEdit = $PBg/Parallax/PassageEditor/TagLineEdit
onready var voice_edit: LineEdit = $PBg/Parallax/PassageEditor/VoiceLineEdit
onready var directions_list: ItemList = $PBg/Parallax/PassageEditor/DirectionsList
onready var arguments_list: ItemList = $PBg/Parallax/PassageEditor/DirectionArgumentsList
onready var direction_tag_edit: LineEdit = $PBg/Parallax/PassageEditor/DirectionTagLineEdit
onready var argument_string_edit: LineEdit = $PBg/Parallax/PassageEditor/ArgumentStringLineEdit

# PassageEditor LinkButtons
onready var add_pass_btn: LinkButton = $PBg/Parallax/PassageEditor/AddPassBtn
onready var remove_pass_btn: LinkButton = $PBg/Parallax/PassageEditor/RemovePassBtn
onready var add_direction_btn: LinkButton = $PBg/Parallax/PassageEditor/AddDirectionBtn
onready var remove_direction_btn: LinkButton = $PBg/Parallax/PassageEditor/RemoveDirectionBtn
onready var add_argument_btn: LinkButton = $PBg/Parallax/PassageEditor/AddArgumentBtn
onready var remove_argument_btn: LinkButton = $PBg/Parallax/PassageEditor/RemoveArgumentBtn

func _ready():
	resize_window()
	add_passage()
	update_ui()

func resize_window():
	# Doubles the window's width to fit the editor
	get_tree().set_screen_stretch(0, 0, Vector2(1, 1))
	OS.set_window_size(Vector2(1024, 424))
	get_tree().set_screen_stretch(1, 1, Vector2(1024, 424))
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

# Story Data Management
func add_passage():
	var new_passage: Dictionary = Passage.duplicate(true)
	var passages: Array = current_story.passages
	if passages.size() > 0:
		passages.insert(current_passage + 1, new_passage)
		current_passage += int(passages.size() > 1)
	else:
		passages.insert(0, new_passage)
		current_passage = 0

func remove_passage():
	var passages: Array = current_story.passages
	if passages.size() > 1:
		passages.remove(current_passage)
		if current_passage <= passages.size():
			current_passage = max(current_passage - 1, 0)

func add_direction():
	var new_direction: Dictionary = Direction.duplicate(true)
	var passages: Array = current_story.passages
	var directions: Array = passages[current_passage].directions 
	if passages.size() > 0:
		if directions.size() > 0:
			directions.insert(current_direction +1, new_direction)
			current_direction += int(directions.size() > 1)
		else:
			directions.insert(0, new_direction)
			current_direction = 0

func remove_direction():
	var passages: Array = current_story.passages
	var directions: Array = passages[current_passage].directions
	if directions.size() > 0:
		directions.remove(current_direction)
		if current_direction <= directions.size():
			current_direction = max(current_passage - 1, 0)

func add_argument():
	var new_argument: String = ""
	var passages: Array = current_story.passages
	var directions: Array = passages[current_passage].directions
	var arguments: Array = directions[current_direction].arguments
	if passages.size() > 0 and directions.size() > 0:
		if arguments.size() > 0:
			arguments.insert(current_argument + 1, new_argument)
			current_argument += int(arguments.size() > 1)
		else:
			arguments.insert(0, new_argument)
			current_argument = 0

func remove_argument():
	var passages: Array = current_story.passages
	var directions: Array = passages[current_passage].directions
	var arguments: Array = directions[current_direction].arguments
	if passages.size() > 0:
		if directions.size() > 0:
			if arguments.size() > 0:
				arguments.remove(current_argument)
				if current_argument <= arguments.size():
					current_argument = max(current_passage - 1, 0)

#UI Management
func update_lines():
	var targets = get_tree().get_nodes_in_group("NecRomEdit_line")
	for line in targets:
		line.text = ""
	title_edit.text = current_story.title
	version_edit.text = current_story.version
	description_edit.text = current_story.description
	id_edit.text = current_story.id
	author_edit.text = current_story.author
	email_edit.text = current_story.email
	website_edit.text = current_story.website
	if current_story.passages.size() > 0:
		var passage_item: Passage = current_story.passages[current_passage]
		text_edit.text = passage_item.text
		tag_edit.text = passage_item.tag
		voice_edit.text = passage_item.voice
		if passage_item.directions.size() > 0:
			var direction_item: Dictionary = passage_item.directions[current_direction]
			direction_tag_edit.text = direction_item.tag
			if direction_item.arguments.size() > 0:
				argument_string_edit.text = direction_item.arguments[current_argument]

func update_passages_list():
	passages_list.clear()
	if current_story.passages.size() <= 0:
		current_passage = 0
		return
	for index in current_story.passages.size():
		var item: Passage = current_story.passages[index]
		var item_title: String
		var item_tag: String = item.tag
		var item_text: String = item.text
		if item_tag.length() > 0:
			item_title = "%04d: [{0}] {1}".format([item_tag, item_text]) % index
		else:
			item_title = "%04d: {0}".format([item_text]) % index
		passages_list.add_item(item_title)
	if current_passage > passages_list.items.size():
		current_passage = 0
	if passages_list.items.size() > 0:
		passages_list.select(current_passage)
		passages_list.ensure_current_is_visible()

func update_directions_list():
	directions_list.clear()
	if current_story.passages.size() <= 0:
		current_passage = 0
		return
	elif current_story.passages[current_passage].directions.size() <= 0:
		current_direction = 0
		return
	for index in current_story.passages[current_passage].directions.size():
		var item: Dictionary = current_story.passages[current_passage].directions[index]
		var item_title: String
		var item_tag: String = item.tag
		var item_arguments: String = ""
		if current_story.passages[current_passage].directions[index].arguments.size() > 0:
			for argument in current_story.passages[current_passage].directions[index].arguments:
				item_arguments += ", " + argument
		item_title = "%04d: {0}{1}".format([item_tag, item_arguments]) % index
		directions_list.add_item(item_title)
	if current_direction > directions_list.items.size():
		current_direction = 0
	if directions_list.items.size() > 0:
		directions_list.select(current_direction)
		directions_list.ensure_current_is_visible()

func update_arguments_list():
	arguments_list.clear()
	if current_story.passages.size() <= 0:
		current_passage = 0
		return
	elif current_story.passages[current_passage].directions.size() <= 0:
		current_direction = 0
		return
	elif current_story.passages[current_passage].directions[current_direction].arguments.size() <= 0:
		current_argument = 0
		return
	for index in current_story.passages[current_passage].directions[current_direction].arguments.size():
		var item: String = current_story.passages[current_passage].directions[current_direction].arguments[index]
		var item_title: String
		item_title = "%04d: {0}".format([item]) % index
		arguments_list.add_item(item_title)
	if current_argument > arguments_list.items.size():
		current_argument = 0
	if arguments_list.items.size() > 0:
		arguments_list.select(current_argument)
		arguments_list.ensure_current_is_visible()

func update_buttons():
	if current_story.passages.size() > 0:
		text_edit.readonly = false
		tag_edit.editable = true
		remove_pass_btn.disabled = false
		add_direction_btn.disabled = false
		if current_story.passages[current_passage].directions.size() > 0:
			direction_tag_edit.editable = true
			remove_direction_btn.disabled = false
			add_argument_btn.disabled = false
			if current_story.passages[current_passage].directions[current_direction].arguments.size() > 0:
				remove_argument_btn.disabled = false
				argument_string_edit.editable = true
			else:
				remove_argument_btn.disabled = true
				argument_string_edit.editable = false
		else:
			argument_string_edit.editable = false
			direction_tag_edit.editable = false
			remove_direction_btn.disabled = true
			add_argument_btn.disabled = true
			remove_argument_btn.disabled = true
	else:
		text_edit.readonly = true
		tag_edit.editable = false
		direction_tag_edit.editable = false
		argument_string_edit.editable = false
		remove_pass_btn.disabled = true
		add_direction_btn.disabled = true
		remove_direction_btn.disabled = true
		add_argument_btn.disabled = true
		remove_argument_btn.disabled = true

func update_preview():
	if current_story.passages.size() > 0:
		if current_story.passages[current_passage].text.length() > 0:
			$VisualNovel.print_passage_dictionary(current_story.passages[current_passage])

func update_ui(line: = true):
	update_passages_list()
	update_directions_list()
	update_arguments_list()
	if line:
		update_lines()
	update_buttons()
	update_preview()

## THE UI ##
# Upper navigation
func _on_StoryBtn_pressed() -> void:
	passage_editor.visible = false
	voice_editor.visible = false
	story_editor.visible = true
	update_ui()

func _on_PassagesBtn_pressed() -> void:
	story_editor.visible = false
	voice_editor.visible = false
	passage_editor.visible = true
	update_ui()

func _on_VoicesBtn_pressed() -> void:
	story_editor.visible = false
	passage_editor.visible = false
	voice_editor.visible = true
	update_ui()


func _on_LoadStoryBtn_pressed() -> void:
	save_or_load = "load"
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.popup()
	update_ui()

func _on_SaveStoryBtn_pressed() -> void:
	save_or_load = "save"
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup()
	update_ui()

func _on_FileDialog_file_selected(path: String) -> void:
	save_load_path = path
	if save_or_load == "load":
		# current_story = $StorySaver.load_story(path).duplicate(true)
		current_story = $JsonParser.load_data(path).duplicate(true)
		print(save_load_path)
	elif save_or_load == "save":
		# $StorySaver.save(current_story.duplicate(true), path)
		$JsonParser.write_data(current_story.duplicate(true), path)
		print(save_load_path)
	update_ui()

# StoryEditor
func _on_TitleLineEdit_text_changed(new_text: String) -> void:
	current_story.title = new_text
	update_ui(false)

func _on_VersionLineEdit_text_changed(new_text: String) -> void:
	current_story.version = new_text
	update_ui(false)

func _on_DescriptionLineEdit_text_changed(new_text: String) -> void:
	current_story.description = new_text
	update_ui(false)

func _on_IdLineEdit_text_changed(new_text: String) -> void:
	current_story.id = new_text
	update_ui(false)

func _on_AuthorLineEdit_text_changed(new_text: String) -> void:
	current_story.author = new_text
	update_ui(false)

func _on_EmailLineEdit_text_changed(new_text: String) -> void:
	current_story.email = new_text
	update_ui(false)

func _on_WebsiteLineEdit_text_changed(new_text: String) -> void:
	current_story.website = new_text
	update_ui(false)

# PassageEditor
func _on_TextEdit_text_changed() -> void:
	var new_text = $PBg/Parallax/PassageEditor/TextEdit.text
	if current_story.passages.size() > 0:
		current_story.passages[current_passage].text = new_text
	update_ui(false)

func _on_AddPassBtn_pressed() -> void:
	add_passage()
	update_ui()

func _on_RemovePassBtn_pressed() -> void:
	remove_passage()
	update_ui()

func _on_PassagesList_item_selected(index: int) -> void:
	current_passage = index
	current_direction = 0
	current_argument = 0
	update_ui()

func _on_TagLineEdit_text_changed(new_text: String) -> void:
	if current_story.passages.size() > 0:
		current_story.passages[current_passage].tag = new_text
	update_ui(false)

func _on_VoiceLineEdit_text_changed(new_text: String) -> void:
	if current_story.passages.size() > 0:
		current_story.passages[current_passage].voice = new_text
	update_ui(false)

func _on_AddDirectionBtn_pressed() -> void:
	add_direction()
	update_ui()

func _on_RemoveDirectionBtn_pressed() -> void:
	remove_direction()
	update_ui()

func _on_DirectionsList_item_selected(index: int) -> void:
	current_direction = index
	current_argument = 0
	update_ui()

func _on_AddArgumentBtn_pressed() -> void:
	add_argument()
	update_ui()

func _on_RemoveArgumentBtn_pressed() -> void:
	remove_argument()
	update_ui()

func _on_DirectionArgumentsList_item_selected(index: int) -> void:
	current_argument = index
	update_ui()	

func _on_DirectionTagLineEdit_text_changed(new_text: String) -> void:
	if (current_story.passages.size() > 0 and
	current_story.passages[current_passage].directions.size() > 0):
			current_story.passages[current_passage].directions[current_direction].tag = new_text
	update_ui(false)

func _on_ArgumentStringLineEdit_text_changed(new_text: String) -> void:
	if (current_story.passages.size() > 0 and
	current_story.passages[current_passage].directions.size() > 0 and
	current_story.passages[current_passage].directions[current_direction].arguments.size() > 0):
		current_story.passages[current_passage].directions[current_direction].arguments[current_argument] = new_text
	update_ui(false)
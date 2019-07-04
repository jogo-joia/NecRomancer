extends Node
class_name StorySaver

const Story: Resource = preload("res://resources/Story.gd")
var SAVE_FOLDER: String = "res://debug/save"
var TEMPLATE: String = "save_%03d.tres"

func save(story_data: Resource, path: String):
	var directory: = Directory.new()
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)
	var save_path = path
	var error: int = ResourceSaver.save(save_path, story_data)
	if error != OK:
		print("Error saving file: ", error)

func load_story(path: String):
	return ResourceLoader.load(path)
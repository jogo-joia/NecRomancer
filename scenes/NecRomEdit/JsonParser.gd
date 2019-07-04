extends Node
class_name JsonParser

onready var file = File.new()
onready var directory = Directory.new()

func load_data(path: String):
	print(path)
	if path == null:
		return
	if not file.file_exists(path):
		return
	file.open(path, File.READ)
	
	var data = {}
	data = parse_json(file.get_as_text())
	file.close()
	
	return data

func write_data(dict: Dictionary, path: String):
	if path == null:
		return
	file.open(path, File.WRITE)
	
	file.store_line(to_json(dict))
	file.close()

func mkdir(path):
	if directory.open(path) == OK:
		print("JsonParser.mkdir(): Directory '%s' already exists" % path)
		return -1
	else:
		directory.make_dir(path)

func mkdir_recursive(path):
	if directory.open(path) == OK:
		print("JsonParser.mkdir_recursive(): Directory '%s' already exists." % path)
		return -1
	else:
		directory.make_dir_recursive(path)
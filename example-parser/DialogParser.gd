extends Node

export (PackedScene) var choice_button_pack
export (NodePath) var dialog_choices_vbox_node_path
export (NodePath) var character_node_path

onready var dialog_choices_vbox_node = get_node(dialog_choices_vbox_node_path)
onready var character_node = get_node(character_node_path)

var dialog_dict: Dictionary = {}

func _ready():
	var dialog_file: File = File.new()
	dialog_file.open("res://dialog.json", File.READ)
	dialog_dict = parse_json(dialog_file.get_as_text())
	dialog_file.close()
	print(dialog_dict)
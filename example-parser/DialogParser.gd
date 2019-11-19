extends Node

export (PackedScene) var choice_button_pack
export (NodePath) var dialog_choices_vbox_node_path
export (NodePath) var character_node_path
export (NodePath) var status_label_path

onready var dialog_choices_vbox_node = get_node(dialog_choices_vbox_node_path)
onready var character_node = get_node(character_node_path)
onready var status_label = get_node(status_label_path)

var dialog_dict: Dictionary = {}

var cur_state: String = "0" setget set_cur_state

func set_cur_state(new_cur_state):
	cur_state = new_cur_state
	status_label.text = dialog_dict[cur_state]["state"]
	character_node.text = dialog_dict[cur_state]["text"]
	for choice in dialog_choices_vbox_node.get_children():
		choice.queue_free()
	for choice_text in dialog_dict[cur_state]["choices"].keys():
		var cur_dialog_choice: Button = choice_button_pack.instance()
		cur_dialog_choice.text = choice_text
		cur_dialog_choice.connect("pressed", self, "choice_button_pressed", [dialog_dict[cur_state]["choices"][choice_text]])
		dialog_choices_vbox_node.add_child(cur_dialog_choice)

func choice_button_pressed(new_state):
	self.cur_state = new_state[0]

func _ready():
	var dialog_file: File = File.new()
	dialog_file.open("res://dialog.json", File.READ)
	dialog_dict = parse_json(dialog_file.get_as_text())
	dialog_file.close()
#	print(dialog_dict["0"])
	self.cur_state = "0"

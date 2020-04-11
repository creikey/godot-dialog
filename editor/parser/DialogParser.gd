extends Control

export (NodePath) var dialog_label_path
export (NodePath) var emotion_label_path
export (NodePath) var event_label_path
export (NodePath) var choice_button_hbox_path
export (PackedScene) var choice_button

onready var dialog_label = get_node(dialog_label_path)
onready var emotion_label = get_node(emotion_label_path)
onready var event_label = get_node(event_label_path)
onready var choice_button_hbox = get_node(choice_button_hbox_path)

var state = "0" setget set_state
var last_choices: Dictionary = {}

var cur_dict: Dictionary = {}

func set_state(new_state):
	state = new_state

	for c in choice_button_hbox.get_children():
		c.queue_free()
	
	if state == "0":
		return
	if cur_dict[state].has("event"):
		event_label.visible = true
		event_label.text = cur_dict[state]["event"]
	else:
		dialog_label.scrolling_text = cur_dict[state]["text"]
		emotion_label.text = cur_dict[state]["state"]
	
	
	
	var choices_to_add: Dictionary = {}
	
	if cur_dict[state].has("next"):
		choices_to_add = {"continue" : cur_dict[state]["next"]}
	elif typeof(cur_dict[state]["choices"]) == TYPE_STRING and cur_dict[state]["choices"] == "inherit": # inherit
		choices_to_add = last_choices
	else:
		choices_to_add = cur_dict[state]["choices"]
		last_choices = choices_to_add.duplicate(true)
	
	for choice in choices_to_add.keys():
		var cur_button: Button = choice_button.instance()
		cur_button.text = choice
# warning-ignore:return_value_discarded
		cur_button.connect("pressed", self, "_choice_button_pressed", [choices_to_add[choice]])
		choice_button_hbox.add_child(cur_button)

func _choice_button_pressed(next_state):
	event_label.visible = false
	self.state = next_state


func act_out_dict(d: Dictionary):
	cur_dict = d
	self.state = "1"

func _on_GraphEdit_to_run_dict(dict):
	act_out_dict(dict)

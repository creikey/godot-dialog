extends GraphNode

class_name EventGraphNode

const editor_state = preload("res://editor_state.tres")

var text = "" setget set_text,get_text

func set_text(new_text):
	text = new_text
	if has_node("LineEdit"):
		$LineEdit.text = text

func get_text():
	if has_node("LineEdit"):
		return $LineEdit.text
	return text

func _ready():
	set_slot(0, true, 0, editor_state.state_color, true, 0, editor_state.state_color)

func connected(_from: StateStubGraphNode):
	pass

func disconnected(_from: StateStubGraphNode):
	pass

func _on_EventGraphNode_close_request():
	get_parent().disconnect_all(name)
	queue_free()


func _on_LineEdit_text_changed(new_text):
	if new_text == "":
		title = "Event"
		return
	title = new_text


func _on_EventGraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_EventGraphNode_sort_children():
	rect_size.y = 0.0

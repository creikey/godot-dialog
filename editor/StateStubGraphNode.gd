extends GraphNode

class_name StateStubGraphNode

const editor_state = preload("res://editor_state.tres")

# warning-ignore:unused_class_variable
var state: String = "" setget set_state_text,get_state_text
# warning-ignore:unused_class_variable
var text: String = "" setget set_text,get_text

func _ready():
	set_slot(0, true, 0, editor_state.state_color, true, 0, editor_state.state_color)

func get_text() -> String:
	return $TextLineEdit.text

func set_text(new_text):
	text = new_text
	if has_node("TextLineEdit"):
		$TextLineEdit.text = text

func get_state_text() -> String:
	return $StateLineEdit.text

func set_state_text(new_state_text):
	state = new_state_text
	if has_node("StateLineEdit"):
		$StateLineEdit.text = new_state_text

func connected(_from: StateStubGraphNode):
	pass

func disconnected(_from: StateStubGraphNode):
	pass


func _on_StateStubGraphNode_close_request():
	get_parent().disconnect_all(name)
	queue_free()


func _on_StateStubGraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_TextLineEdit_text_changed(new_text):
	title = new_text

func _on_StateStubGraphNode_sort_children():
	rect_size.y = 0

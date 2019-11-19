extends GraphNode

const editor_state = preload("res://editor_state.tres")

var choices: Array = []

func _ready():
	set_slot(0, true, 0, editor_state.state_color, false, 0, Color())

func _on_IncrementButton_pressed():
	var cur_line_edit: LineEdit = LineEdit.new()
	cur_line_edit.placeholder_text = "choice"
	cur_line_edit.expand_to_text_length = true
	choices.append(cur_line_edit)
	add_child(cur_line_edit)
	set_slot(2 + choices.size(), false, 0, Color(), true, 0, editor_state.state_color)


func _on_DecrementButton_pressed():
	if choices.size() <= 0:
		return
	clear_slot(2 + choices.size())
	choices[choices.size() - 1].queue_free()
	choices.remove(choices.size() - 1)

func _on_StateGraphNode_close_request():
	queue_free()
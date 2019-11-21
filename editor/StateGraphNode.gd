extends GraphNode

const editor_state = preload("res://editor_state.tres")
const notice_label_pack = preload("res://NoticeLabel.tscn")

var choices: Array = []
var notice_label = null
export var is_initial: bool = false
onready var choices_index: int = get_children().size() - 1

func _ready():
	update_notice_label()
	set_slot(0, true, 0, editor_state.state_color, false, 0, Color())

func _on_IncrementButton_pressed():
	var cur_line_edit: LineEdit = LineEdit.new()
	cur_line_edit.placeholder_text = "choice"
	cur_line_edit.expand_to_text_length = true
	choices.append(cur_line_edit)
	update_notice_label()
	add_child(cur_line_edit)
	set_slot(choices_index + choices.size(), false, 0, Color(), true, 0, editor_state.state_color)

func _on_DecrementButton_pressed():
	if choices.size() <= 0:
		return
	clear_slot(choices_index + choices.size())
	choices[choices.size() - 1].queue_free()
	choices.remove(choices.size() - 1)
	update_notice_label()

func _on_StateGraphNode_close_request():
	queue_free()

func update_notice_label():
	if is_initial:
		return
	if choices.size() > 0:
		if notice_label != null:
			notice_label.queue_free()
			notice_label = null
	else:
		notice_label = notice_label_pack.instance()
		add_child(notice_label)

func _on_StateGraphNode_resize_request(new_minsize):
	rect_size = new_minsize
	rect_min_size = new_minsize

func _on_TextLineEdit_text_changed(new_text):
	if not is_initial:
		title = new_text
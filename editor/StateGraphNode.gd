extends GraphNode

class_name StateGraphNode

signal choices_changed(new_choices)

const editor_state = preload("res://editor_state.tres")
const notice_label_pack = preload("res://NoticeLabel.tscn")

var choices: Array = [] setget set_choices
var choice_nodes: Array = []
var notice_label = null
export var is_initial: bool = false
onready var initial_child_count = get_child_count()
var inherited_choices: bool = false setget set_inherited_choices
var state: String = "" setget ,get_state_text
var text: String = "" setget ,get_text

func get_text() -> String:
	return $TextLineEdit.text

func get_state_text() -> String:
	return $StateLineEdit.text

func set_inherited_choices(new_inherited_choices):
	inherited_choices = new_inherited_choices
	if inherited_choices:
		overlay = OVERLAY_BREAKPOINT
	else:
		overlay = OVERLAY_DISABLED

func update_choice_nodes():
	emit_signal("choices_changed", choices)
	var cur_index: int = initial_child_count
	for c_index in cur_index:
		clear_slot(cur_index)
	for c_node in choice_nodes:
		c_node.queue_free()
	choice_nodes.clear()
	cur_index = initial_child_count
	var cur_choice: int = 0
	for c in choices:
		var cur_line_edit: LineEdit = LineEdit.new()
		cur_line_edit.placeholder_text = "choice"
		cur_line_edit.text = c
		cur_line_edit.name = str(cur_choice)
# warning-ignore:return_value_discarded
		cur_line_edit.connect("text_changed", self, "choice_edited", [cur_choice])
		choice_nodes.append(cur_line_edit)
		add_child(cur_line_edit)
		set_slot(cur_index, false, 0, Color(), true, 0, editor_state.state_color)
		cur_index += 1
		cur_choice += 1
	set_deferred("rect_size:y", 0)
	rect_size.y = 0

func choice_edited(new_text, index):
	if inherited_choices:
		self.inherited_choices = false
	choices[index] = new_text
	emit_signal("choices_changed", choices)

func set_choices(new_choices):
	choices = new_choices
	update_notice_label()
	update_choice_nodes()

func connected(from: StateGraphNode):
	if choices.size() <= 0:
		self.inherited_choices = true
		self.choices = from.choices
		from.connect("choices_changed", self, "_on_from_choices_changed")

func _on_from_choices_changed(new_choices):
	self.choices = new_choices

func disconnected(_from: StateGraphNode):
	if inherited_choices:
		self.inherited_choices = false
		self.choices = []

func _ready():
	update_notice_label()
	set_slot(0, true, 0, editor_state.state_color, false, 0, Color())

func _on_IncrementButton_pressed():
	if inherited_choices:
		self.inherited_choices = false
	choices.append("")
	update_notice_label()
	update_choice_nodes()

func _on_DecrementButton_pressed():
	if inherited_choices:
		self.inherited_choices = false
	get_parent().disconnect_connected_to(name, choices.size() - 1)
	choices.remove(choices.size() - 1)
	update_notice_label()
	update_choice_nodes()

func _on_StateGraphNode_close_request():
	queue_free()

func update_notice_label():
	if is_initial:
		return
	if choices.size() > 0:
		if notice_label != null:
			notice_label.queue_free()
			notice_label = null
	elif notice_label == null:
		notice_label = notice_label_pack.instance()
		add_child(notice_label)

func _on_StateGraphNode_resize_request(new_minsize):
	rect_size = new_minsize
#	rect_min_size = new_minsize

func _on_TextLineEdit_text_changed(new_text):
	if not is_initial:
		title = new_text

func _on_StateGraphNode_sort_children():
	rect_size.y = 0

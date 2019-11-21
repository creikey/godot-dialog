extends GraphEdit

# warning-ignore:unused_class_variable
var out_dict: Dictionary

func _ready():
	set_right_disconnects(true)

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
# warning-ignore:return_value_discarded
	connect_node(from, from_slot, to, to_slot)
	get_node(to).connected(get_node(from))

func connected_to_me(graph_node_name: String) -> Node:
	for connection in get_connection_list():
		if connection["to"] == graph_node_name:
			return get_node(connection["from"])
	return null

func _input(event):
	if event.is_action_pressed("g_new_state"):
		var cur_state: GraphNode = preload("res://StateGraphNode.tscn").instance()
		cur_state.offset = event.global_position - Vector2(0, 200)
		add_child(cur_state)

func export_dict():
	for node in get_children():
		pass

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(to).disconnected(get_node(from))

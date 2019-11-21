extends GraphEdit

var out_dict: Dictionary

func _ready():
	set_right_disconnects(true)

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)
	get_node(to).connected(get_node(from))

func connected_to_me(graph_node_name: String) -> Node:
	for connection in get_connection_list():
		if connection["to"] == graph_node_name:
			return get_node(connection["from"])
	return null

func export_dict():
	for node in get_children():
		pass

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(to).disconnected(get_node(from))

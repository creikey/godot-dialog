extends GraphEdit

# warning-ignore:unused_class_variable
var out_dict: Dictionary

func _ready():
	set_right_disconnects(true)

#var counter = 0.0
#func _process(delta):
#	counter += delta
#	if counter > 1.0:
#		counter = 0.0
#		export_dict()
#		print(out_dict,"\n")

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
# warning-ignore:return_value_discarded
	connect_node(from, from_slot, to, to_slot)
	get_node(to).connected(get_node(from))

func connected_to_me(graph_node_name: String) -> Node:
	for connection in get_connection_list():
		if connection["to"] == graph_node_name:
			return get_node(connection["from"])
	return null

func disconnect_connected_to(graph_node_name: String, slot_index: int):
	for connection in get_connection_list():
		if connection["from_port"] == slot_index and connection["from"] == graph_node_name:
			disconnect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])

func _input(event):
	if event.is_action_pressed("g_new_state"):
		var cur_state: GraphNode = preload("res://StateGraphNode.tscn").instance()
		cur_state.offset = event.global_position - Vector2(0, 200)
		add_child(cur_state)

func get_node_children() -> Array:
	var to_return = []
	for node in get_children():
		if node.name == "ExitGraphNode" or not node is GraphNode:
			continue
		to_return.append(node)
	return to_return

func export_dict():
	# get interesting children
	var node_children = get_node_children()
	
	
	# number each state with an ID ( needed for export )
	var cur_state: int = 1 # 0 is the exit state
	var name_to_state_number: Dictionary = {
		"ExitGraphNode" : 0
	}
	for node in node_children:
		name_to_state_number[node.name] = cur_state
		cur_state += 1
	
	
	# track all connections relative to name of node
	var name_to_incoming_connections: Dictionary = {}	
	# state connections in a dictionary
	#{
	#	choice_text : target_node_name
	#}
	var name_to_choice_connections: Dictionary = {}
	
	
	
	for connection in get_connection_list():
		name_to_incoming_connections[connection["to"]] = name_to_state_number[connection["from"]]

		var key = get_node(connection["from"]).choices[connection["from_port"]]
		var value = name_to_state_number[connection["to"]]
#		print(name_to_choice_connections.has(connection["from"]),"	",key)
		if not name_to_choice_connections.has(connection["from"]):
			name_to_choice_connections[connection["from"]] = {
				key : value
			}
		else:
			name_to_choice_connections[connection["from"]] = { key : value }
#		print(name_to_choice_connections)

	cur_state = 1
	print(name_to_state_number)
	for node in node_children:
		
		var choices_dict: Dictionary = {}
		if not name_to_choice_connections.has(node.name):
			printerr("Warning: node '", node.text, "' does not have any connections")
		else:
			choices_dict = name_to_choice_connections[node.name]
		
		out_dict[cur_state] = {
			"state" : node.state,
			"text" : node.text,
			"choices" : choices_dict
		}
		cur_state += 1
	
	# save graph data for opening
	out_dict["savedata"] = {
		"names_to_offsets": {},
		"connections": []
	}
	
	for node in node_children:
		out_dict["savedata"]["names_to_offsets"][node.name] = node.offset
	
	for connection in get_connection_list():
		out_dict["savedata"]["connections"].append(connection)

func load_savedata(savedata_dict: Dictionary):
	var node_children = get_node_children()
	for node in node_children:
		if node.name == "InitialGraphNode":
			continue
		node.queue_free()
	
	for cur_name in savedata_dict["names_to_offsets"].keys():
		var cur_graph_node: GraphNode = preload("res://StateGraphNode.tscn").instance()
		cur_graph_node.name = cur_name
		cur_graph_node.offset = savedata_dict["names_to_offsets"][cur_name]

	for connection in savedata_dict["connections"]:
# warning-ignore:return_value_discarded
		connect_node(connection["from_port"], connection["from"], connection["to_port"], connection["to"])

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(to).disconnected(get_node(from))

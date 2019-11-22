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

func disconnect_all(graph_node_name: String):
	for c in get_connection_list():
		if c["to"] == graph_node_name:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
		if c["from"] == graph_node_name:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])


#func _input(event):
func ignore(event):
	if event.is_action_pressed("g_new_state"):
		var cur_state: GraphNode = preload("res://StateGraphNode.tscn").instance()
		cur_state.offset = event.global_position - Vector2(0, 200)
		# ensure name is unique among graph nodes ( innefficient, but hopefully will never slow down... )
		var cur_name = str(randi())
		var cur_name_good: bool = false
		while not cur_name_good:
			var found_name: bool = false
			for c in get_children():
				if c.name == cur_name:
					found_name = true
			if found_name:
				cur_name_good = false
				cur_name = str(randi())
			else:
				cur_name_good = true
		cur_state.name = cur_name
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
		"names_to_choices": {},
		"names_to_state": {},
		"names_to_text": {},
		"connections": []
	}
	
	for node in node_children:
		write_node(node.name, node, out_dict["savedata"])
	
	write_node($ExitGraphNode.name, $ExitGraphNode, out_dict["savedata"])
	
	for connection in get_connection_list():
		out_dict["savedata"]["connections"].append(connection)

func write_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	save_data["names_to_offsets"][node_name] = {
		"x": node_ref.offset.x,
		"y": node_ref.offset.y
	}
	save_data["names_to_choices"][node_name] = node_ref.choices
	save_data["names_to_state"][node_name] = node_ref.state
	save_data["names_to_text"][node_name] = node_ref.text

func load_savedata(savedata_dict: Dictionary):
	var node_children = get_node_children()
	clear_connections()
	for node in node_children:
		if node.name == "InitialGraphNode":
			continue
		node.name = "__GARBAGE"
		node.queue_free()
	
	for cur_name in savedata_dict["names_to_offsets"].keys():
		if cur_name == "InitialGraphNode" or cur_name == "ExitGraphNode":
			continue
		var cur_graph_node: GraphNode = preload("res://StateGraphNode.tscn").instance()
		cur_graph_node.name = cur_name
		add_child(cur_graph_node)
		update_node(cur_name, cur_graph_node, savedata_dict)
	
	update_node($InitialGraphNode.name, $InitialGraphNode, savedata_dict)
	update_node($ExitGraphNode.name, $ExitGraphNode, savedata_dict)
	

	for connection in savedata_dict["connections"]:
# warning-ignore:return_value_discarded
		connect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])



func update_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	var offset_dict = save_data["names_to_offsets"][node_name]
	node_ref.offset.x = offset_dict["x"]
	node_ref.offset.y = offset_dict["y"]
	node_ref.choices = save_data["names_to_choices"][node_name]
	node_ref.state = save_data["names_to_state"][node_name]
	node_ref.text = save_data["names_to_text"][node_name]

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(to).disconnected(get_node(from))

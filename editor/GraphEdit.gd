extends GraphEdit

signal new_greatest_id(greatest_id)
signal to_run_dict(dict)

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
		if node.name == "0" or not node is StateGraphNode:
			continue
		to_return.append(node)
	return to_return

func get_stub_children() -> Array:
	var to_return = []
	for node in get_children():
		if not node is StateStubGraphNode:
			continue
		if not node.is_stub:
			continue
		to_return.append(node)
	return to_return

func is_stub_name(n: String) -> bool:
	return n.split("_").size() > 1 and n.split("_")[1] == "stub"

func remove_stub_suffix(n: String) -> String:
	if is_stub_name(n):
		return n.split("_")[0]
	else:
		return n

func export_dict():
	# get interesting children
	var node_children = get_node_children()
	var stub_children = get_stub_children()
	
	# {
	#	name : {
	#		choice_text : target_name
	#	}
	# }
	var name_to_choice_connections = {}
	
	# does NOT have stub suffix
	# {
	#	name : "3"
	# }
	var name_to_next_state = {}
	
	for c in get_connection_list():
		var from = c["from"]
		var from_port: int = c["from_port"]
		var to = c["to"]
		var to_port: int = c["to_port"]
		
		if is_stub_name(from):
			from = remove_stub_suffix(from)
			if name_to_next_state.has(from):
				printerr("WARNING: state ", get_node(from + "_stub").text, " has two outbound connections")
			name_to_next_state[from] = remove_stub_suffix(to)
			continue

		if not name_to_choice_connections.has(from):
			name_to_choice_connections[from] = {}
		name_to_choice_connections[from][get_node(from).choices[from_port]] = remove_stub_suffix(to)
	
	for node in node_children:
		out_dict[node.name] = {}
		var state_data = out_dict[node.name]
		
		state_data["state"] = node.state
		state_data["text"] = node.text
		if not name_to_choice_connections.has(node.name):
			state_data["choices"] = {}
		else:
			state_data["choices"] = name_to_choice_connections[node.name]
	
	for stub in stub_children:
		var stub_name = remove_stub_suffix(stub.name)
		out_dict[stub_name] = {}
		var state_data = out_dict[stub_name]
		
		state_data["state"] = stub.state
		state_data["text"] = stub.text
		
		if name_to_next_state.has(stub_name):
			state_data["next"] = name_to_next_state[stub_name]
		else:
			state_data["choices"] = "inherit"
	
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
	
	for node in stub_children:
		write_stub_node(node.name, node, out_dict["savedata"])
	
	write_node("1", get_node("1"), out_dict["savedata"])
	write_node("0", get_node("0"), out_dict["savedata"])
	
	for connection in get_connection_list():
		out_dict["savedata"]["connections"].append(connection)

func write_stub_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	save_data["names_to_offsets"][node_name] = {
		"x": node_ref.offset.x,
		"y": node_ref.offset.y
	}
	save_data["names_to_state"][node_name] = node_ref.state
	save_data["names_to_text"][node_name] = node_ref.text

func write_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	write_stub_node(node_name, node_ref, save_data)
	save_data["names_to_choices"][node_name] = node_ref.choices
	

func load_savedata(savedata_dict: Dictionary):
	var node_children = get_node_children()
	var stub_children = get_stub_children()
	
	var greatest_id_seen: float = 0
	
	clear_connections()
	for node in node_children:
		if node.name == "1":
			continue
		node.name = "__GARBAGE"
		node.queue_free()
	for node_stub in stub_children:
		node_stub.name = "__GARBAGE_stub"
		node_stub.queue_free()
	
	for cur_name in savedata_dict["names_to_offsets"].keys():
		if cur_name == "0" or cur_name == "1":
			continue
		var cur_graph_node: GraphNode
		var is_stub: bool = false
		if is_stub_name(cur_name):
			greatest_id_seen = max(greatest_id_seen, float(cur_name.split("_")[0]))
			cur_graph_node = preload("res://StateStubGraphNode.tscn").instance()
			is_stub = true
		else:
			greatest_id_seen = max(greatest_id_seen, float(cur_name))
			cur_graph_node = preload("res://StateGraphNode.tscn").instance()
		cur_graph_node.name = cur_name
		add_child(cur_graph_node)
		if is_stub:
			update_stub_node(cur_name, cur_graph_node, savedata_dict)
		else:
			update_node(cur_name, cur_graph_node, savedata_dict)
	
	update_node("1", get_node("1"), savedata_dict)
	update_node("0", get_node("0"), savedata_dict)
	

	for connection in savedata_dict["connections"]:
# warning-ignore:return_value_discarded
		connect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])
	
	emit_signal("new_greatest_id", greatest_id_seen)

func update_stub_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	var offset_dict = save_data["names_to_offsets"][node_name]
	node_ref.offset.x = offset_dict["x"]
	node_ref.offset.y = offset_dict["y"]
	node_ref.state = save_data["names_to_state"][node_name]
	node_ref.text = save_data["names_to_text"][node_name]

func update_node(node_name: String, node_ref: GraphNode, save_data: Dictionary):
	update_stub_node(node_name, node_ref, save_data)
	node_ref.choices = save_data["names_to_choices"][node_name]
	

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(to).disconnected(get_node(from))


func _on_PlayButton_pressed():
	export_dict()
	emit_signal("to_run_dict", out_dict)

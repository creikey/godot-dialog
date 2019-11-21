extends GraphEdit

var out_dict: Dictionary

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)

func export_dict():
	for node in get_children():
		pass
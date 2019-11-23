extends PopupMenu

export (NodePath) var graph_edit_path

var global_mouse_position: Vector2 = Vector2()

func _input(event):
	if event.is_action_pressed("g_new_state"):
		popup()
		global_mouse_position = event.global_position
		rect_position = event.position

func get_untaken_name() -> String:
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
	return cur_name

func add_graph_node(pack: PackedScene):
	var graph_edit = get_node(graph_edit_path)
	var cur_state: GraphNode = pack.instance()
	cur_state.offset = global_mouse_position - Vector2(0, 200)
	# ensure name is unique among graph nodes ( innefficient, but hopefully will never slow down... )
	var cur_name: String = get_untaken_name()
	cur_state.name = cur_name
	graph_edit.add_child(cur_state)

func _on_PopupMenu_id_pressed(id):
	match id:
		0: # normal state
			add_graph_node(preload("res://StateGraphNode.tscn"))
		1: # stubbed state
			add_graph_node(preload("res://StateStubGraphNode.tscn"))

extends PopupMenu

export (NodePath) var graph_edit_path

var global_mouse_position: Vector2 = Vector2()

var id_counter: int = 1

func _input(event):
	if event.is_action_pressed("g_new_state"):
		popup()
		global_mouse_position = event.global_position
		rect_position = event.position

func get_untaken_name() -> String:
	id_counter += 1
	return str(id_counter)

func add_graph_node(pack: PackedScene, suffix: String):
	var graph_edit = get_node(graph_edit_path)
	var cur_state: GraphNode = pack.instance()
	cur_state.offset = global_mouse_position + graph_edit.scroll_offset
	# ensure name is unique among graph nodes ( innefficient, but hopefully will never slow down... )
	var cur_name: String = get_untaken_name()
	cur_state.name = cur_name + suffix
	graph_edit.add_child(cur_state)

func _on_PopupMenu_id_pressed(id):
	match id:
		0: # normal state
			add_graph_node(preload("res://StateGraphNode.tscn"), "")
		1: # stubbed state
			add_graph_node(preload("res://StateStubGraphNode.tscn"), "_stub")
		2: # event state
			add_graph_node(preload("res://EventGraphNode.tscn"), "_event")

func _on_GraphEdit_new_greatest_id(greatest_id):
	id_counter = greatest_id + 1

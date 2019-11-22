extends FileDialog

export (NodePath) var graph_edit_path


func _on_FileDialog_file_selected(path):
	var graph_edit = get_node(graph_edit_path)
	graph_edit.export_dict()
	var cur_file: File = File.new()
# warning-ignore:return_value_discarded
	cur_file.open(path, File.WRITE)
	cur_file.store_string(to_json(graph_edit.out_dict))
	cur_file.close()


func _on_FileButton_save_menu():
	popup()

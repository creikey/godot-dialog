extends FileDialog

export (NodePath) var graph_edit_path


func _on_FileDialog_file_selected(path):
	match mode:
		FileDialog.MODE_SAVE_FILE:
			var graph_edit = get_node(graph_edit_path)
			graph_edit.export_dict()
			var cur_file: File = File.new()
		# warning-ignore:return_value_discarded
			cur_file.open(path, File.WRITE)
			cur_file.store_string(to_json(graph_edit.out_dict))
			cur_file.close()
		FileDialog.MODE_OPEN_FILE:
			var graph_edit = get_node(graph_edit_path)
			var cur_file: File = File.new()
# warning-ignore:return_value_discarded
			cur_file.open(path, File.READ)
			graph_edit.load_savedata(parse_json(cur_file.get_as_text())["savedata"])
			cur_file.close()
		_:
			printerr("Unknown filedialog mode ", mode)


func _on_FileButton_save_menu():
	mode = FileDialog.MODE_SAVE_FILE
	popup()


func _on_FileButton_load_menu():
	mode = FileDialog.MODE_OPEN_FILE
	popup()

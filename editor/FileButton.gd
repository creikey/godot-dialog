extends MenuButton

signal export_menu

func _ready():
	get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(id):
	match id:
		2:
			emit_signal("export_menu")

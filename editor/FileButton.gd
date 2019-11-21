extends MenuButton

signal save_menu
signal load_menu

func _ready():
	get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(id):
	match id:
		1:
			emit_signal("load_menu")
		2:
			emit_signal("save_menu")

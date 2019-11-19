extends Node2D

var text: String = "" setget set_text

func set_text(new_text):
	text = new_text
	if has_node("DialogLabel"):
		set_process(true)
		$DialogLabel.text = text
		$DialogLabel.percent_visible = 0.0

func _ready():
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	var display_vector: Vector2 = Vector2(width, height)
	
	global_position = display_vector/2
	set_process(false)
	self.text = "testing"

func _process(delta):
	$DialogLabel.percent_visible += delta
	update_label_position()

func update_label_position():
	$DialogLabel.rect_position.y = -$Sprite.texture.get_size().y/2 - 10 - $DialogLabel.rect_size.y
	$DialogLabel.rect_position.x = -$DialogLabel.rect_size.x/2
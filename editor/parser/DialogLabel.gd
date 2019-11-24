extends Label

var scrolling_text = "" setget set_scrolling_text

func set_scrolling_text(new_scrolling_text):
	text = new_scrolling_text
	percent_visible = 0.0

func _process(delta):
	percent_visible += delta

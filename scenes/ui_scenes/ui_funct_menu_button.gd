@tool
extends MarginContainer

@export var text: String = "Button":
	set(value):
		text = value
		if has_node("CenterContainer/MarginContainer/Label"):
			$CenterContainer/MarginContainer/Label.text = value

func _ready():
	$CenterContainer/MarginContainer/Label.text = text
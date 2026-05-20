extends PanelContainer

@onready var texture_rect = $TextureRect

# Define two colors for the background highlight
@export var normal_color = Color(0.2, 0.2, 0.2, 0.6)      # Dark translucent grey
@export var highlight_color = Color(0.8, 0.6, 0.2, 0.9)   # Bright gold/yellow

func display_item(item_data: ItemData, is_selected: bool):
	# Set the icon texture if it exists
	if item_data and item_data.icon:
		texture_rect.texture = item_data.icon
	else:
		texture_rect.texture = null
		
	# Apply a flat background color override depending on selection state
	var style = StyleBoxFlat.new()
	if is_selected:
		style.bg_color = normal_color
		style.set_border_width_all(2) # Add a small border for the selected item
		style.border_color = highlight_color
	else:
		style.bg_color = normal_color
		
	add_theme_stylebox_override("panel", style)
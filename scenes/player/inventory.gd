extends Node3D

signal picked_up_item

@onready var inventory: Array[ItemData] = []


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_inventory"):
		for item in inventory:
			print(item)
			print("Item :" + item.name + "\nDescription: " + item.description)

func pick_up_item(item_node):
	if "data" in item_node:
		add_item_to_inventory(item_node.data)
		print("Picked up: ", item_node)
		item_node.queue_free()


func add_item_to_inventory(item_data: ItemData):
	inventory.append(item_data)
	picked_up_item.emit()


func item_added_with_dialog(item: ItemData):
	Dialogic.VAR.set_variable("item_strings.item_received", item.name)
	Dialogic.VAR.set_variable("item_strings.item_description", item.description)
	add_item_to_inventory(item)
	if Dialogic.current_timeline == null:
		Dialogic.start("item_received_timeline")


func get_inventory() -> Array[ItemData]:
	return inventory


# Inventory
func remove_item(_item_name):
	pass
	#for item in inventory:
	#	if item.name == item_name:

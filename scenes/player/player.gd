extends CharacterBody3D

@export var SPEED = 5
@export var JUMP_VELOCITY = 4.5

@export var mouse_sensitivity = 0.002
@export var can_move = true
@export var debug_mode = false

@export var footstep_sounds: Array[AudioStream] = []

var target_velocity = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Possible different Walk Modes
enum PLAYER_MODES {
	WALK
}
var current_mode := PLAYER_MODES.WALK

#Player Visibility Stuff, Moving Head around, showing Items and UI Hints
@onready var head = $Head
@onready var interaction_ray = $Head/InteractionRay
@onready var hand_mesh = $UILayer/ItemInHandContainer/ItemInHand/HandSlot/HandMesh
@onready var pick_up_hint = $UILayer/UIHints/PickupHint
@onready var talk_hint = $UILayer/UIHints/TalkHint
@onready var interact_hint = $UILayer/UIHints/InteractHint
var hint_checker = true
var min_camera_x = deg_to_rad(-90)
var max_camera_x = deg_to_rad(90)

#Inventory
var selected_index: int = 0
var inventory: Array[ItemData]=[]
var current_item: ItemData 
const INVENTORY_SLOT_SCENE = preload("res://scenes/player/InventoryUI/InventorySlot.tscn")
@onready var slot_container = $UILayer/InventoryBar/SlotContainer

@onready var footstep_player = $FootstepPlayer
@onready var footstep_timer = $FootstepPlayer/FootstepTimer

@onready var pause_menu = $"../PauseLayer/PauseMenu"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Captures the mouse and hides it

	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_started():
	can_move = false
	hint_checker = false

func _on_timeline_ended():
	can_move = true
	hint_checker = true

func _input(event):
	if event is InputEventMouseMotion and can_move:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_camera_x, max_camera_x)
	
	if event.is_action_pressed("interact"):
		check_interaction()

	if event.is_action_pressed("show_inventory"):
		for item in inventory:
			print(item)
			print("Item :"+item.name+"\nDescription: "+item.description)

	if event.is_action_pressed("next_item"):
		change_selected_item(1)
	elif event.is_action_pressed("prev_item"):
		change_selected_item(-1)
	
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func _physics_process(delta):
	match current_mode:
		PLAYER_MODES.WALK:
			walk_process(delta)

	pick_up_hint.visible = false
	talk_hint.visible = false
	interact_hint.visible = false

	if interaction_ray.is_colliding() and hint_checker:
		var collider = interaction_ray.get_collider()
		if collider != null:
			if collider.is_in_group("item_for_pickup"):
				pick_up_hint.visible = true
			elif collider.is_in_group("talk_to"):
				talk_hint.visible = true
			elif collider.is_in_group("interactable"):
				interact_hint.visible = true

func walk_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and can_move:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	var horizontal_velocity = Vector2(velocity.x, velocity.z)

	if is_on_floor() and horizontal_velocity.length() > 0.1:
		if footstep_timer.is_stopped():
			play_footstep_sound()
			footstep_timer.start()
	else:
		if not footstep_timer.is_stopped():
			footstep_timer.stop()

func check_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()

		if collider.is_in_group("item_for_pickup"):
			pick_up_item(collider)
		
		if collider.has_method("startDialog"):
			collider.startDialog()
		
		if collider and collider.has_method("interact"):
			if collider.has_signal("ToiletMiniGameStarted") and collider.has_signal("ToiletMiniGameEnded"):
				if not collider.ToiletMiniGameStarted.is_connected(_on_toilet_mini_game_started):
					collider.ToiletMiniGameStarted.connect(_on_toilet_mini_game_started)
					collider.ToiletMiniGameEnded.connect(_on_toilet_mini_game_ended)
			collider.interact()

func pick_up_item(item_node):
	if "data" in item_node:
		add_item(item_node.data)
		if debug_mode:
			print("Picked up: ", item_node)
		item_node.queue_free()

func change_selected_item(direction: int):
	if inventory.is_empty():
		return
		
	selected_index = (selected_index + direction) % inventory.size() # Cycle through inventory index safely
	if selected_index < 0:
		selected_index = inventory.size() - 1

	update_hand_display()

	if debug_mode:
		print(inventory[selected_index].name)

func add_item(item_data:ItemData):
	inventory.append(item_data)
	current_item = inventory[-1]
	change_selected_item(1)
	update_inventory_ui()


func update_hand_display():
	current_item = inventory[selected_index]
	
	if current_item and current_item.item_mesh:
		hand_mesh.mesh = current_item.item_mesh #Just change the visual shape of the existing hand node
		hand_mesh.visible = true
	else:
		hand_mesh.visible = false #Hide it if the slot is empty or has no mesh

	update_inventory_ui()

func play_footstep_sound():
	if footstep_sounds.is_empty():
		return

	var random_index = randi() % footstep_sounds.size()
	var chosen_sound = footstep_sounds[random_index]
	footstep_player.stream = chosen_sound
	footstep_player.pitch_scale = randf_range(0.95, 1.05)
	footstep_player.play()


func _on_footstep_timer_timeout() -> void:
	play_footstep_sound()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state

	pause_menu.visible = new_pause_state

	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if has_node("FootstepTimer"): $FootstepTimer.stop()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_inventory_ui():
	for child in slot_container.get_children():
		child.queue_free()

	for i in range(inventory.size()):
		var slot_instance = INVENTORY_SLOT_SCENE.instantiate()
		slot_container.add_child(slot_instance)

		var is_active = (i == selected_index)

		slot_instance.display_item(inventory[i], is_active)

func _on_toilet_mini_game_started():
	can_move = false
	hint_checker = false
	interact_hint.visible = false

func _on_toilet_mini_game_ended():
	can_move = true
	hint_checker = true
	var sharp_metal_object = load("res://resources/assets/items_for_pickup/sharpMetalObject/metal_object.tres")
	Dialogic.VAR.set_variable("has_sharp", true)
	add_item(sharp_metal_object)

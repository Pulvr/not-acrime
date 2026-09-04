extends CenterContainer

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var interaction_ray: Node = get_node("../../Head/InteractionRay")
@onready var pick_up_hint: MarginContainer = $PickupHint
@onready var talk_hint: MarginContainer = $TalkHint
@onready var interact_hint: MarginContainer = $InteractHint


func _physics_process(_delta: float) -> void:
	pick_up_hint.visible = false
	talk_hint.visible = false
	interact_hint.visible = false

	if interaction_ray.is_colliding() and player.get_state() == Player.State.FREE:
		var collider = interaction_ray.get_collider()
		if collider != null:
			if collider.is_in_group("item_for_pickup"):
				pick_up_hint.visible = true
			elif collider.is_in_group("talk_to"):
				talk_hint.visible = true
			elif collider.is_in_group("interactable"):
				interact_hint.visible = true

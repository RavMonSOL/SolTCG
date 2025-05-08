extends Node2D

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 0.85
const CARD_SMALLER_SCALE = 0.6

var cardScaleSize = 1.1
var screen_size
var isCardBeingDragged
var isHovering
var lastCardHovered
var player_hand_reference
var played_monster_card_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isCardBeingDragged:
		var mousePos = get_global_mouse_position()
		isCardBeingDragged.position = Vector2(clamp(mousePos.x, 0, screen_size.x), 
			clamp(mousePos.y, 0, screen_size.y))
		

#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			## Raycast check for card
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#finish_drag()

func start_drag(card):
	card.get_parent().move_child(card, -1)
	isCardBeingDragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)

func finish_drag():
	isCardBeingDragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		if isCardBeingDragged.card_type == card_slot_found.card_slot_type:
			if !played_monster_card_this_turn:
				played_monster_card_this_turn = true
				isCardBeingDragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
				isCardBeingDragged.z_index = -1
				isHovering = false
				isCardBeingDragged.card_slot_is_in = card_slot_found
				player_hand_reference.remove_card_from_hand(isCardBeingDragged)
				isCardBeingDragged.position = card_slot_found.position
				isCardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = true
				card_slot_found.card_in_slot = true
				isCardBeingDragged = null
				return
	player_hand_reference.add_card_to_hand(isCardBeingDragged, DEFAULT_CARD_MOVE_SPEED)
	isCardBeingDragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_left_click_released():
	if isCardBeingDragged:
		finish_drag()

func on_hovered_over_card(card):
	if !isHovering:
		isHovering = true
		highlight_card(card, true)
 
func on_hovered_off_card(card):
	if !card.card_slot_is_in && !isCardBeingDragged:
		if card != lastCardHovered && lastCardHovered != null:
			lastCardHovered.z_index = 1 
		
		lastCardHovered = card
		lastCardHovered.z_index = 2
	
	
	
	if !isCardBeingDragged:
		highlight_card(card, false)
		var newCardHovered = raycast_check_for_card()
		if newCardHovered:
			highlight_card(newCardHovered, true)
		else:
			isHovering = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 3
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		
		
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

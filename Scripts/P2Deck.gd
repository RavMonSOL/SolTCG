extends Node2D

const CARD_SCENE_PATH = "res://Scenes/P2Card.tscn"
const CARD_DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 2

var p2_deck = ["Pepe", "Fwog", "Gork", "Popcat"]
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p2_deck.shuffle()
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()

func draw_card():
	var card_drawn_name = p2_deck[0]
	p2_deck.erase(card_drawn_name)
	
	if p2_deck.size() == 0:
		$Sprite2D.visible = false
		
	print("draw card")
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/Cards/" + card_drawn_name + ".png")
	var card_data = card_database_reference.CARDS[card_drawn_name]
	new_card.attack = card_data[0]  # Attack value
	new_card.get_node("Attack").text = str(new_card.attack)
	new_card.health = card_data[1]  # Health value
	new_card.get_node("Health").text = str(new_card.health)
	new_card.card_type = card_data[2]  # Card type
	new_card.position = self.position
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../P2Hand".add_card_to_hand(new_card, CARD_DRAW_SPEED)

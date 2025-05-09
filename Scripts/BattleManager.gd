extends Node

const SMALL_CARD_SCALE = 0.6
const MOVE_SPEED = 0.2
const STARTING_HEALTH = 10
const BATTLE_POS_OFFSET = 25


var battle_timer
var empty_meme_card_slot = []
var p2_cards_on_field = []
var p1_cards_on_field = []
var p1_health
var p2_health

func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_meme_card_slot.append($"../CardSlots/P2MemeSlot")
	empty_meme_card_slot.append($"../CardSlots/P2MemeSlot2")
	empty_meme_card_slot.append($"../CardSlots/P2MemeSlot3")
	empty_meme_card_slot.append($"../CardSlots/P2MemeSlot4")
	empty_meme_card_slot.append($"../CardSlots/P2MemeSlot5")
	
	p1_health = STARTING_HEALTH
	$"../P1hp".text = str(p1_health)
	p2_health = STARTING_HEALTH
	$"../P2hp".text = str(p2_health)
	
func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	#wait 1 second
	await wait(1)
	
	if $"../P2Deck".p2_deck.size() != 0:
		$"../P2Deck".draw_card()
	await wait(1)
	
	#check for free meme card slots, if none end turn
	if empty_meme_card_slot.size() != 0:
		await play_card_with_highest_atk()
		
	if p2_cards_on_field.size() != 0:
		var enemy_cards_to_attack = p2_cards_on_field.duplicate()
		for card in enemy_cards_to_attack:
			if p1_cards_on_field.size() != 0:
				var card_to_attack = p1_cards_on_field.pick_random()
				await attack(card, card_to_attack, "P2")
			else:
				await direct_attack(card, "P2")
		
	#end turn
	end_p2_turn()
	
func direct_attack(attacking_card, attacker):
	var new_pos_y
	if attacker == "P2":
		new_pos_y = 1080
	else:
		new_pos_y = 0
		
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	
	attacking_card.z_index = 5
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, MOVE_SPEED)
	await wait(0.15)
	
	if attacker == "P2":
		p1_health = max(0, p1_health - attacking_card.attack)
		$"../P1hp".text = str(p1_health)
	else:
		p2_health = max(0, p2_health - attacking_card.attack)
		$"../P2hp".text = str(p2_health)
		
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_is_in.position, MOVE_SPEED)
	attacking_card.z_index = 0
	await wait(1.0)
	
	
func attack(attacking_card, defending_card, attacker):
	print("Attack")
	attacking_card.z_index = 5
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, MOVE_SPEED)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_is_in.position, MOVE_SPEED)
	
	#card damage
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Health").text = str(defending_card.health)
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1.0)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	#destroy card if health = 0
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true
	if defending_card.health == 0:
		if attacker == "P1":
			destroy_card(defending_card, "P2")
		else:
			destroy_card(defending_card, "P1")
		card_was_destroyed = true
		
	if card_was_destroyed:
		await wait(1.0)
	
func destroy_card(card, card_owner):
	var new_pos
	if card_owner == "P1":
		new_pos = $"../P1Grave".position
		if card in p1_cards_on_field:
			p1_cards_on_field.erase(card)
	else:
		new_pos = $"../P2Grave".position
		
	card.card_slot_is_in.card_in_slot = false
	card.card_slot_is_in = null
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, MOVE_SPEED)
	
	
func play_card_with_highest_atk():
	var p2_hand = $"../P2Hand".p2_hand
	if p2_hand.size() == 0:
		end_p2_turn()
		return
	
	#var random_empty_meme_slot = empty_meme_card_slot[randi_range(0, empty_meme_card_slot.size())]
	var random_empty_meme_slot = empty_meme_card_slot.pick_random()
	print(empty_meme_card_slot.size())
	empty_meme_card_slot.erase(random_empty_meme_slot)
	
	#play card in hand with highest attack
	var card_highest_atk = p2_hand[0]
	#loop through rest of cards in hand looking for highest atk niggers
	for card in p2_hand:
		if card.attack > card_highest_atk.attack:
			card_highest_atk = card
	
	var tween = get_tree().create_tween()
	tween.tween_property(card_highest_atk, "position", random_empty_meme_slot.position, MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_highest_atk, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), MOVE_SPEED)
	card_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	#remove card from hand
	$"../P2Hand".remove_card_from_hand(card_highest_atk)
	card_highest_atk.card_slot_is_in = random_empty_meme_slot
	p2_cards_on_field.append(card_highest_atk)
		#wait 1 second
	await wait(1)
	
func end_p2_turn():
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_monster()
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

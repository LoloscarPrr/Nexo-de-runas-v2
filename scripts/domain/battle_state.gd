class_name BattleState
extends RefCounted

const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")

var hand: Array[String] = []
var draw_pile: Array[String] = []
var player_lanes := [null, null, null, null]
var enemy_lanes := [null, null, null, null]
var enemy_queue: Array[String] = ["esqueleto", "zombi", "esqueleto", "zombi", "sepulturero"]
var enemy_queue_index := 0
var bones := 2
var energy := 3
var max_energy := 3
var scale := 0
var turn := 1
var result := "ongoing"
var last_message := "Elige una carta y luego una casilla vacía."

func setup(deck_ids: Array[String]) -> void:
	hand = []
	draw_pile = []
	for card_id in deck_ids:
		draw_pile.append(card_id)
	player_lanes = [null, null, null, null]
	enemy_lanes = [null, null, null, null]
	enemy_queue_index = 0
	bones = 2
	energy = 3
	max_energy = 3
	scale = 0
	turn = 1
	result = "ongoing"
	last_message = "Elige una carta y luego una casilla vacía."
	_draw_one()
	_draw_one()
	_draw_one()
	_spawn_enemy()

func can_play(hand_index: int, lane_index: int) -> String:
	if result != "ongoing":
		return "La batalla ya terminó."
	if hand_index < 0 or hand_index >= hand.size():
		return "Selecciona una carta de tu mano."
	if lane_index < 0 or lane_index >= player_lanes.size():
		return "Casilla inválida."
	if player_lanes[lane_index] != null:
		return "Esa casilla ya está ocupada."
	var card := CardCatalogScript.find_by_id(hand[hand_index])
	if card.is_empty():
		return "Carta inválida."
	var resource := str(card.get("resource", "none"))
	var cost := int(card.get("cost_value", 0))
	match resource:
		"none":
			return ""
		"energy":
			if energy < cost:
				return "Energía insuficiente."
			return ""
		"bones":
			if bones < cost:
				return "Huesos insuficientes."
			return ""
		"runes":
			return "Las Runas se habilitarán con el sistema Mox completo."
		"blood":
			return "La Sangre se habilitará con sacrificios en la siguiente iteración."
		_:
			return "Recurso no compatible."

func play_card(hand_index: int, lane_index: int) -> bool:
	var error_message := can_play(hand_index, lane_index)
	if not error_message.is_empty():
		last_message = error_message
		return false
	var card_id := hand[hand_index]
	var card := CardCatalogScript.find_by_id(card_id)
	var resource := str(card.get("resource", "none"))
	var cost := int(card.get("cost_value", 0))
	if resource == "energy":
		energy -= cost
	elif resource == "bones":
		bones -= cost
	player_lanes[lane_index] = {"id": card_id, "hp": int(card.get("hp", 1))}
	hand.remove_at(hand_index)
	last_message = "%s entra en la casilla %d." % [str(card.get("name", card_id)), lane_index + 1]
	return true

func end_turn() -> String:
	if result != "ongoing":
		return result
	_resolve_player_attacks()
	if _check_result() != "ongoing":
		return result
	_resolve_enemy_attacks()
	if _check_result() != "ongoing":
		return result
	turn += 1
	max_energy = min(6, max_energy + 1)
	energy = max_energy
	_draw_one()
	_spawn_enemy()
	last_message = "Turno %d · la balanza está en %+d." % [turn, scale]
	return result

func _resolve_player_attacks() -> void:
	for lane_index in range(player_lanes.size()):
		var unit = player_lanes[lane_index]
		if unit == null:
			continue
		var card := CardCatalogScript.find_by_id(str(unit["id"]))
		var damage := int(card.get("atk", 0))
		var enemy = enemy_lanes[lane_index]
		if enemy == null:
			scale += damage
		else:
			enemy["hp"] = int(enemy["hp"]) - damage
			if int(enemy["hp"]) <= 0:
				enemy_lanes[lane_index] = null
				bones += 1

func _resolve_enemy_attacks() -> void:
	for lane_index in range(enemy_lanes.size()):
		var enemy = enemy_lanes[lane_index]
		if enemy == null:
			continue
		var card := CardCatalogScript.find_by_id(str(enemy["id"]))
		var damage := int(card.get("atk", 0))
		var unit = player_lanes[lane_index]
		if unit == null:
			scale -= damage
		else:
			unit["hp"] = int(unit["hp"]) - damage
			if int(unit["hp"]) <= 0:
				player_lanes[lane_index] = null
				bones += 1

func _check_result() -> String:
	if scale >= 5:
		result = "victory"
		last_message = "Victoria. La balanza cae de tu lado."
	elif scale <= -5:
		result = "defeat"
		last_message = "Derrota. La expedición puede reiniciarse."
	return result

func _draw_one() -> void:
	if draw_pile.is_empty():
		return
	hand.append(draw_pile.pop_front())

func _spawn_enemy() -> void:
	if enemy_queue_index >= enemy_queue.size():
		return
	var lane_index := -1
	for i in range(enemy_lanes.size()):
		if enemy_lanes[i] == null:
			lane_index = i
			break
	if lane_index == -1:
		return
	var card_id := enemy_queue[enemy_queue_index]
	enemy_queue_index += 1
	var card := CardCatalogScript.find_by_id(card_id)
	enemy_lanes[lane_index] = {"id": card_id, "hp": int(card.get("hp", 1))}

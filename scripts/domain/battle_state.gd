class_name BattleState
extends RefCounted

const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")

var hand: Array[String] = []
var draw_pile: Array[String] = []
var player_lanes := [null, null, null, null]
var enemy_lanes := [null, null, null, null]
var enemy_queue: Array[String] = ["coyote", "rana_toro", "lobo", "puercoespin", "coyote"]
var enemy_queue_index := 0
var bones := 0
var squirrel_pile_count := 10
var draw_pending := false
var scale := 0
var turn := 1
var result := "ongoing"
var last_message := "Elige una carta. Las cartas de Sangre exigen sacrificios."

func setup(deck_ids: Array[String]) -> void:
	hand = []
	draw_pile = []
	for card_id in deck_ids:
		draw_pile.append(card_id)
	player_lanes = [null, null, null, null]
	enemy_lanes = [null, null, null, null]
	enemy_queue_index = 0
	bones = 0
	squirrel_pile_count = 10
	draw_pending = false
	scale = 0
	turn = 1
	result = "ongoing"
	last_message = "Elige una carta. Las cartas de Sangre exigen sacrificios."
	_draw_regular_if_possible()
	_draw_regular_if_possible()
	_draw_regular_if_possible()
	hand.append("ardilla")
	_spawn_enemy()

func needs_draw() -> bool:
	return draw_pending and result == "ongoing"

func draw_from_deck() -> bool:
	if not needs_draw():
		return false
	if draw_pile.is_empty():
		last_message = "El mazo principal está vacío. Roba una Ardilla si quedan."
		return false
	hand.append(draw_pile.pop_front())
	draw_pending = false
	last_message = "Robaste del mazo principal."
	return true

func draw_squirrel() -> bool:
	if not needs_draw():
		return false
	if squirrel_pile_count <= 0:
		last_message = "No quedan Ardillas en la reserva."
		return false
	hand.append("ardilla")
	squirrel_pile_count -= 1
	draw_pending = false
	last_message = "Tomaste una Ardilla de la reserva."
	return true

func blood_cost_for(hand_index: int) -> int:
	if hand_index < 0 or hand_index >= hand.size():
		return 0
	var card := CardCatalogScript.find_by_id(hand[hand_index])
	if str(card.get("resource", "none")) != "blood":
		return 0
	return int(card.get("cost_value", 0))

func can_play(hand_index: int, lane_index: int, sacrifice_lanes: Array[int]) -> String:
	if result != "ongoing":
		return "La batalla ya terminó."
	if draw_pending:
		return "Primero debes robar una carta."
	if hand_index < 0 or hand_index >= hand.size():
		return "Selecciona una carta de tu mano."
	if lane_index < 0 or lane_index >= player_lanes.size():
		return "Casilla inválida."
	var card := CardCatalogScript.find_by_id(hand[hand_index])
	if card.is_empty():
		return "Carta inválida."
	var resource := str(card.get("resource", "none"))
	var cost := int(card.get("cost_value", 0))
	if resource == "blood":
		var unique: Array[int] = []
		for sacrifice_lane in sacrifice_lanes:
			if sacrifice_lane < 0 or sacrifice_lane >= player_lanes.size():
				return "Sacrificio inválido."
			if unique.has(sacrifice_lane):
				continue
			if player_lanes[sacrifice_lane] == null:
				return "No hay criatura en una casilla marcada para sacrificio."
			unique.append(sacrifice_lane)
		if unique.size() < cost:
			return "Faltan %d sacrificio(s)." % (cost - unique.size())
		if unique.size() > cost:
			return "Has marcado más sacrificios de los necesarios."
		if player_lanes[lane_index] != null and not unique.has(lane_index):
			return "Esa casilla está ocupada."
		return ""
	if player_lanes[lane_index] != null:
		return "Esa casilla está ocupada."
	if resource == "bones":
		if bones < cost:
			return "Huesos insuficientes."
		return ""
	if resource == "none":
		return ""
	return "Ese recurso no pertenece al Acto 1 activo."

func play_card(hand_index: int, lane_index: int, sacrifice_lanes: Array[int]) -> bool:
	var error_message := can_play(hand_index, lane_index, sacrifice_lanes)
	if not error_message.is_empty():
		last_message = error_message
		return false
	var card_id := hand[hand_index]
	var card := CardCatalogScript.find_by_id(card_id)
	var resource := str(card.get("resource", "none"))
	var cost := int(card.get("cost_value", 0))
	if resource == "blood":
		for sacrifice_lane in sacrifice_lanes:
			if player_lanes[sacrifice_lane] != null:
				player_lanes[sacrifice_lane] = null
				bones += 1
	elif resource == "bones":
		bones -= cost
	player_lanes[lane_index] = {"id": card_id, "hp": int(card.get("hp", 1))}
	hand.remove_at(hand_index)
	last_message = "%s entra en la casilla %d." % [str(card.get("name", card_id)), lane_index + 1]
	return true

func end_turn() -> String:
	if result != "ongoing":
		return result
	if draw_pending:
		last_message = "Debes robar antes de continuar el turno."
		return result
	_resolve_player_attacks()
	if _check_result() != "ongoing":
		return result
	_resolve_enemy_attacks()
	if _check_result() != "ongoing":
		return result
	turn += 1
	draw_pending = not draw_pile.is_empty() or squirrel_pile_count > 0
	_spawn_enemy()
	last_message = "Turno %d · elige entre tu mazo y la reserva de Ardillas." % turn if draw_pending else "No quedan cartas. Juega tu mano o toca la campana."
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
		last_message = "Victoria. Los dientes inclinan la balanza a tu favor."
	elif scale <= -5:
		result = "defeat"
		last_message = "La balanza cayó del lado de tu oponente."
	return result

func _draw_regular_if_possible() -> void:
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

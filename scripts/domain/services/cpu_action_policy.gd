class_name CpuActionPolicy
extends RefCounted

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

## Selecciona una acción legal sin ejecutar reglas.
## La ejecución sigue perteneciendo a CanonicalCpuBattle y a los resolvers compartidos.
##
## La CPU ya no toma actions[0]. Puntúa cada alternativa para que los cinco
## carriles sean posiciones tácticas reales, no una lista que se rellena de
## izquierda a derecha.
static func choose_action(battle) -> Dictionary:
	var best_action: Dictionary = {}
	var best_score: int = -1000000
	var best_tie_break: int = -1000000

	for hand_index in range(battle.cpu_hand.size()):
		var card_id := str(battle.cpu_hand[hand_index])
		var card: Dictionary = Catalog.find_by_id(card_id)
		if card.is_empty():
			continue
		var actions: Array = battle.cpu_legal_actions_for_card(hand_index)
		if actions.is_empty():
			continue

		# Conserva la intención anterior de aprovechar cartas de mayor coste,
		# pero deja que la posición/objetivo decidan entre sus jugadas legales.
		var cost: int = int(card.get("cost", 0))
		for raw_action in actions:
			var action: Dictionary = Dictionary(raw_action)
			var score: int = cost * 100 + _score_action(battle, card, action)
			var tie_break: int = _tie_break_score(battle, card_id, hand_index, action)
			if score > best_score or (score == best_score and tie_break > best_tie_break):
				best_score = score
				best_tie_break = tie_break
				best_action = action.duplicate(true)
				best_action["hand_index"] = hand_index

	return best_action

static func _score_action(battle, card: Dictionary, action: Dictionary) -> int:
	var card_type := str(card.get("type", ""))
	match card_type:
		Catalog.TYPE_CREATURE:
			return _score_creature_lane(battle, card, int(action.get("lane", -1)))
		Catalog.TYPE_RITE:
			return _score_target_lane(battle, int(action.get("target_lane", -1)))
		Catalog.TYPE_RELIC, Catalog.TYPE_SEAL:
			# Reemplazar un permanente útil es peor que ocupar una ranura libre.
			return -8 if int(action.get("replace_index", -1)) >= 0 else 4
		_:
			return 0

static func _score_creature_lane(battle, card: Dictionary, lane: int) -> int:
	if lane < 0 or lane >= int(battle.LANE_COUNT):
		return -10000

	var score: int = _positional_score(battle, lane)
	var attack: int = int(card.get("attack", 0))
	var health: int = int(card.get("health", 0))
	var opposing_unit = battle.player_lanes[lane]

	if opposing_unit != null:
		var defender: Dictionary = opposing_unit
		var defender_attack: int = int(defender.get("attack", 0))
		var defender_hp: int = int(defender.get("hp", 0))
		# Bloquear una amenaza existente tiene prioridad sobre rellenar huecos.
		score += 35 + defender_attack * 4 + defender_hp * 2
		if attack >= defender_hp:
			score += 14
		if defender_attack >= health and health > 0:
			score -= 5
	else:
		# Un carril libre ofrece presión futura al Nexo.
		score += 12

	# Una pequeña preferencia por apoyar unidades vecinas hace que la formación
	# responda al tablero sin obligar a una secuencia fija.
	if lane > 0 and battle.enemy_lanes[lane - 1] != null:
		score += 3
	if lane + 1 < int(battle.LANE_COUNT) and battle.enemy_lanes[lane + 1] != null:
		score += 3
	return score

static func _score_target_lane(battle, lane: int) -> int:
	if lane < 0:
		return 0
	if lane >= int(battle.LANE_COUNT):
		return -10000

	var score: int = _positional_score(battle, lane)
	var player_unit = battle.player_lanes[lane]
	var enemy_unit = battle.enemy_lanes[lane]
	if player_unit != null:
		var victim: Dictionary = player_unit
		score += 18 + int(victim.get("attack", 0)) * 4 + int(victim.get("hp", 0)) * 2
	if enemy_unit != null:
		var ally: Dictionary = enemy_unit
		score += 8 + int(ally.get("attack", 0)) * 2 + int(ally.get("hp", 0))
	return score

static func _positional_score(battle, lane: int) -> int:
	# En un tablero neutro se favorece levemente el centro, pero el pequeño
	# desplazamiento por turno evita una preferencia eterna por el mismo lado.
	var lane_count: int = int(battle.LANE_COUNT)
	var center: float = float(lane_count - 1) / 2.0
	var center_bonus: int = 8 - int(absf(float(lane) - center) * 2.0)
	var turn_variation: int = (lane * 3 + int(battle.turn) * 2) % lane_count
	return center_bonus + turn_variation

static func _tie_break_score(battle, card_id: String, hand_index: int, action: Dictionary) -> int:
	# Desempate determinista por estado: evita tests aleatorios, pero cambia con
	# turno/carta/posición y elimina el sesgo sistemático hacia el carril 1.
	var lane: int = int(action.get("lane", action.get("target_lane", -1)))
	var key: String = "%d:%s:%d:%d:%d" % [int(battle.turn), card_id, hand_index, lane, int(battle.cpu_energy_current)]
	return absi(hash(key)) % 100000

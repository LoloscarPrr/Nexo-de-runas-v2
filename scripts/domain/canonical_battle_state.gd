class_name CanonicalBattleState
extends RefCounted

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const BoardStateScript = preload("res://scripts/domain/entities/board_state.gd")
const CostDefinitionScript = preload("res://scripts/domain/value_objects/cost_definition.gd")
const CostResolverScript = preload("res://scripts/domain/services/cost_resolver.gd")
const EventQueueScript = preload("res://scripts/domain/events/event_queue.gd")
const GameEventScript = preload("res://scripts/domain/events/game_event.gd")
const AbilityDefinitionScript = preload("res://scripts/domain/definitions/ability_definition.gd")
const AbilityCatalogScript = preload("res://scripts/domain/definitions/ability_catalog.gd")
const AbilityResolverScript = preload("res://scripts/domain/services/ability_resolver.gd")

const LANE_COUNT := BoardStateScript.DEFAULT_LANE_COUNT
const STARTING_INTEGRITY := 20
const STARTING_HAND := 4
const MAX_HAND := 8
const STANDARD_ENERGY_CAP := 6
const ABSOLUTE_ENERGY_CAP := 12
const MAX_SEALS := 3
const MAX_RELICS := 3

var player_domain := Catalog.DOMAIN_FOREST
var enemy_domain := Catalog.DOMAIN_FOREST
var player_integrity := STARTING_INTEGRITY
var enemy_integrity := STARTING_INTEGRITY
var energy_capacity := 1
var energy_current := 1
var essence_current := 0
var turn := 1
var result := "ongoing"

var hand: Array[String] = []
var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var enemy_discard: Array[String] = []
var player_lanes: Array = BoardStateScript.make_empty_slots(LANE_COUNT)
var enemy_lanes: Array = BoardStateScript.make_empty_slots(LANE_COUNT)
var active_seals: Array[String] = []
var active_relics: Array[String] = []

var failed_draws := 0
var impulse_available := false
var last_revealed: Array[String] = []
var last_message := ""
var event_queue = EventQueueScript.new()
var turn_gates: Dictionary = {}
var cost_modifiers: Dictionary = {"player": [], "enemy": []}
var death_window_current: Dictionary = {"player": 0, "enemy": 0}
var death_window_previous: Dictionary = {"player": 0, "enemy": 0}

func setup(domain: String, deck_ids: Array[String], second_player: bool = false) -> void:
	player_domain = domain
	enemy_domain = domain
	player_integrity = STARTING_INTEGRITY
	enemy_integrity = STARTING_INTEGRITY
	energy_capacity = 1
	energy_current = 1
	essence_current = 0
	turn = 1
	result = "ongoing"
	hand.clear()
	draw_pile.clear()
	discard_pile.clear()
	enemy_discard.clear()
	player_lanes = BoardStateScript.make_empty_slots(LANE_COUNT)
	enemy_lanes = BoardStateScript.make_empty_slots(LANE_COUNT)
	active_seals.clear()
	active_relics.clear()
	failed_draws = 0
	impulse_available = second_player
	last_revealed.clear()
	last_message = ""
	event_queue.clear()
	turn_gates.clear()
	cost_modifiers = {"player": [], "enemy": []}
	death_window_current = {"player": 0, "enemy": 0}
	death_window_previous = {"player": 0, "enemy": 0}
	for card_id in deck_ids:
		if not Catalog.find_by_id(card_id).is_empty():
			draw_pile.append(card_id)
	for i in range(STARTING_HAND):
		draw_card()
	event_queue.clear()

func setup_starter(domain: String, second_player: bool = false) -> void:
	setup(domain, Catalog.starter_deck(domain), second_player)

func recharge_energy_for_new_turn() -> void:
	energy_capacity = mini(energy_capacity + 1, STANDARD_ENERGY_CAP)
	energy_current = energy_capacity

func begin_new_turn() -> void:
	if result != "ongoing":
		return
	turn += 1
	recharge_energy_for_new_turn()
	reset_turn_gates("player")
	_roll_death_window("player")
	_expire_cost_modifiers("player", "turn")
	_expire_statuses_for_turn("player")
	_reset_guard_usage(player_lanes)
	_reset_guard_usage(enemy_lanes)
	draw_card()
	event_queue.push(GameEventScript.create("TURN_STARTED", "", [], {"turn": turn}))

func draw_card() -> bool:
	if result != "ongoing":
		return false
	if hand.size() >= MAX_HAND:
		last_message = "La mano está llena."
		return false
	if draw_pile.is_empty():
		failed_draws += 1
		player_integrity -= failed_draws
		last_message = "Inestabilidad del Nexo: -%d Integridad." % failed_draws
		_check_result()
		return false
	var card_id := str(draw_pile.pop_front())
	hand.append(card_id)
	event_queue.push(GameEventScript.create("CARD_DRAWN", card_id, [], {"side":"player","turn":turn}))
	return true

func use_impulse() -> bool:
	if not impulse_available or result != "ongoing":
		return false
	impulse_available = false
	grant_temporary_energy(1)
	event_queue.push(GameEventScript.create("IMPULSE_USED"))
	return true

func grant_temporary_energy(amount: int) -> int:
	var before := energy_current
	energy_current = mini(ABSOLUTE_ENERGY_CAP, energy_current + maxi(0, amount))
	var gained := energy_current - before
	if gained > 0:
		event_queue.push(GameEventScript.create("RESOURCE_GAINED", "", [], {"resource": "energy", "amount": gained}))
	return gained

func resource_amount(resource_type: String) -> int:
	match resource_type:
		"energy":
			return energy_current
		"essence":
			return essence_current
		_:
			return 0

func spend_resource(resource_type: String, amount: int) -> bool:
	if amount < 0 or resource_amount(resource_type) < amount:
		return false
	match resource_type:
		"energy":
			energy_current -= amount
		"essence":
			essence_current -= amount
		_:
			return false
	if amount > 0:
		event_queue.push(GameEventScript.create("RESOURCE_SPENT", "", [], {"resource": resource_type, "amount": amount}))
	return true

func can_pay_energy(amount: int) -> bool:
	if amount < 0:
		return false
	return CostResolverScript.can_pay(CostDefinitionScript.energy(amount), self)

func spend_energy(amount: int) -> bool:
	if amount < 0:
		return false
	return CostResolverScript.pay(CostDefinitionScript.energy(amount), self)

func essence_name() -> String:
	return Catalog.essence_name(player_domain)

func essence_max() -> int:
	return Catalog.essence_max(player_domain)

func gain_essence(amount: int) -> int:
	var before := essence_current
	essence_current = mini(essence_max(), essence_current + maxi(0, amount))
	var gained := essence_current - before
	if gained > 0:
		event_queue.push(GameEventScript.create("RESOURCE_GAINED", "", [], {"resource": "essence", "amount": gained, "name": essence_name()}))
	return gained

func spend_essence(amount: int) -> bool:
	if amount < 0:
		return false
	return CostResolverScript.pay(CostDefinitionScript.essence(amount), self)

func drain_events() -> Array[Dictionary]:
	return event_queue.drain_serialized()

func reset_turn_gates(side: String) -> void:
	turn_gates[side] = {}

func consume_first_turn_gate(side: String, gate_id: String) -> bool:
	if gate_id.is_empty():
		return false
	if not turn_gates.has(side):
		turn_gates[side] = {}
	var gates: Dictionary = turn_gates[side]
	if bool(gates.get(gate_id, false)):
		return false
	gates[gate_id] = true
	turn_gates[side] = gates
	return true

func create_unit(card_id: String, ready: bool = false) -> Dictionary:
	var card := Catalog.find_by_id(card_id)
	if card.is_empty() or str(card.get("type", "")) != Catalog.TYPE_CREATURE:
		return {}
	var shield := 0
	for keyword in Array(card.get("keywords", [])):
		var code := str(keyword)
		if code.begins_with("BLINDAJE_"):
			shield += int(code.trim_prefix("BLINDAJE_"))
	return {
		"id": card_id,
		"name": str(card.get("name", card_id)),
		"domain": str(card.get("domain", "")),
		"attack": int(card.get("attack", 0)),
		"hp": int(card.get("health", 1)),
		"max_hp": int(card.get("health", 1)),
		"keywords": Array(card.get("keywords", [])).duplicate(),
		"tags": Array(card.get("tags", [])).duplicate(),
		"ready": ready or Array(card.get("keywords", [])).has("CARGA") or Array(card.get("keywords", [])).has("EMBESTIDA"),
		"has_fought": false,
		"guard_used": false,
		"shield": shield,
		"temp_attack": 0,
		"temp_health": 0,
		"statuses": [],
		"auras": [],
		"aura_attack": 0,
		"aura_health": 0
	}

func place_enemy_unit(card_id: String, lane: int, ready: bool = true) -> bool:
	if lane < 0 or lane >= LANE_COUNT or enemy_lanes[lane] != null:
		return false
	var unit := create_unit(card_id, ready)
	if unit.is_empty():
		return false
	enemy_lanes[lane] = unit
	return true

func ability_target_spec(card_id: String, trigger: String = AbilityDefinitionScript.ON_PLAY) -> Dictionary:
	var card := Catalog.find_by_id(card_id)
	if card.is_empty():
		return {}
	return AbilityCatalogScript.target_spec_for(str(card.get("effect_id", "")), trigger)

func play_card(hand_index: int, lane: int = -1, target_lane: int = -1, replace_index: int = -1, target_lanes: Array = [], destination_lane: int = -1) -> bool:
	if result != "ongoing" or hand_index < 0 or hand_index >= hand.size():
		return false
	var card_id := hand[hand_index]
	var card := Catalog.find_by_id(card_id)
	if card.is_empty():
		return false
	var cost := effective_card_cost(card_id, "player")
	if not can_pay_energy(cost):
		last_message = "Energía Rúnica insuficiente."
		return false
	var card_type := str(card.get("type", ""))
	var success := false
	match card_type:
		Catalog.TYPE_CREATURE:
			success = _play_creature(card, lane, target_lane, destination_lane)
		Catalog.TYPE_RITE:
			success = _play_rite(card, target_lane, target_lanes, destination_lane)
		Catalog.TYPE_RELIC:
			success = _play_persistent(card_id, active_relics, MAX_RELICS, replace_index)
		Catalog.TYPE_SEAL:
			success = _play_persistent(card_id, active_seals, MAX_SEALS, replace_index)
		_:
			success = false
	if not success:
		return false
	if not spend_energy(cost):
		return false
	hand.remove_at(hand_index)
	if card_type == Catalog.TYPE_RITE:
		discard_pile.append(card_id)
		if player_domain == Catalog.DOMAIN_TOWER:
			gain_essence(1)
	elif card_type == Catalog.TYPE_SEAL and player_domain == Catalog.DOMAIN_TOWER:
		gain_essence(1)
	if card_type == Catalog.TYPE_RELIC:
		event_queue.push(GameEventScript.create("RELIC_PLAYED", card_id, [], {"side":"player"}))
	elif card_type == Catalog.TYPE_SEAL:
		event_queue.push(GameEventScript.create("SEAL_PLAYED", card_id, [], {"side":"player"}))
	event_queue.push(GameEventScript.create("CARD_PLAYED", card_id, [], {
		"card_type": card_type,
		"lane": lane,
		"target_lane": target_lane,
		"target_lanes": target_lanes.duplicate(),
		"destination_lane": destination_lane
	}))
	return true

func _play_creature(card: Dictionary, lane: int, target_lane: int = -1, destination_lane: int = -1) -> bool:
	if lane < 0 or lane >= LANE_COUNT or player_lanes[lane] != null:
		last_message = "El carril no está disponible."
		return false
	var unit := create_unit(str(card.get("id", "")), false)
	if unit.is_empty():
		return false
	player_lanes[lane] = unit
	_recalculate_auras("player")
	_trigger_active_relics("player", AbilityDefinitionScript.FIRST_SUMMON_PER_TURN, {"source_side":"player","source_lane":lane,"target_lane":lane,"summoned_card_id":str(card.get("id",""))})
	if int(card.get("cost", 0)) >= 4:
		_trigger_active_relics("player", AbilityDefinitionScript.FIRST_HIGH_COST_UNIT_PER_TURN, {"source_side":"player","source_lane":lane,"target_lane":lane,"summoned_card_id":str(card.get("id",""))})
	event_queue.push(GameEventScript.create("UNIT_SUMMONED", str(card.get("id", "")), [], {"side":"player","lane":lane,"token":false}))
	_on_creature_entered(card, lane, target_lane, destination_lane)
	return true

func _play_persistent(card_id: String, slots: Array[String], limit: int, replace_index: int) -> bool:
	if slots.size() < limit:
		slots.append(card_id)
		return true
	if replace_index < 0 or replace_index >= limit:
		last_message = "Debes elegir qué espacio reemplazar."
		return false
	discard_pile.append(slots[replace_index])
	slots[replace_index] = card_id
	return true

func _play_rite(card: Dictionary, target_lane: int, target_lanes: Array = [], destination_lane: int = -1) -> bool:
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return false
	return AbilityResolverScript.resolve(effect_id, AbilityDefinitionScript.ON_PLAY, {
		"source_card_id": str(card.get("id", "")),
		"source_side": "player",
		"source_lane": -1,
		"target_lane": target_lane,
		"target_lanes": target_lanes.duplicate(),
		"destination_lane": destination_lane
	}, self)

func _on_creature_entered(card: Dictionary, lane: int, target_lane: int = -1, destination_lane: int = -1) -> void:
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return
	AbilityResolverScript.resolve(effect_id, AbilityDefinitionScript.ON_SUMMON, {
		"source_card_id": str(card.get("id", "")),
		"source_side": "player",
		"source_lane": lane,
		"target_lane": target_lane if target_lane >= 0 else lane,
		"destination_lane": destination_lane
	}, self)

func resolve_player_attacks() -> void:
	if result != "ongoing":
		return
	event_queue.push(GameEventScript.create("COMBAT_STARTED", "", [], {"side":"player","turn":turn}))
	for lane in range(LANE_COUNT):
		var attacker = player_lanes[lane]
		if attacker == null or not bool(attacker.get("ready", false)):
			continue
		event_queue.push(GameEventScript.create("UNIT_ATTACK_STARTED", str(attacker.get("id", "")), [], {"side":"player","lane":lane}))
		var defender_lane := lane
		if enemy_lanes[defender_lane] == null:
			defender_lane = _guard_interceptor(enemy_lanes, lane)
		var attacker_card := Catalog.find_by_id(str(attacker.get("id", "")))
		var attacker_effect := str(attacker_card.get("effect_id", ""))
		if not attacker_effect.is_empty():
			AbilityResolverScript.resolve(attacker_effect, AbilityDefinitionScript.ON_ATTACK, {
				"source_card_id": str(attacker.get("id", "")),
				"source_side": "player",
				"source_lane": lane,
				"target_lane": defender_lane,
				"blocked": defender_lane >= 0
			}, self)
		if defender_lane < 0:
			var damage := maxi(0, int(attacker.get("attack", 0)))
			enemy_integrity -= damage
			if damage > 0 and player_domain == Catalog.DOMAIN_FOREST:
				gain_essence(1)
			_check_result()
			if result != "ongoing":
				return
			continue
		if defender_lane != lane:
			var guard: Dictionary = enemy_lanes[defender_lane]
			guard["guard_used"] = true
		_resolve_creature_combat(lane, defender_lane)
		if result != "ongoing":
			event_queue.push(GameEventScript.create("COMBAT_ENDED", "", [], {"side":"player","turn":turn}))
			return
	event_queue.push(GameEventScript.create("COMBAT_ENDED", "", [], {"side":"player","turn":turn}))

func _resolve_creature_combat(player_lane: int, enemy_lane: int) -> void:
	var attacker: Dictionary = player_lanes[player_lane]
	var defender: Dictionary = enemy_lanes[enemy_lane]
	if attacker.is_empty() or defender.is_empty():
		return
	var attacker_damage := maxi(0, int(attacker.get("attack", 0)))
	var defender_damage := maxi(0, int(defender.get("attack", 0)))
	var ambush := _unit_has_keyword(attacker, "EMBOSCADA") and not bool(attacker.get("has_fought", false))
	attacker["has_fought"] = true
	if ambush:
		_deal_damage_to_unit(false, enemy_lane, attacker_damage, str(attacker.get("id", "")), "player")
		if enemy_lanes[enemy_lane] != null:
			_deal_damage_to_unit(true, player_lane, defender_damage, str(defender.get("id", "")), "enemy")
	else:
		_deal_damage_to_unit(false, enemy_lane, attacker_damage, str(attacker.get("id", "")), "player")
		_deal_damage_to_unit(true, player_lane, defender_damage, str(defender.get("id", "")), "enemy")

func end_player_turn() -> void:
	if result != "ongoing":
		return
	resolve_player_attacks()
	_expire_temporary_bonuses()
	if player_domain == Catalog.DOMAIN_FORGE and essence_current >= 6 and result == "ongoing":
		player_integrity -= 1
		essence_current = 3
		last_message = "Sobrecarga: el Nexo recibe 1 daño."
		_check_result()
	for i in range(LANE_COUNT):
		if player_lanes[i] != null:
			var unit: Dictionary = player_lanes[i]
			unit["ready"] = true

func _deal_damage_to_unit(player_side: bool, lane: int, amount: int, source_id: String = "", source_side: String = "") -> int:
	var lanes: Array = player_lanes if player_side else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return 0
	var unit: Dictionary = lanes[lane]
	var shield := int(unit.get("shield", 0))
	var damage := maxi(0, amount)
	if shield > 0 and damage > 0:
		damage = maxi(0, damage - shield)
		unit["shield"] = 0
	unit["hp"] = int(unit.get("hp", 0)) - damage
	event_queue.push(GameEventScript.create("DAMAGE_DEALT", source_id, [str(unit.get("id", ""))], {
		"source_side": source_side,
		"target_side": "player" if player_side else "enemy",
		"lane": lane,
		"amount": damage
	}))
	if int(unit.get("hp", 0)) <= 0:
		_kill_unit(player_side, lane, "damage", source_id, source_side)
	return damage

func _heal_unit(player_side: bool, lane: int, amount: int, source_id: String = "", source_side: String = "") -> int:
	var lanes: Array = player_lanes if player_side else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return 0
	var unit: Dictionary = lanes[lane]
	var before := int(unit.get("hp", 0))
	unit["hp"] = mini(int(unit.get("max_hp", 1)), before + maxi(0, amount))
	var healed := int(unit.get("hp", 0)) - before
	event_queue.push(GameEventScript.create("HEAL_APPLIED", source_id, [str(unit.get("id", ""))], {
		"source_side": source_side,
		"target_side": "player" if player_side else "enemy",
		"lane": lane,
		"amount": healed
	}))
	return healed

func _kill_unit(player_side: bool, lane: int, death_reason: String = "destroyed", source_id: String = "", source_side: String = "") -> void:
	var lanes: Array = player_lanes if player_side else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return
	var unit: Dictionary = lanes[lane]
	_trigger_last_breath(unit, player_side, lane)
	var card_id := str(unit.get("id", ""))
	if player_side:
		discard_pile.append(card_id)
		if player_domain == Catalog.DOMAIN_CRYPT:
			gain_essence(1)
	else:
		enemy_discard.append(card_id)
	lanes[lane] = null
	var dead_side := "player" if player_side else "enemy"
	_record_death(dead_side)
	_recalculate_auras(dead_side)
	if dead_side != _current_turn_side():
		_trigger_active_relics(dead_side, AbilityDefinitionScript.FIRST_ALLY_DEATH_BETWEEN_TURNS, {"source_side":dead_side,"target_lane":lane,"source_lane":lane,"dead_card_id":card_id})
	if death_reason == "sacrifice":
		event_queue.push(GameEventScript.create("UNIT_SACRIFICED", card_id, [], {
			"side": "player" if player_side else "enemy",
			"lane": lane,
			"source_id": source_id,
			"source_side": source_side
		}))
	event_queue.push(GameEventScript.create("UNIT_DIED", card_id, [], {
		"side": "player" if player_side else "enemy",
		"lane": lane,
		"death_reason": death_reason,
		"source_id": source_id,
		"source_side": source_side
	}))

func _trigger_last_breath(unit: Dictionary, player_side: bool, lane: int) -> void:
	if not player_side:
		return
	var card_id := str(unit.get("id", ""))
	var card := Catalog.find_by_id(card_id)
	if card.is_empty():
		return
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return
	AbilityResolverScript.resolve(effect_id, AbilityDefinitionScript.ON_DEATH, {
		"source_card_id": card_id,
		"source_side": "player",
		"source_lane": lane,
		"target_lane": lane
	}, self)

func _expire_temporary_bonuses() -> void:
	for lane in range(LANE_COUNT):
		if player_lanes[lane] == null:
			continue
		var unit: Dictionary = player_lanes[lane]
		var temp_attack := int(unit.get("temp_attack", 0))
		var temp_health := int(unit.get("temp_health", 0))
		if temp_attack > 0:
			unit["attack"] = maxi(0, int(unit.get("attack", 0)) - temp_attack)
			unit["temp_attack"] = 0
		if temp_health > 0:
			unit["max_hp"] = maxi(1, int(unit.get("max_hp", 1)) - temp_health)
			unit["hp"] = int(unit.get("hp", 0)) - temp_health
			unit["temp_health"] = 0
			if int(unit.get("hp", 0)) <= 0:
				_kill_unit(true, lane)

func _apply_status_to_unit(side: String, lane: int, status_id: String, duration: String = "until_next_turn", source_id: String = "", source_side: String = "") -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	if status_id.is_empty() or not _valid_occupied_lane(lanes, lane):
		return false
	var unit: Dictionary = lanes[lane]
	var statuses: Array = Array(unit.get("statuses", []))
	for i in range(statuses.size()):
		var existing: Dictionary = Dictionary(statuses[i])
		if str(existing.get("id", "")) == status_id:
			existing["duration"] = duration
			existing["source_id"] = source_id
			existing["source_side"] = source_side
			existing["expires_on_side"] = source_side if duration == "until_next_turn" else side
			statuses[i] = existing
			unit["statuses"] = statuses
			return true
	statuses.append({"id":status_id,"duration":duration,"source_id":source_id,"source_side":source_side,"expires_on_side":source_side if duration == "until_next_turn" else side})
	unit["statuses"] = statuses
	event_queue.push(GameEventScript.create("STATUS_APPLIED", source_id, [str(unit.get("id", ""))], {"side":side,"lane":lane,"status":status_id,"duration":duration,"source_side":source_side}))
	return true

func _unit_has_status(unit: Dictionary, status_id: String) -> bool:
	if status_id == "ROOTED":
		var keywords: Array = Array(unit.get("keywords", []))
		if keywords.has("ROOTED") or keywords.has("ENRAIZADO"):
			return true
	for raw_status in Array(unit.get("statuses", [])):
		if str(Dictionary(raw_status).get("id", "")) == status_id:
			return true
	return false

func _expire_statuses_for_turn(turn_side: String) -> void:
	for board_side in ["player", "enemy"]:
		var lanes: Array = player_lanes if board_side == "player" else enemy_lanes
		for lane in range(lanes.size()):
			if lanes[lane] == null:
				continue
			var unit: Dictionary = lanes[lane]
			var kept: Array = []
			for raw_status in Array(unit.get("statuses", [])):
				var status: Dictionary = Dictionary(raw_status)
				var expires_on := str(status.get("expires_on_side", board_side))
				if str(status.get("duration", "")) == "until_next_turn" and expires_on == turn_side:
					event_queue.push(GameEventScript.create("STATUS_EXPIRED", str(status.get("source_id", "")), [str(unit.get("id", ""))], {"side":board_side,"lane":lane,"status":str(status.get("id", "")),"expired_on_turn":turn_side}))
				else:
					kept.append(status)
			unit["statuses"] = kept

func _expire_statuses_for_side(side: String) -> void:
	_expire_statuses_for_turn(side)

func _move_unit(side: String, from_lane: int, to_lane: int, forced: bool = false, source_id: String = "", source_side: String = "", max_distance: int = -1) -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	if from_lane < 0 or from_lane >= lanes.size() or to_lane < 0 or to_lane >= lanes.size() or from_lane == to_lane:
		return false
	if max_distance >= 0 and absi(to_lane - from_lane) > max_distance:
		return false
	if lanes[from_lane] == null or lanes[to_lane] != null:
		return false
	var unit: Dictionary = lanes[from_lane]
	if _unit_has_status(unit, "ROOTED"):
		return false
	lanes[to_lane] = unit
	lanes[from_lane] = null
	_recalculate_auras(side)
	event_queue.push(GameEventScript.create("UNIT_MOVED", str(unit.get("id", "")), [], {"side":side,"from_lane":from_lane,"to_lane":to_lane,"forced":forced,"source_id":source_id,"source_side":source_side}))
	return true

func _swap_units(side: String, lane_a: int, lane_b: int, source_id: String = "", source_side: String = "") -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	if lane_a < 0 or lane_a >= lanes.size() or lane_b < 0 or lane_b >= lanes.size() or lane_a == lane_b:
		return false
	if lanes[lane_a] == null or lanes[lane_b] == null:
		return false
	var unit_a: Dictionary = lanes[lane_a]
	var unit_b: Dictionary = lanes[lane_b]
	if _unit_has_status(unit_a, "ROOTED") or _unit_has_status(unit_b, "ROOTED"):
		return false
	lanes[lane_a] = unit_b
	lanes[lane_b] = unit_a
	_recalculate_auras(side)
	event_queue.push(GameEventScript.create("UNIT_MOVED", str(unit_a.get("id", "")), [], {"side":side,"from_lane":lane_a,"to_lane":lane_b,"forced":false,"source_id":source_id,"source_side":source_side}))
	event_queue.push(GameEventScript.create("UNIT_MOVED", str(unit_b.get("id", "")), [], {"side":side,"from_lane":lane_b,"to_lane":lane_a,"forced":false,"source_id":source_id,"source_side":source_side}))
	event_queue.push(GameEventScript.create("UNITS_SWAPPED", source_id, [str(unit_a.get("id", "")),str(unit_b.get("id", ""))], {"side":side,"lane_a":lane_a,"lane_b":lane_b,"source_side":source_side}))
	return true

func add_cost_modifier(side: String, modifier_id: String, delta: int, floor: int = 1, duration: String = "turn", card_type: String = "", min_base_cost: int = -1) -> void:
	if side != "player" and side != "enemy":
		return
	var list: Array = Array(cost_modifiers.get(side, []))
	for i in range(list.size()):
		var existing: Dictionary = Dictionary(list[i])
		if str(existing.get("id", "")) == modifier_id:
			existing["delta"] = delta
			existing["floor"] = floor
			existing["duration"] = duration
			existing["card_type"] = card_type
			existing["min_base_cost"] = min_base_cost
			list[i] = existing
			cost_modifiers[side] = list
			return
	list.append({"id": modifier_id, "delta": delta, "floor": floor, "duration": duration, "card_type": card_type, "min_base_cost": min_base_cost})
	cost_modifiers[side] = list

func _expire_cost_modifiers(side: String, duration: String) -> void:
	var kept: Array = []
	for raw in Array(cost_modifiers.get(side, [])):
		var modifier: Dictionary = Dictionary(raw)
		if str(modifier.get("duration", "")) != duration:
			kept.append(modifier)
	cost_modifiers[side] = kept

func effective_card_cost(card_id: String, side: String = "player") -> int:
	var card := Catalog.find_by_id(card_id)
	if card.is_empty():
		return 0
	var base_cost := int(card.get("cost", 0))
	var result_cost := base_cost
	var intrinsic: Dictionary = Dictionary(card.get("cost_rule", {}))
	if str(intrinsic.get("type", "")) == "deaths_since_last_turn":
		var reduction_per_death := maxi(0, int(intrinsic.get("reduction_per_death", 1)))
		var intrinsic_floor := maxi(0, int(intrinsic.get("floor", 0)))
		result_cost = maxi(intrinsic_floor, result_cost - deaths_since_last_turn(side) * reduction_per_death)
	for raw in Array(cost_modifiers.get(side, [])):
		var modifier: Dictionary = Dictionary(raw)
		var required_type := str(modifier.get("card_type", ""))
		if not required_type.is_empty() and str(card.get("type", "")) != required_type:
			continue
		var min_base := int(modifier.get("min_base_cost", -1))
		if min_base >= 0 and base_cost < min_base:
			continue
		result_cost += int(modifier.get("delta", 0))
		result_cost = maxi(int(modifier.get("floor", 0)), result_cost)
	return maxi(0, result_cost)

func _record_death(side: String) -> void:
	death_window_current[side] = int(death_window_current.get(side, 0)) + 1

func _roll_death_window(side: String) -> void:
	death_window_previous[side] = int(death_window_current.get(side, 0))
	death_window_current[side] = 0

func deaths_since_last_turn(side: String) -> int:
	return int(death_window_previous.get(side, 0))

func _deck_for_side(side: String) -> Array:
	if side == "enemy" and has_method("cpu_deck_reference"):
		return call("cpu_deck_reference")
	return draw_pile

func _move_discard_creature_to_deck_bottom(side: String, requested_card_id: String = "", max_cost: int = 999, source_id: String = "") -> bool:
	var discard: Array = enemy_discard if side == "enemy" else discard_pile
	var deck: Array = _deck_for_side(side)
	for i in range(discard.size() - 1, -1, -1):
		var card_id := str(discard[i])
		if not requested_card_id.is_empty() and card_id != requested_card_id:
			continue
		var card := Catalog.find_by_id(card_id)
		if card.is_empty() or str(card.get("type", "")) != Catalog.TYPE_CREATURE or int(card.get("cost", 999)) > max_cost:
			continue
		discard.remove_at(i)
		deck.append(card_id)
		event_queue.push(GameEventScript.create("CARD_MOVED_TO_DECK_BOTTOM", source_id, [card_id], {"side": side}))
		return true
	return false

func _modify_unit_stats_permanent(side: String, lane: int, attack_delta: int, health_delta: int, source_id: String = "", source_side: String = "") -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return false
	var unit: Dictionary = lanes[lane]
	unit["attack"] = maxi(0, int(unit.get("attack", 0)) + attack_delta)
	if health_delta != 0:
		unit["max_hp"] = maxi(1, int(unit.get("max_hp", 1)) + health_delta)
		unit["hp"] = clampi(int(unit.get("hp", 0)) + health_delta, 1, int(unit.get("max_hp", 1)))
	event_queue.push(GameEventScript.create("STATS_MODIFIED_PERMANENT", source_id, [str(unit.get("id", ""))], {"side": side, "lane": lane, "attack": attack_delta, "health": health_delta, "source_side": source_side}))
	return true

func _add_aura_to_unit(side: String, lane: int, aura_id: String, attack: int = 0, health: int = 0, radius: int = 1) -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	if aura_id.is_empty() or not _valid_occupied_lane(lanes, lane):
		return false
	var unit: Dictionary = lanes[lane]
	var auras: Array = Array(unit.get("auras", []))
	var replaced := false
	for i in range(auras.size()):
		var existing: Dictionary = Dictionary(auras[i])
		if str(existing.get("id", "")) == aura_id:
			auras[i] = {"id": aura_id, "attack": attack, "health": health, "radius": maxi(1, radius)}
			replaced = true
			break
	if not replaced:
		auras.append({"id": aura_id, "attack": attack, "health": health, "radius": maxi(1, radius)})
	unit["auras"] = auras
	_recalculate_auras(side)
	return true

func _recalculate_auras(side: String) -> void:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	for lane in range(lanes.size()):
		if lanes[lane] == null:
			continue
		var unit: Dictionary = lanes[lane]
		var old_max_hp := int(unit.get("max_hp", 1))
		var damage_taken := maxi(0, old_max_hp - int(unit.get("hp", 0)))
		unit["_aura_damage_taken"] = damage_taken
		unit["attack"] = maxi(0, int(unit.get("attack", 0)) - int(unit.get("aura_attack", 0)))
		unit["max_hp"] = maxi(1, old_max_hp - int(unit.get("aura_health", 0)))
		unit["aura_attack"] = 0
		unit["aura_health"] = 0
	for source_lane in range(lanes.size()):
		if lanes[source_lane] == null:
			continue
		var source: Dictionary = lanes[source_lane]
		for raw_aura in Array(source.get("auras", [])):
			var aura: Dictionary = Dictionary(raw_aura)
			var radius := maxi(1, int(aura.get("radius", 1)))
			for target_lane in range(lanes.size()):
				if target_lane == source_lane or lanes[target_lane] == null or absi(target_lane - source_lane) > radius:
					continue
				var target: Dictionary = lanes[target_lane]
				var attack_bonus := int(aura.get("attack", 0))
				var health_bonus := int(aura.get("health", 0))
				target["attack"] = int(target.get("attack", 0)) + attack_bonus
				target["aura_attack"] = int(target.get("aura_attack", 0)) + attack_bonus
				target["max_hp"] = maxi(1, int(target.get("max_hp", 1)) + health_bonus)
				target["aura_health"] = int(target.get("aura_health", 0)) + health_bonus
	for lane in range(lanes.size()):
		if lanes[lane] == null:
			continue
		var unit: Dictionary = lanes[lane]
		var damage_taken := int(unit.get("_aura_damage_taken", 0))
		unit["hp"] = maxi(1, int(unit.get("max_hp", 1)) - damage_taken)
		unit.erase("_aura_damage_taken")

func _current_turn_side() -> String:
	return "player"

func _active_relics_for_side(side: String) -> Array:
	if side == "enemy" and has_method("cpu_relics_reference"):
		return call("cpu_relics_reference")
	return active_relics

func _trigger_active_relics(side: String, trigger: String, context: Dictionary) -> void:
	for relic_id in _active_relics_for_side(side):
		var card := Catalog.find_by_id(str(relic_id))
		var effect_id := str(card.get("effect_id", ""))
		if effect_id.is_empty():
			continue
		var gate_id := "%s:%s" % [str(relic_id), trigger]
		if not consume_first_turn_gate(side, gate_id):
			continue
		var local_context := context.duplicate(true)
		local_context["source_card_id"] = str(relic_id)
		local_context["source_side"] = side
		AbilityResolverScript.resolve(effect_id, trigger, local_context, self)

func _has_adjacent_ally(side: String, lane: int) -> bool:
	var lanes: Array = player_lanes if side == "player" else enemy_lanes
	for offset in [-1, 1]:
		var candidate := lane + int(offset)
		if candidate >= 0 and candidate < lanes.size() and lanes[candidate] != null:
			return true
	return false

func _heal_nexus(side: String, amount: int, source_id: String = "") -> int:
	var healed := 0
	if side == "enemy":
		var before := enemy_integrity
		enemy_integrity = mini(STARTING_INTEGRITY, enemy_integrity + maxi(0, amount))
		healed = enemy_integrity - before
	else:
		var before := player_integrity
		player_integrity = mini(STARTING_INTEGRITY, player_integrity + maxi(0, amount))
		healed = player_integrity - before
	if healed > 0:
		event_queue.push(GameEventScript.create("NEXUS_HEALED", source_id, [], {"side":side,"amount":healed}))
	return healed

func _damage_enemy_nexus(source_side: String, amount: int, source_id: String = "") -> int:
	var damage := maxi(0, amount)
	if source_side == "enemy":
		player_integrity -= damage
	else:
		enemy_integrity -= damage
	if damage > 0:
		event_queue.push(GameEventScript.create("NEXUS_DAMAGED", source_id, [], {"side":"player" if source_side == "enemy" else "enemy","amount":damage}))
	_check_result()
	return damage

func _guard_interceptor(lanes: Array, target_lane: int) -> int:
	for offset in [-1, 1]:
		var candidate_lane: int = target_lane + int(offset)
		if candidate_lane < 0 or candidate_lane >= LANE_COUNT:
			continue
		var candidate = lanes[candidate_lane]
		if candidate != null and _unit_has_keyword(candidate, "GUARDIA") and not bool(candidate.get("guard_used", false)):
			return candidate_lane
	return -1

func _unit_has_keyword(unit: Dictionary, keyword: String) -> bool:
	return Array(unit.get("keywords", [])).has(keyword)

func _first_free_lane(lanes: Array) -> int:
	for i in range(LANE_COUNT):
		if lanes[i] == null:
			return i
	return -1

func _valid_occupied_lane(lanes: Array, lane: int) -> bool:
	return lane >= 0 and lane < LANE_COUNT and lanes[lane] != null

func _make_token(id: String, name: String, attack: int, health: int, tags: Array) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"domain": player_domain,
		"attack": attack,
		"hp": health,
		"max_hp": health,
		"keywords": [],
		"tags": tags.duplicate(),
		"ready": false,
		"has_fought": false,
		"guard_used": false,
		"shield": 0,
		"temp_attack": 0,
		"temp_health": 0,
		"statuses": [],
		"auras": [],
		"aura_attack": 0,
		"aura_health": 0
	}

func _reset_guard_usage(lanes: Array) -> void:
	for unit in lanes:
		if unit != null:
			unit["guard_used"] = false

func _check_result() -> void:
	var previous_result := result
	if enemy_integrity <= 0:
		result = "victory"
	elif player_integrity <= 0:
		result = "defeat"
	if previous_result == "ongoing" and result != "ongoing":
		event_queue.push(GameEventScript.create("BATTLE_ENDED", "", [], {"result": result}))

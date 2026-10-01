class_name CanonicalCpuBattle
extends CanonicalBattleState

const CatalogScript = preload("res://scripts/domain/canonical_card_catalog.gd")
const AbilityDefinitionScriptCpu = preload("res://scripts/domain/definitions/ability_definition.gd")
const AbilityResolverScriptCpu = preload("res://scripts/domain/services/ability_resolver.gd")
const TargetSpecScriptCpu = preload("res://scripts/domain/value_objects/target_spec.gd")
const CostDefinitionScriptCpu = preload("res://scripts/domain/value_objects/cost_definition.gd")
const CostResolverScriptCpu = preload("res://scripts/domain/services/cost_resolver.gd")
const BattleSidePayerScript = preload("res://scripts/domain/services/battle_side_payer.gd")
const CpuActionPolicyScript = preload("res://scripts/domain/services/cpu_action_policy.gd")
const GameEventScriptCpu = preload("res://scripts/domain/events/game_event.gd")

var cpu_hand: Array[String] = []
var cpu_draw_pile: Array[String] = []
var cpu_energy_capacity := 1
var cpu_energy_current := 1
var cpu_essence_current := 0
var cpu_failed_draws := 0
var cpu_last_revealed: Array[String] = []
var cpu_active_seals: Array[String] = []
var cpu_active_relics: Array[String] = []

func setup_cpu(domain: String, player_deck: Array[String], enemy_domain_value: String = "", enemy_deck: Array[String] = []) -> void:
	setup(domain, player_deck)
	enemy_domain = domain if enemy_domain_value.is_empty() else enemy_domain_value
	cpu_hand.clear()
	cpu_draw_pile.clear()
	cpu_energy_capacity = 1
	cpu_energy_current = 1
	cpu_essence_current = 0
	cpu_failed_draws = 0
	cpu_last_revealed.clear()
	cpu_active_seals.clear()
	cpu_active_relics.clear()
	var source_deck: Array[String] = enemy_deck
	if source_deck.is_empty():
		source_deck = CatalogScript.starter_deck(enemy_domain)
	for card_id in source_deck:
		cpu_draw_pile.append(card_id)
	for i in range(STARTING_HAND):
		cpu_draw_card()
	# Igual que con la mano del jugador, el setup no deja ruido de eventos jugables.
	event_queue.clear()

func setup_cpu_starter(domain: String) -> void:
	setup_cpu(domain, CatalogScript.starter_deck(domain), domain, CatalogScript.starter_deck(domain))

func advance_round() -> void:
	if result != "ongoing":
		return
	end_player_turn()
	if result != "ongoing":
		return
	run_cpu_turn()
	if result != "ongoing":
		return
	begin_new_turn()

func run_cpu_turn() -> void:
	if result != "ongoing":
		return
	cpu_energy_capacity = mini(maxi(1, turn), STANDARD_ENERGY_CAP)
	cpu_energy_current = cpu_energy_capacity
	cpu_draw_card()
	cpu_take_actions()
	resolve_cpu_attacks()
	_expire_cpu_temporary_bonuses()
	_resolve_cpu_overload()
	for lane in range(LANE_COUNT):
		if enemy_lanes[lane] != null:
			var unit: Dictionary = enemy_lanes[lane]
			unit["ready"] = true

func cpu_take_actions() -> void:
	var safety := 0
	while result == "ongoing" and safety < 24:
		var action := CpuActionPolicyScript.choose_action(self)
		if action.is_empty():
			return
		var ok := cpu_play_card(
			int(action.get("hand_index", -1)),
			int(action.get("lane", -1)),
			int(action.get("target_lane", -1)),
			int(action.get("replace_index", -1))
		)
		if not ok:
			return
		safety += 1

func cpu_legal_actions_for_card(hand_index: int) -> Array:
	var actions: Array = []
	if hand_index < 0 or hand_index >= cpu_hand.size():
		return actions
	var card := CatalogScript.find_by_id(cpu_hand[hand_index])
	if card.is_empty():
		return actions
	var cost := int(card.get("cost", 0))
	if not cpu_can_pay_energy(cost):
		return actions
	var card_type := str(card.get("type", ""))
	match card_type:
		CatalogScript.TYPE_CREATURE:
			for lane in range(LANE_COUNT):
				if enemy_lanes[lane] == null:
					actions.append({"lane": lane, "target_lane": -1, "replace_index": -1})
		CatalogScript.TYPE_RITE:
			var spec := ability_target_spec(str(card.get("id", "")), AbilityDefinitionScriptCpu.ON_PLAY)
			var target_type := str(spec.get("type", TargetSpecScriptCpu.NONE))
			if target_type == TargetSpecScriptCpu.PLAYER_LANE:
				for lane in range(LANE_COUNT):
					if _cpu_can_resolve_rite(card, lane):
						actions.append({"lane": -1, "target_lane": lane, "replace_index": -1})
			elif target_type == TargetSpecScriptCpu.ENEMY_LANE:
				for lane in range(LANE_COUNT):
					if _cpu_can_resolve_rite(card, lane):
						actions.append({"lane": -1, "target_lane": lane, "replace_index": -1})
			else:
				if _cpu_can_resolve_rite(card, -1):
					actions.append({"lane": -1, "target_lane": -1, "replace_index": -1})
		CatalogScript.TYPE_RELIC:
			var relic_replace := -1 if cpu_active_relics.size() < MAX_RELICS else 0
			actions.append({"lane": -1, "target_lane": -1, "replace_index": relic_replace})
		CatalogScript.TYPE_SEAL:
			var seal_replace := -1 if cpu_active_seals.size() < MAX_SEALS else 0
			actions.append({"lane": -1, "target_lane": -1, "replace_index": seal_replace})
	return actions

func cpu_play_card(hand_index: int, lane: int = -1, target_lane: int = -1, replace_index: int = -1) -> bool:
	if result != "ongoing" or hand_index < 0 or hand_index >= cpu_hand.size():
		return false
	var card_id := cpu_hand[hand_index]
	var card := CatalogScript.find_by_id(card_id)
	if card.is_empty():
		return false
	var cost := int(card.get("cost", 0))
	if not cpu_can_pay_energy(cost):
		return false
	var card_type := str(card.get("type", ""))
	var success := false
	match card_type:
		CatalogScript.TYPE_CREATURE:
			success = _cpu_play_creature(card, lane)
		CatalogScript.TYPE_RITE:
			success = _cpu_play_rite(card, target_lane)
		CatalogScript.TYPE_RELIC:
			success = _cpu_play_persistent(card_id, cpu_active_relics, MAX_RELICS, replace_index)
		CatalogScript.TYPE_SEAL:
			success = _cpu_play_persistent(card_id, cpu_active_seals, MAX_SEALS, replace_index)
	if not success:
		return false
	if not cpu_spend_energy(cost):
		return false
	cpu_hand.remove_at(hand_index)
	if card_type == CatalogScript.TYPE_RITE:
		enemy_discard.append(card_id)
		if enemy_domain == CatalogScript.DOMAIN_TOWER:
			cpu_gain_essence(1)
	elif card_type == CatalogScript.TYPE_SEAL and enemy_domain == CatalogScript.DOMAIN_TOWER:
		cpu_gain_essence(1)
	event_queue.push(GameEventScriptCpu.create("CARD_PLAYED", card_id, [], {
		"side": "enemy",
		"card_type": card_type,
		"lane": lane,
		"target_lane": target_lane
	}))
	return true

func _cpu_play_creature(card: Dictionary, lane: int) -> bool:
	if lane < 0 or lane >= LANE_COUNT or enemy_lanes[lane] != null:
		return false
	var unit := create_unit(str(card.get("id", "")), false)
	if unit.is_empty():
		return false
	enemy_lanes[lane] = unit
	var effect_id := str(card.get("effect_id", ""))
	if not effect_id.is_empty():
		AbilityResolverScriptCpu.resolve(effect_id, AbilityDefinitionScriptCpu.ON_SUMMON, {
			"source_card_id": str(card.get("id", "")),
			"source_side": "enemy",
			"source_lane": lane,
			"target_lane": lane
		}, self)
	return true

func _cpu_play_rite(card: Dictionary, target_lane: int) -> bool:
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return false
	return AbilityResolverScriptCpu.resolve(effect_id, AbilityDefinitionScriptCpu.ON_PLAY, {
		"source_card_id": str(card.get("id", "")),
		"source_side": "enemy",
		"source_lane": -1,
		"target_lane": target_lane
	}, self)

func _cpu_can_resolve_rite(card: Dictionary, target_lane: int) -> bool:
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return false
	return AbilityResolverScriptCpu.can_resolve(effect_id, AbilityDefinitionScriptCpu.ON_PLAY, {
		"source_card_id": str(card.get("id", "")),
		"source_side": "enemy",
		"source_lane": -1,
		"target_lane": target_lane
	}, self)

func _cpu_play_persistent(card_id: String, slots: Array[String], limit: int, replace_index: int) -> bool:
	if slots.size() < limit:
		slots.append(card_id)
		return true
	if replace_index < 0 or replace_index >= limit:
		return false
	enemy_discard.append(slots[replace_index])
	slots[replace_index] = card_id
	return true

func cpu_essence_name() -> String:
	return CatalogScript.essence_name(enemy_domain)

func cpu_essence_max() -> int:
	return CatalogScript.essence_max(enemy_domain)

func cpu_gain_essence(amount: int) -> int:
	var before := cpu_essence_current
	cpu_essence_current = mini(cpu_essence_max(), cpu_essence_current + maxi(0, amount))
	var gained := cpu_essence_current - before
	if gained > 0:
		event_queue.push(GameEventScriptCpu.create("RESOURCE_GAINED", "", [], {
			"side": "enemy",
			"resource": "essence",
			"amount": gained,
			"name": cpu_essence_name()
		}))
	return gained

func cpu_grant_temporary_energy(amount: int) -> int:
	var before := cpu_energy_current
	cpu_energy_current = mini(ABSOLUTE_ENERGY_CAP, cpu_energy_current + maxi(0, amount))
	var gained := cpu_energy_current - before
	if gained > 0:
		event_queue.push(GameEventScriptCpu.create("RESOURCE_GAINED", "", [], {
			"side": "enemy",
			"resource": "energy",
			"amount": gained
		}))
	return gained

func cpu_resource_amount(resource_type: String) -> int:
	match resource_type:
		"energy":
			return cpu_energy_current
		"essence":
			return cpu_essence_current
		_:
			return 0

func resource_amount_for_side(side: String, resource_type: String) -> int:
	return cpu_resource_amount(resource_type) if side == "enemy" else resource_amount(resource_type)

func spend_resource_for_side(side: String, resource_type: String, amount: int) -> bool:
	if side != "enemy":
		return spend_resource(resource_type, amount)
	if amount < 0 or cpu_resource_amount(resource_type) < amount:
		return false
	match resource_type:
		"energy":
			cpu_energy_current -= amount
		"essence":
			cpu_essence_current -= amount
		_:
			return false
	if amount > 0:
		event_queue.push(GameEventScriptCpu.create("RESOURCE_SPENT", "", [], {
			"side": "enemy",
			"resource": resource_type,
			"amount": amount
		}))
	return true

func cpu_can_pay_energy(amount: int) -> bool:
	if amount < 0:
		return false
	var payer = BattleSidePayerScript.new(self, "enemy")
	return CostResolverScriptCpu.can_pay(CostDefinitionScriptCpu.energy(amount), payer)

func cpu_spend_energy(amount: int) -> bool:
	if amount < 0:
		return false
	var payer = BattleSidePayerScript.new(self, "enemy")
	return CostResolverScriptCpu.pay(CostDefinitionScriptCpu.energy(amount), payer)

func cpu_draw_card() -> bool:
	if cpu_hand.size() >= MAX_HAND:
		return false
	if cpu_draw_pile.is_empty():
		cpu_failed_draws += 1
		enemy_integrity -= cpu_failed_draws
		_check_result()
		return false
	cpu_hand.append(cpu_draw_pile.pop_front())
	return true

func _cpu_draw_card() -> bool:
	return cpu_draw_card()

func resolve_cpu_attacks() -> void:
	if result != "ongoing":
		return
	for lane in range(LANE_COUNT):
		var attacker = enemy_lanes[lane]
		if attacker == null or not bool(attacker.get("ready", false)):
			continue
		var defender_lane := lane
		if player_lanes[defender_lane] == null:
			defender_lane = _guard_interceptor(player_lanes, lane)
		if defender_lane < 0:
			var damage := maxi(0, int(attacker.get("attack", 0)))
			player_integrity -= damage
			if damage > 0 and enemy_domain == CatalogScript.DOMAIN_FOREST:
				cpu_gain_essence(1)
			_check_result()
			if result != "ongoing":
				return
			continue
		if defender_lane != lane:
			var guard: Dictionary = player_lanes[defender_lane]
			guard["guard_used"] = true
		_resolve_cpu_creature_combat(lane, defender_lane)
		if result != "ongoing":
			return

func _resolve_cpu_creature_combat(enemy_lane: int, player_lane: int) -> void:
	var attacker: Dictionary = enemy_lanes[enemy_lane]
	var defender: Dictionary = player_lanes[player_lane]
	if attacker.is_empty() or defender.is_empty():
		return
	var attacker_damage := maxi(0, int(attacker.get("attack", 0)))
	var defender_damage := maxi(0, int(defender.get("attack", 0)))
	var ambush := _unit_has_keyword(attacker, "EMBOSCADA") and not bool(attacker.get("has_fought", false))
	attacker["has_fought"] = true
	if ambush:
		_deal_damage_to_unit(true, player_lane, attacker_damage)
		if player_lanes[player_lane] != null:
			_deal_damage_to_unit(false, enemy_lane, defender_damage)
	else:
		_deal_damage_to_unit(true, player_lane, attacker_damage)
		_deal_damage_to_unit(false, enemy_lane, defender_damage)

func _kill_unit(player_side: bool, lane: int) -> void:
	var lanes: Array = player_lanes if player_side else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return
	var unit: Dictionary = lanes[lane]
	_trigger_last_breath(unit, player_side, lane)
	var card_id := str(unit.get("id", ""))
	if player_side:
		discard_pile.append(card_id)
		if player_domain == CatalogScript.DOMAIN_CRYPT:
			gain_essence(1)
	else:
		enemy_discard.append(card_id)
		if enemy_domain == CatalogScript.DOMAIN_CRYPT:
			cpu_gain_essence(1)
	lanes[lane] = null
	event_queue.push(GameEventScriptCpu.create("UNIT_DIED", card_id, [], {
		"side": "player" if player_side else "enemy",
		"lane": lane
	}))

func _trigger_last_breath(unit: Dictionary, player_side: bool, lane: int) -> void:
	var card_id := str(unit.get("id", ""))
	var card := CatalogScript.find_by_id(card_id)
	if card.is_empty():
		return
	var effect_id := str(card.get("effect_id", ""))
	if effect_id.is_empty():
		return
	AbilityResolverScriptCpu.resolve(effect_id, AbilityDefinitionScriptCpu.ON_DEATH, {
		"source_card_id": card_id,
		"source_side": "player" if player_side else "enemy",
		"source_lane": lane,
		"target_lane": lane
	}, self)

func _expire_cpu_temporary_bonuses() -> void:
	for lane in range(LANE_COUNT):
		if enemy_lanes[lane] == null:
			continue
		var unit: Dictionary = enemy_lanes[lane]
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
				_kill_unit(false, lane)

func _resolve_cpu_overload() -> void:
	if enemy_domain == CatalogScript.DOMAIN_FORGE and cpu_essence_current >= 6 and result == "ongoing":
		enemy_integrity -= 1
		cpu_essence_current = 3
		_check_result()

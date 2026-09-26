class_name CanonicalCpuBattle
extends CanonicalBattleState

const CatalogScript = preload("res://scripts/domain/canonical_card_catalog.gd")

var cpu_hand: Array[String] = []
var cpu_draw_pile: Array[String] = []
var cpu_energy_capacity := 1
var cpu_energy_current := 1
var cpu_failed_draws := 0

func setup_cpu(domain: String, player_deck: Array[String], enemy_domain_value: String = "", enemy_deck: Array[String] = []) -> void:
	setup(domain, player_deck)
	enemy_domain = domain if enemy_domain_value.is_empty() else enemy_domain_value
	cpu_hand.clear()
	cpu_draw_pile.clear()
	cpu_energy_capacity = 1
	cpu_energy_current = 1
	cpu_failed_draws = 0
	var source_deck: Array[String] = enemy_deck
	if source_deck.is_empty():
		source_deck = CatalogScript.starter_deck(enemy_domain)
	for card_id in source_deck:
		cpu_draw_pile.append(card_id)
	for i in range(STARTING_HAND):
		_cpu_draw_card()

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
	_cpu_draw_card()
	_cpu_play_creatures()
	resolve_cpu_attacks()
	for lane in range(LANE_COUNT):
		if enemy_lanes[lane] != null:
			var unit: Dictionary = enemy_lanes[lane]
			unit["ready"] = true

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
			player_integrity -= maxi(0, int(attacker.get("attack", 0)))
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

func _cpu_draw_card() -> bool:
	if cpu_hand.size() >= MAX_HAND:
		return false
	if cpu_draw_pile.is_empty():
		cpu_failed_draws += 1
		enemy_integrity -= cpu_failed_draws
		_check_result()
		return false
	cpu_hand.append(cpu_draw_pile.pop_front())
	return true

func _cpu_play_creatures() -> void:
	var free_lane := _first_free_lane(enemy_lanes)
	while free_lane >= 0 and cpu_energy_current > 0:
		var chosen := _best_affordable_creature()
		if chosen < 0:
			return
		var card_id := cpu_hand[chosen]
		var card := CatalogScript.find_by_id(card_id)
		var cost := int(card.get("cost", 0))
		var unit := create_unit(card_id, false)
		if unit.is_empty():
			cpu_hand.remove_at(chosen)
			continue
		enemy_lanes[free_lane] = unit
		cpu_energy_current -= cost
		cpu_hand.remove_at(chosen)
		free_lane = _first_free_lane(enemy_lanes)

func _best_affordable_creature() -> int:
	var best_index := -1
	var best_cost := -1
	for i in range(cpu_hand.size()):
		var card := CatalogScript.find_by_id(cpu_hand[i])
		if str(card.get("type", "")) != CatalogScript.TYPE_CREATURE:
			continue
		var cost := int(card.get("cost", 0))
		if cost <= cpu_energy_current and cost > best_cost:
			best_cost = cost
			best_index = i
	return best_index

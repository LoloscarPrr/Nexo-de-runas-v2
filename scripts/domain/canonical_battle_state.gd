class_name CanonicalBattleState
extends RefCounted

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

const LANE_COUNT := 4
const STARTING_INTEGRITY := 20
const STARTING_HAND := 4
const MAX_HAND := 8
const STANDARD_ENERGY_CAP := 6
const ABSOLUTE_ENERGY_CAP := 12
const MAX_SEALS := 3
const MAX_RELICS := 2

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
var player_lanes: Array = [null, null, null, null]
var enemy_lanes: Array = [null, null, null, null]
var active_seals: Array[String] = []
var active_relics: Array[String] = []

var failed_draws := 0
var impulse_available := false
var last_revealed: Array[String] = []
var last_message := ""

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
	player_lanes = [null, null, null, null]
	enemy_lanes = [null, null, null, null]
	active_seals.clear()
	active_relics.clear()
	failed_draws = 0
	impulse_available = second_player
	last_revealed.clear()
	last_message = ""
	for card_id in deck_ids:
		if not Catalog.find_by_id(card_id).is_empty():
			draw_pile.append(card_id)
	for i in range(STARTING_HAND):
		draw_card()

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
	_reset_guard_usage(player_lanes)
	_reset_guard_usage(enemy_lanes)
	draw_card()

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
	hand.append(draw_pile.pop_front())
	return true

func use_impulse() -> bool:
	if not impulse_available or result != "ongoing":
		return false
	impulse_available = false
	grant_temporary_energy(1)
	return true

func grant_temporary_energy(amount: int) -> int:
	var before := energy_current
	energy_current = mini(ABSOLUTE_ENERGY_CAP, energy_current + maxi(0, amount))
	return energy_current - before

func can_pay_energy(amount: int) -> bool:
	return amount >= 0 and energy_current >= amount

func spend_energy(amount: int) -> bool:
	if not can_pay_energy(amount):
		return false
	energy_current -= amount
	return true

func essence_name() -> String:
	return Catalog.essence_name(player_domain)

func essence_max() -> int:
	return Catalog.essence_max(player_domain)

func gain_essence(amount: int) -> int:
	var before := essence_current
	essence_current = mini(essence_max(), essence_current + maxi(0, amount))
	return essence_current - before

func spend_essence(amount: int) -> bool:
	if amount < 0 or essence_current < amount:
		return false
	essence_current -= amount
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
		"ready": ready or Array(card.get("keywords", [])).has("CARGA"),
		"has_fought": false,
		"guard_used": false,
		"shield": shield,
		"temp_attack": 0,
		"temp_health": 0
	}

func place_enemy_unit(card_id: String, lane: int, ready: bool = true) -> bool:
	if lane < 0 or lane >= LANE_COUNT or enemy_lanes[lane] != null:
		return false
	var unit := create_unit(card_id, ready)
	if unit.is_empty():
		return false
	enemy_lanes[lane] = unit
	return true

func play_card(hand_index: int, lane: int = -1, target_lane: int = -1, replace_index: int = -1) -> bool:
	if result != "ongoing" or hand_index < 0 or hand_index >= hand.size():
		return false
	var card_id := hand[hand_index]
	var card := Catalog.find_by_id(card_id)
	if card.is_empty():
		return false
	var cost := int(card.get("cost", 0))
	if not can_pay_energy(cost):
		last_message = "Energía Rúnica insuficiente."
		return false
	var card_type := str(card.get("type", ""))
	var success := false
	match card_type:
		Catalog.TYPE_CREATURE:
			success = _play_creature(card, lane)
		Catalog.TYPE_RITE:
			success = _play_rite(card, target_lane)
		Catalog.TYPE_RELIC:
			success = _play_persistent(card_id, active_relics, MAX_RELICS, replace_index)
		Catalog.TYPE_SEAL:
			success = _play_persistent(card_id, active_seals, MAX_SEALS, replace_index)
		_:
			success = false
	if not success:
		return false
	spend_energy(cost)
	hand.remove_at(hand_index)
	if card_type == Catalog.TYPE_RITE:
		discard_pile.append(card_id)
		if player_domain == Catalog.DOMAIN_TOWER:
			gain_essence(1)
	elif card_type == Catalog.TYPE_SEAL and player_domain == Catalog.DOMAIN_TOWER:
		gain_essence(1)
	return true

func _play_creature(card: Dictionary, lane: int) -> bool:
	if lane < 0 or lane >= LANE_COUNT or player_lanes[lane] != null:
		last_message = "El carril no está disponible."
		return false
	var unit := create_unit(str(card.get("id", "")), false)
	if unit.is_empty():
		return false
	player_lanes[lane] = unit
	_on_creature_entered(card, lane)
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

func _play_rite(card: Dictionary, target_lane: int) -> bool:
	var card_id := str(card.get("id", ""))
	match card_id:
		"llamado_de_la_manada":
			var free_lane := _first_free_lane(player_lanes)
			if free_lane < 0:
				return false
			player_lanes[free_lane] = _make_token("cria_del_bosque", "CRÍA DEL BOSQUE", 1, 1, ["BESTIA"])
			if player_domain == Catalog.DOMAIN_FOREST:
				gain_essence(1)
			return true
		"crecimiento_violento":
			return _temporary_buff(target_lane, 2, 2)
		"ofrenda_de_ceniza":
			if not _valid_occupied_lane(player_lanes, target_lane):
				return false
			_kill_unit(true, target_lane)
			draw_card()
			draw_card()
			return true
		"exhumacion":
			for i in range(discard_pile.size() - 1, -1, -1):
				var candidate := Catalog.find_by_id(discard_pile[i])
				if str(candidate.get("type", "")) == Catalog.TYPE_CREATURE and int(candidate.get("cost", 99)) <= 3:
					hand.append(discard_pile[i])
					discard_pile.remove_at(i)
					return true
			return false
		"proyectil_runico":
			if not _valid_occupied_lane(enemy_lanes, target_lane):
				return false
			_deal_damage_to_unit(false, target_lane, 1)
			return true
		"vision_prohibida":
			last_revealed.clear()
			var count := mini(3, draw_pile.size())
			for i in range(count):
				last_revealed.append(draw_pile[i])
			if count > 0 and hand.size() < MAX_HAND:
				hand.append(draw_pile.pop_front())
			return true
		"chispa_mecanica":
			if not _valid_occupied_lane(enemy_lanes, target_lane):
				return false
			_deal_damage_to_unit(false, target_lane, 1)
			gain_essence(1)
			return true
		"sobrecarga":
			if not _valid_occupied_lane(player_lanes, target_lane):
				return false
			var unit: Dictionary = player_lanes[target_lane]
			if not Array(unit.get("tags", [])).has("CONSTRUCTO"):
				return false
			unit["attack"] = int(unit.get("attack", 0)) + 3
			unit["temp_attack"] = int(unit.get("temp_attack", 0)) + 3
			gain_essence(2)
			return true
	return false

func _temporary_buff(lane: int, attack_bonus: int, health_bonus: int) -> bool:
	if not _valid_occupied_lane(player_lanes, lane):
		return false
	var unit: Dictionary = player_lanes[lane]
	unit["attack"] = int(unit.get("attack", 0)) + attack_bonus
	unit["hp"] = int(unit.get("hp", 0)) + health_bonus
	unit["max_hp"] = int(unit.get("max_hp", 0)) + health_bonus
	unit["temp_attack"] = int(unit.get("temp_attack", 0)) + attack_bonus
	unit["temp_health"] = int(unit.get("temp_health", 0)) + health_bonus
	return true

func _on_creature_entered(card: Dictionary, lane: int) -> void:
	var card_id := str(card.get("id", ""))
	match card_id:
		"ardilla_vigilante":
			if _has_other_tag(lane, "BESTIA"):
				gain_essence(1)
		"sepulturero":
			gain_essence(1)
		"familiar_arcano":
			last_revealed.clear()
			if not draw_pile.is_empty():
				last_revealed.append(draw_pile[0])
		"automata_obrero":
			gain_essence(1)

func resolve_player_attacks() -> void:
	if result != "ongoing":
		return
	for lane in range(LANE_COUNT):
		var attacker = player_lanes[lane]
		if attacker == null or not bool(attacker.get("ready", false)):
			continue
		var defender_lane := lane
		if enemy_lanes[defender_lane] == null:
			defender_lane = _guard_interceptor(enemy_lanes, lane)
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
			return

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
		_deal_damage_to_unit(false, enemy_lane, attacker_damage)
		if enemy_lanes[enemy_lane] != null:
			_deal_damage_to_unit(true, player_lane, defender_damage)
	else:
		_deal_damage_to_unit(false, enemy_lane, attacker_damage)
		_deal_damage_to_unit(true, player_lane, defender_damage)

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

func _deal_damage_to_unit(player_side: bool, lane: int, amount: int) -> void:
	var lanes: Array = player_lanes if player_side else enemy_lanes
	if not _valid_occupied_lane(lanes, lane):
		return
	var unit: Dictionary = lanes[lane]
	var shield := int(unit.get("shield", 0))
	var damage := maxi(0, amount)
	if shield > 0 and damage > 0:
		damage = maxi(0, damage - shield)
		unit["shield"] = 0
	unit["hp"] = int(unit.get("hp", 0)) - damage
	if int(unit.get("hp", 0)) <= 0:
		_kill_unit(player_side, lane)

func _kill_unit(player_side: bool, lane: int) -> void:
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

func _trigger_last_breath(unit: Dictionary, player_side: bool, lane: int) -> void:
	if not player_side:
		return
	var card_id := str(unit.get("id", ""))
	match card_id:
		"esqueleto_roto":
			gain_essence(1)
		"perro_funebre":
			if _valid_occupied_lane(enemy_lanes, lane):
				_deal_damage_to_unit(false, lane, 1)
		"lamentadora":
			draw_card()

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

func _has_other_tag(excluded_lane: int, tag: String) -> bool:
	for lane in range(LANE_COUNT):
		if lane == excluded_lane or player_lanes[lane] == null:
			continue
		if Array(player_lanes[lane].get("tags", [])).has(tag):
			return true
	return false

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
		"temp_health": 0
	}

func _reset_guard_usage(lanes: Array) -> void:
	for unit in lanes:
		if unit != null:
			unit["guard_used"] = false

func _check_result() -> void:
	if enemy_integrity <= 0:
		result = "victory"
	elif player_integrity <= 0:
		result = "defeat"

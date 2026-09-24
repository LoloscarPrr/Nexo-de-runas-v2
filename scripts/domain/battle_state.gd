class_name BattleState
extends RefCounted

const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")

var hand: Array[String] = []
var draw_pile: Array[String] = []
var player_lanes := [null, null, null, null]
var enemy_lanes := [null, null, null, null]
var enemy_queue: Array[String] = []
var encounter_id := "battle_1"
var run_buffs: Dictionary = {}
var run_sigils: Dictionary = {}

const ENCOUNTERS := {
	"battle_1": ["coyote", "rana_toro", "lobo", "puercoespin", "cascabel", "cuervo"],
	"battle_2": ["puercoespin", "cascabel", "sabueso", "cuervo", "alce", "oso_grizzly"],
	"boss_1": ["mula_de_carga", "coyote", "trampa_saltarina", "sabueso", "cascabel", "oso_grizzly", "alce_macho"],
	"battle_3": ["urraca", "mofeta", "alce", "cucaracha", "gran_tiburon_blanco", "oso_grizzly"],
	"boss_2": ["trampa_saltarina", "puercoespin", "cascabel", "sabueso", "buitre_pavo", "urayuli"]
}
var enemy_queue_index := 0
var bones := 0
# Recursos multi-familia. Energía se recarga al máximo al comenzar cada turno
# del jugador y su capacidad aumenta gradualmente hasta 6.
var energy_current := 1
var energy_max := 1
const ENERGY_CAP := 6

# Mox no se consume: su presencia depende de cristales/unidades activas en mesa.
var mox_green_active := false
var mox_orange_active := false
var mox_blue_active := false

var squirrel_pile_count := 10
var draw_pending := false
var scale := 0
var turn := 1
var result := "ongoing"
var last_message := "Elige una carta. Las cartas de Sangre exigen sacrificios."
var starvation_level := 0
var cpu_surrender_pending := false
var cpu_surrender_declined := false
var items_generated := 0
var ouroboros_bonus := 0

const AMORPHOUS_POOL := [
	"AIRBORNE", "MIGHTY_LEAP", "SHARP_QUILLS", "STINKY",
	"BURROWER", "SPRINTER", "UNKILLABLE", "FLEDGLING"
]

func setup(deck_ids: Array[String], buffs: Dictionary = {}, battle_id: String = "battle_1", sigil_mods: Dictionary = {}) -> void:
	encounter_id = battle_id
	run_buffs = buffs.duplicate(true)
	run_sigils = sigil_mods.duplicate(true)
	enemy_queue = []
	var encounter_cards = ENCOUNTERS.get(battle_id, ENCOUNTERS["battle_1"])
	for enemy_id in encounter_cards:
		enemy_queue.append(str(enemy_id))
	hand = []
	draw_pile = []
	for card_id in deck_ids:
		var card := CardCatalogScript.find_by_id(card_id)
		if not card.is_empty() and bool(card.get("playable", true)):
			draw_pile.append(card_id)
	player_lanes = [null, null, null, null]
	enemy_lanes = [null, null, null, null]
	enemy_queue_index = 0
	bones = 0
	energy_max = 1
	energy_current = 1
	mox_green_active = false
	mox_orange_active = false
	mox_blue_active = false
	squirrel_pile_count = 10
	draw_pending = false
	scale = 0
	turn = 1
	result = "ongoing"
	starvation_level = 0
	cpu_surrender_pending = false
	cpu_surrender_declined = false
	items_generated = 0
	last_message = "Elige una carta. Las cartas de Sangre exigen sacrificios."
	_draw_regular_if_possible()
	_draw_regular_if_possible()
	_draw_regular_if_possible()
	hand.append("ardilla")
	_spawn_enemy()

func card_for_id(card_id: String) -> Dictionary:
	var card := CardCatalogScript.find_by_id(card_id)
	if card.is_empty():
		return card
	if run_buffs.has(card_id) and run_buffs[card_id] is Dictionary:
		var buff: Dictionary = run_buffs[card_id]
		card["atk"] = int(card.get("atk", 0)) + int(buff.get("atk", 0))
		card["hp"] = int(card.get("hp", 1)) + int(buff.get("hp", 0))
	if run_sigils.has(card_id):
		var merged: Array[String] = []
		for sigil in Array(card.get("sigils", [])):
			var code := str(sigil)
			if not merged.has(code): merged.append(code)
		for sigil in Array(run_sigils[card_id]):
			var code := str(sigil)
			if not merged.has(code): merged.append(code)
		card["sigils"] = merged
	return card

func can_pay_energy(cost: int) -> bool:
	return cost <= 0 or energy_current >= cost

func spend_energy(cost: int) -> bool:
	if cost <= 0:
		return true
	if not can_pay_energy(cost):
		return false
	energy_current -= cost
	return true

func recharge_energy_for_new_turn() -> void:
	energy_max = mini(ENERGY_CAP, energy_max + 1)
	energy_current = energy_max

func refresh_mox_presence() -> Dictionary:
	mox_green_active = false
	mox_orange_active = false
	mox_blue_active = false
	for unit in player_lanes:
		if unit == null:
			continue
		var provided: Array[String] = _mox_provided_by_unit(unit)
		for color in provided:
			match color:
				"green":
					mox_green_active = true
				"orange":
					mox_orange_active = true
				"blue":
					mox_blue_active = true
	return {
		"green": mox_green_active,
		"orange": mox_orange_active,
		"blue": mox_blue_active
	}

func active_mox() -> Dictionary:
	return refresh_mox_presence()

func has_required_mox(requirements: Array) -> bool:
	if requirements.is_empty():
		return true
	var state := refresh_mox_presence()
	for raw_color in requirements:
		var color := str(raw_color).to_lower()
		if color not in ["green", "orange", "blue"]:
			return false
		if not bool(state.get(color, false)):
			return false
	return true

func _card_mox_requirements(card: Dictionary) -> Array:
	var result: Array = []
	var raw = card.get("mox_requirements", [])
	if raw is String:
		if not str(raw).is_empty():
			result.append(str(raw).to_lower())
	elif raw is Array:
		for item in raw:
			var color := str(item).to_lower()
			if not color.is_empty() and not result.has(color):
				result.append(color)
	return result

func _mox_provided_by_unit(unit) -> Array[String]:
	var result: Array[String] = []
	if unit == null:
		return result
	var raw = unit.get("mox_provides", [])
	if raw is String:
		var direct := str(raw).to_lower()
		if not direct.is_empty():
			result.append(direct)
	elif raw is Array:
		for item in raw:
			var direct := str(item).to_lower()
			if not direct.is_empty() and not result.has(direct):
				result.append(direct)
	var card := card_for_id(str(unit.get("id", "")))
	var card_raw = card.get("mox_provides", [])
	if card_raw is String:
		var from_card := str(card_raw).to_lower()
		if not from_card.is_empty() and not result.has(from_card):
			result.append(from_card)
	elif card_raw is Array:
		for item in card_raw:
			var from_card := str(item).to_lower()
			if not from_card.is_empty() and not result.has(from_card):
				result.append(from_card)
	return result

func needs_draw() -> bool:
	return draw_pending and result == "ongoing"

func draw_from_deck() -> bool:
	if cpu_surrender_pending:
		last_message = "Primero responde a la rendición de la CPU."
		return false
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
	if cpu_surrender_pending:
		last_message = "Primero responde a la rendición de la CPU."
		return false
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

func blood_value_for_sacrifices(sacrifice_lanes: Array[int]) -> int:
	var total := 0
	var seen: Array[int] = []
	for lane in sacrifice_lanes:
		if lane < 0 or lane >= player_lanes.size() or seen.has(lane):
			continue
		seen.append(lane)
		var unit = player_lanes[lane]
		if unit == null:
			continue
		total += 3 if _has_sigil(unit, "WORTHY_SACRIFICE") else 1
	return total

func can_play(hand_index: int, lane_index: int, sacrifice_lanes: Array[int]) -> String:
	if cpu_surrender_pending:
		return "Primero responde a la rendición de la CPU."
	if result != "ongoing":
		return "La batalla ya terminó."
	if draw_pending:
		return "Primero debes robar una carta."
	if hand_index < 0 or hand_index >= hand.size():
		return "Selecciona una carta de tu mano."
	if lane_index < 0 or lane_index >= player_lanes.size():
		return "Casilla inválida."
	var card := CardCatalogScript.find_by_id(hand[hand_index])
	if card.is_empty() or not bool(card.get("playable", true)):
		return "Esa carta no puede jugarse directamente."
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
		if blood_value_for_sacrifices(unique) < cost:
			return "Falta Sangre para pagar el coste."
		if player_lanes[lane_index] != null:
			if not unique.has(lane_index):
				return "Esa casilla está ocupada."
			if _survives_sacrifice(player_lanes[lane_index]):
				return "La criatura sacrificada seguirá ocupando esa casilla."
		return ""
	if player_lanes[lane_index] != null:
		return "Esa casilla está ocupada."
	if resource == "bones" and bones < cost:
		return "Huesos insuficientes."
	if resource == "energy" and not can_pay_energy(cost):
		return "Energía insuficiente."
	var mox_requirements: Array = _card_mox_requirements(card)
	if resource == "mox" and mox_requirements.is_empty():
		return "La carta Mox no define un cristal requerido."
	if not has_required_mox(mox_requirements):
		return "Falta un cristal Mox requerido en la mesa."
	return ""

func play_card(hand_index: int, lane_index: int, sacrifice_lanes: Array[int]) -> bool:
	var error_message := can_play(hand_index, lane_index, sacrifice_lanes)
	if not error_message.is_empty():
		last_message = error_message
		return false
	var card_id := hand[hand_index]
	var card := CardCatalogScript.find_by_id(card_id)
	var resource := str(card.get("resource", "none"))
	if resource == "blood":
		var unique: Array[int] = []
		for lane in sacrifice_lanes:
			if not unique.has(lane):
				unique.append(lane)
		for lane in unique:
			_sacrifice_player_unit(lane)
	elif resource == "bones":
		bones -= int(card.get("cost_value", 0))
	elif resource == "energy":
		if not spend_energy(int(card.get("cost_value", 0))):
			last_message = "Energía insuficiente."
			return false
	if player_lanes[lane_index] != null:
		last_message = "La casilla sigue ocupada tras el sacrificio."
		return false
	hand.remove_at(hand_index)
	player_lanes[lane_index] = _new_unit(card_id, true)
	_on_card_played(true, lane_index)
	_trigger_guardian(false, lane_index)
	refresh_mox_presence()
	last_message = "%s entra en la casilla %d." % [str(card.get("name", card_id)), lane_index + 1]
	return true

func end_turn() -> String:
	if cpu_surrender_pending:
		last_message = "Primero responde a la rendición de la CPU."
		return result
	if result != "ongoing":
		return result
	if draw_pending:
		last_message = "Debes robar antes de continuar el turno."
		return result
	_resolve_side_attacks(true)
	if _check_result() != "ongoing":
		return result
	_end_side_phase(true)
	_resolve_side_attacks(false)
	if _check_result() != "ongoing":
		return result
	_end_side_phase(false)
	turn += 1
	recharge_energy_for_new_turn()
	refresh_mox_presence()
	draw_pending = not draw_pile.is_empty() or squirrel_pile_count > 0
	var spawned_enemy := _spawn_enemy()
	if not spawned_enemy:
		_offer_cpu_surrender_if_exhausted()
	if not cpu_surrender_pending:
		last_message = "Turno %d · elige entre tu mazo y la reserva de Ardillas." % turn if draw_pending else "No quedan cartas en tu mazo principal."
	return result

func _new_unit(card_id: String, player_owned: bool = false) -> Dictionary:
	var card := CardCatalogScript.find_by_id(card_id)
	var buff: Dictionary = {}
	if player_owned and run_buffs.has(card_id) and run_buffs[card_id] is Dictionary:
		buff = run_buffs[card_id]
	var persistent_atk := int(buff.get("atk", 0))
	var persistent_hp := int(buff.get("hp", 0))
	var ouro_bonus := ouroboros_bonus if card_id == "uroboros" else 0
	var unit := {
		"id": card_id,
		"hp": int(card.get("hp", 1)) + persistent_hp + ouro_bonus,
		"age": 0,
		"move_dir": 1,
		"sacrifice_count": 0,
		"tail_used": false,
		"extra_sigils": [],
		"mox_provides": card.get("mox_provides", []),
		"attack_bonus": persistent_atk + ouro_bonus
	}
	if Array(card.get("sigils", [])).has("AMORPHOUS"):
		var pick: String = str(AMORPHOUS_POOL[(turn + hand.size() + card_id.length()) % AMORPHOUS_POOL.size()])
		unit.extra_sigils = [pick]
	return unit

func _sigils(unit) -> Array:
	if unit == null:
		return []
	var card := card_for_id(str(unit.get("id", "")))
	var result_sigils: Array = Array(card.get("sigils", [])).duplicate()
	for sigil in Array(unit.get("extra_sigils", [])):
		if not result_sigils.has(sigil):
			result_sigils.append(sigil)
	return result_sigils

func _has_sigil(unit, sigil: String) -> bool:
	return _sigils(unit).has(sigil)

func _survives_sacrifice(unit) -> bool:
	if unit == null or not _has_sigil(unit, "MANY_LIVES"):
		return false
	var id := str(unit.get("id", ""))
	var count := int(unit.get("sacrifice_count", 0))
	if id == "gato" and count >= 8:
		return true
	if id in ["nino_13", "nino_13_despierto"] and count >= 12:
		return true
	return true

func _sacrifice_player_unit(lane: int) -> void:
	var unit = player_lanes[lane]
	if unit == null:
		return
	var id := str(unit.get("id", ""))
	if _has_sigil(unit, "MANY_LIVES"):
		unit.sacrifice_count = int(unit.get("sacrifice_count", 0)) + 1
		if id == "gato" and int(unit.sacrifice_count) >= 9:
			unit.id = "gato_no_muerto"
			unit.hp = int(CardCatalogScript.find_by_id("gato_no_muerto").get("hp", 6))
			unit.extra_sigils = []
			return
		if id in ["nino_13", "nino_13_despierto"]:
			if int(unit.sacrifice_count) >= 13:
				unit.id = "nino_hambriento"
				unit.hp = 1
				unit.extra_sigils = []
			elif id == "nino_13":
				unit.id = "nino_13_despierto"
				unit.hp = 1
			else:
				unit.id = "nino_13"
				unit.hp = 1
			return
		return
	_kill_unit(true, lane, false, -1)

func _on_card_played(player_side: bool, lane: int) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	var unit = lanes[lane]
	if unit == null:
		return
	var id := str(unit.get("id", ""))
	if _has_sigil(unit, "ANT_SPAWNER") and player_side:
		hand.append("hormiga_obrera")
	if _has_sigil(unit, "RABBIT_HOLE") and player_side:
		hand.append("conejo")
	if _has_sigil(unit, "FECUNDITY") and player_side:
		hand.append(id)
	if _has_sigil(unit, "HOARDER") and player_side and not draw_pile.is_empty():
		hand.append(draw_pile.pop_front())
	if _has_sigil(unit, "TRINKET_BEARER") and player_side:
		items_generated += 1
	if _has_sigil(unit, "DAM_BUILDER"):
		_spawn_adjacent(player_side, lane, "represa")
	if _has_sigil(unit, "BELLIST"):
		_spawn_adjacent(player_side, lane, "campanilla")

func _spawn_adjacent(player_side: bool, lane: int, card_id: String) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	for target in [lane - 1, lane + 1]:
		if target >= 0 and target < lanes.size() and lanes[target] == null:
			lanes[target] = _new_unit(card_id, player_side)

func _resolve_side_attacks(player_side: bool) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	for lane in range(lanes.size()):
		var unit = lanes[lane]
		if unit == null:
			continue
		var targets := [lane]
		if _has_sigil(unit, "BIFURCATED_STRIKE"):
			targets = [lane - 1, lane + 1]
		elif _has_sigil(unit, "TRIFURCATED_STRIKE"):
			targets = [lane - 1, lane, lane + 1]
		for target in targets:
			if target >= 0 and target < 4 and unit != null:
				_resolve_strike(player_side, lane, target)

func _resolve_strike(attacker_player: bool, attacker_lane: int, target_lane: int) -> void:
	var attackers = player_lanes if attacker_player else enemy_lanes
	var defenders = enemy_lanes if attacker_player else player_lanes
	var attacker = attackers[attacker_lane]
	if attacker == null:
		return
	var defender = defenders[target_lane]
	if defender == null:
		_try_burrow(not attacker_player, target_lane)
		defender = defenders[target_lane]
	var damage := _unit_attack(attacker, attacker_lane, attacker_player)
	if defender == null:
		_tip_scale(attacker_player, damage)
		return
	if _has_sigil(defender, "REPULSIVE"):
		return
	if _has_sigil(attacker, "AIRBORNE") and not _has_sigil(defender, "MIGHTY_LEAP"):
		_tip_scale(attacker_player, damage)
		return
	if _has_sigil(defender, "WATERBORNE"):
		_tip_scale(attacker_player, damage)
		return
	if _has_sigil(defender, "LOOSE_TAIL") and not bool(defender.get("tail_used", false)):
		if _loose_tail(not attacker_player, target_lane):
			defender = defenders[target_lane]
	if defender == null:
		_tip_scale(attacker_player, damage)
		return
	var defender_card := CardCatalogScript.find_by_id(str(defender.get("id", "")))
	if _has_sigil(defender, "BEES_WITHIN") and not attacker_player:
		# El defensor pertenece al jugador cuando ataca el oponente.
		hand.append("abeja")
	if _has_sigil(attacker, "TOUCH_OF_DEATH") and damage > 0:
		defender.hp = 0
	else:
		defender.hp = int(defender.get("hp", 0)) - damage
	if _has_sigil(defender, "SHARP_QUILLS"):
		attacker.hp = int(attacker.get("hp", 0)) - 1
	if int(defender.get("hp", 0)) <= 0:
		var trap := _has_sigil(defender, "STEEL_TRAP")
		_kill_unit(not attacker_player, target_lane, true, attacker_lane)
		if trap and attackers[attacker_lane] != null:
			_kill_unit(attacker_player, attacker_lane, true, target_lane)
			if not attacker_player:
				hand.append("pelaje_de_lobo")
	if attackers[attacker_lane] != null and int(attackers[attacker_lane].get("hp", 0)) <= 0:
		_kill_unit(attacker_player, attacker_lane, true, target_lane)
	# The Daus retaliates when one of its chimes is struck.
	if str(defender_card.get("id", "")) == "campanilla":
		_daus_retaliate(not attacker_player, attacker_lane)

func _tip_scale(player_side: bool, amount: int) -> void:
	if player_side:
		scale += amount
	else:
		scale -= amount

func _unit_attack(unit, lane: int, player_side: bool) -> int:
	if unit == null:
		return 0
	if unit.has("attack_override"):
		return maxi(0, int(unit.attack_override))
	var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
	var power := int(card.get("atk", 0)) + int(unit.get("attack_bonus", 0))
	var stat := str(card.get("special_stat", "NONE"))
	if stat == "ANTS":
		power = _count_ants(player_side)
	elif stat == "BELL":
		power = lane + 1 if player_side else 4 - lane
	elif stat == "CARDS_IN_HAND":
		power = hand.size() if player_side else 1
	elif stat == "MIRROR":
		var opposing = enemy_lanes[lane] if player_side else player_lanes[lane]
		if opposing != null:
			var opposing_card := CardCatalogScript.find_by_id(str(opposing.get("id", "")))
			power = int(opposing_card.get("atk", 0)) + int(opposing.get("attack_bonus", 0))
		else:
			power = 0
	var own_lanes = player_lanes if player_side else enemy_lanes
	for adjacent in [lane - 1, lane + 1]:
		if adjacent >= 0 and adjacent < 4 and own_lanes[adjacent] != null and _has_sigil(own_lanes[adjacent], "LEADER"):
			power += 1
	var opposing = enemy_lanes[lane] if player_side else player_lanes[lane]
	if opposing != null and _has_sigil(opposing, "STINKY"):
		power -= 1
	return maxi(0, power)

func attack_for_lane(player_side: bool, lane: int) -> int:
	var lanes = player_lanes if player_side else enemy_lanes
	if lane < 0 or lane >= lanes.size() or lanes[lane] == null:
		return 0
	return _unit_attack(lanes[lane], lane, player_side)

func _count_ants(player_side: bool) -> int:
	var lanes = player_lanes if player_side else enemy_lanes
	var count := 0
	for unit in lanes:
		if unit == null:
			continue
		var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
		if bool(card.get("counts_as_ant", false)):
			count += 1
	return count

func _try_burrow(defender_player: bool, target_lane: int) -> bool:
	var lanes = player_lanes if defender_player else enemy_lanes
	if lanes[target_lane] != null:
		return false
	for i in range(lanes.size()):
		if i != target_lane and lanes[i] != null and _has_sigil(lanes[i], "BURROWER"):
			lanes[target_lane] = lanes[i]
			lanes[i] = null
			return true
	return false

func _trigger_guardian(defender_player: bool, target_lane: int) -> void:
	var lanes = player_lanes if defender_player else enemy_lanes
	if lanes[target_lane] != null:
		return
	for i in range(lanes.size()):
		if i != target_lane and lanes[i] != null and _has_sigil(lanes[i], "GUARDIAN"):
			lanes[target_lane] = lanes[i]
			lanes[i] = null
			return

func _loose_tail(defender_player: bool, lane: int) -> bool:
	var lanes = player_lanes if defender_player else enemy_lanes
	var unit = lanes[lane]
	if unit == null:
		return false
	for target in [lane + 1, lane - 1]:
		if target >= 0 and target < 4 and lanes[target] == null:
			unit.tail_used = true
			lanes[target] = unit
			var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
			var tail_id := str(card.get("tail_spawn", ""))
			if tail_id.is_empty():
				tail_id = "cola_retorcida"
			lanes[lane] = _new_unit(tail_id, defender_player)
			return true
	return false

func _kill_unit(player_side: bool, lane: int, combat_death: bool, opposing_lane: int) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	var unit = lanes[lane]
	if unit == null:
		return
	var id := str(unit.get("id", ""))
	var card := CardCatalogScript.find_by_id(id)
	lanes[lane] = null
	if player_side:
		bones += 4 if _has_sigil(unit, "BONE_KING") else 1
		if _has_sigil(unit, "UNKILLABLE"):
			if id == "uroboros":
				ouroboros_bonus += 1
			hand.append(id)
		var death_spawn := str(card.get("death_spawn", ""))
		if not death_spawn.is_empty():
			lanes[lane] = _new_unit(death_spawn, true)
		if combat_death:
			var corpse_index := hand.find("gusanos_cadavericos")
			if corpse_index >= 0 and lanes[lane] == null:
				hand.remove_at(corpse_index)
				lanes[lane] = _new_unit("gusanos_cadavericos", true)
	else:
		var death_spawn_enemy := str(card.get("death_spawn", ""))
		if not death_spawn_enemy.is_empty():
			lanes[lane] = _new_unit(death_spawn_enemy, false)

func _daus_retaliate(defender_player: bool, attacker_lane: int) -> void:
	var lanes = player_lanes if defender_player else enemy_lanes
	for i in range(lanes.size()):
		if lanes[i] != null and str(lanes[i].get("id", "")) == "los_daus":
			var damage := _unit_attack(lanes[i], i, defender_player)
			var targets = enemy_lanes if defender_player else player_lanes
			if targets[attacker_lane] != null:
				targets[attacker_lane].hp = int(targets[attacker_lane].get("hp", 0)) - damage
				if int(targets[attacker_lane].get("hp", 0)) <= 0:
					_kill_unit(not defender_player, attacker_lane, true, i)
			else:
				_tip_scale(defender_player, damage)
			return

func _end_side_phase(player_side: bool) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	# Fledgling transformations.
	for i in range(lanes.size()):
		var unit = lanes[i]
		if unit == null:
			continue
		if _has_sigil(unit, "FLEDGLING"):
			unit.age = int(unit.get("age", 0)) + 1
			var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
			var target := str(card.get("evolve_to", ""))
			if not target.is_empty() and int(unit.age) >= int(card.get("evolve_turns", 1)):
				var evolved := _new_unit(target, player_side)
				evolved.hp = int(CardCatalogScript.find_by_id(target).get("hp", evolved.hp))
				lanes[i] = evolved
	# Movement after transformations. Process in movement direction to avoid double moves.
	for i in range(lanes.size()):
		var unit = lanes[i]
		if unit == null:
			continue
		if _has_sigil(unit, "SPRINTER") or _has_sigil(unit, "HEFTY"):
			_move_unit(player_side, i)

func _move_unit(player_side: bool, lane: int) -> void:
	var lanes = player_lanes if player_side else enemy_lanes
	var unit = lanes[lane]
	if unit == null:
		return
	var dir := int(unit.get("move_dir", 1))
	var target := lane + dir
	if target < 0 or target >= 4:
		dir *= -1
		unit.move_dir = dir
		target = lane + dir
	if target < 0 or target >= 4:
		return
	if lanes[target] == null:
		lanes[target] = unit
		lanes[lane] = null
		return
	if _has_sigil(unit, "HEFTY"):
		var next := target + dir
		if next >= 0 and next < 4 and lanes[next] == null:
			lanes[next] = lanes[target]
			lanes[target] = unit
			lanes[lane] = null
			return
	unit.move_dir = -dir

func _check_result() -> String:
	if scale >= 5:
		result = "victory"
		last_message = "Victoria. Los dientes inclinan la balanza a tu favor."
	elif scale <= -5:
		result = "defeat"
		last_message = "La balanza cayó del lado de tu oponente."
	return result

func _draw_regular_if_possible() -> void:
	if not draw_pile.is_empty():
		hand.append(draw_pile.pop_front())

func _spawn_enemy() -> bool:
	if result != "ongoing":
		return false
	var lane_index := _first_empty_enemy_lane()
	if lane_index == -1:
		return false
	if enemy_queue_index < enemy_queue.size():
		var card_id := enemy_queue[enemy_queue_index]
		enemy_queue_index += 1
		_trigger_guardian(true, lane_index)
		enemy_lanes[lane_index] = _new_unit(card_id)
		_on_card_played(false, lane_index)
		return true
	return false

func _offer_cpu_surrender_if_exhausted() -> void:
	if result != "ongoing" or cpu_surrender_declined or cpu_surrender_pending:
		return
	if enemy_queue_index < enemy_queue.size():
		return
	cpu_surrender_pending = true
	last_message = "La CPU se ha quedado sin cartas y ofrece rendirse."

func accept_cpu_surrender() -> String:
	if not cpu_surrender_pending or result != "ongoing":
		return result
	cpu_surrender_pending = false
	result = "victory"
	last_message = "Aceptaste la rendición de la CPU."
	return result

func reject_cpu_surrender() -> void:
	if not cpu_surrender_pending or result != "ongoing":
		return
	cpu_surrender_pending = false
	cpu_surrender_declined = true
	last_message = "Rechazaste la rendición. La CPU no tiene más cartas que jugar."

func _spawn_starvation_if_needed() -> void:
	# Hambruna no depende de que el oponente se quede sin su cola normal:
	# aparece cuando el jugador empieza un turno sin cartas en el mazo principal.
	if result != "ongoing" or not draw_pile.is_empty():
		return
	starvation_level += 1
	var starvation_id := "hambruna_voladora" if starvation_level >= 5 else "hambruna"
	var unit := _new_unit(starvation_id)
	unit.attack_override = starvation_level
	unit.hp = starvation_level
	# Desde la quinta Hambruna obtiene Aéreo. La ilustración alternativa
	# representa visualmente ese cambio.
	if starvation_level >= 5 and not Array(unit.extra_sigils).has("AIRBORNE"):
		unit.extra_sigils.append("AIRBORNE")
	# Desde la novena, cada aparición castiga además la balanza.
	if starvation_level >= 9:
		scale -= 1
		if _check_result() != "ongoing":
			return
	var lane_index := _first_empty_enemy_lane()
	if lane_index == -1:
		lane_index = 0
	_trigger_guardian(true, lane_index)
	enemy_lanes[lane_index] = unit

func _first_empty_enemy_lane() -> int:
	for i in range(enemy_lanes.size()):
		if enemy_lanes[i] == null:
			return i
	return -1

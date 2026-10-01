class_name CanonicalBattleSession
extends RefCounted

## Application-layer facade for the canonical battle engine.
## Presentation talks to this class instead of deciding game rules itself.

const EngineScript = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const AbilityResolverScript = preload("res://scripts/domain/services/ability_resolver.gd")
const TargetSpecScript = preload("res://scripts/domain/value_objects/target_spec.gd")
const CommandScript = preload("res://scripts/application/battle/battle_command.gd")

const DOMAIN_FOREST := "forest"
const DOMAIN_CRYPT := "crypt"
const DOMAIN_TOWER := "tower"
const DOMAIN_FORGE := "forge"

const TYPE_CREATURE := "creature"
const TYPE_RITE := "rite"
const TYPE_RELIC := "relic"
const TYPE_SEAL := "seal"

var _engine: CanonicalCpuBattle

func start_vs_cpu(domain: String = DOMAIN_FOREST, player_deck: Array[String] = [], enemy_domain: String = "", enemy_deck: Array[String] = []) -> Dictionary:
	_engine = EngineScript.new()
	var deck := player_deck
	if deck.is_empty():
		deck = Catalog.starter_deck(domain)
	var opponent_domain := domain if enemy_domain.is_empty() else enemy_domain
	_engine.setup_cpu(domain, deck, opponent_domain, enemy_deck)
	return snapshot()

func is_started() -> bool:
	return _engine != null

func snapshot() -> Dictionary:
	if _engine == null:
		return {}
	return {
		"lane_count": _engine.LANE_COUNT,
		"player_domain": _engine.player_domain,
		"enemy_domain": _engine.enemy_domain,
		"player_integrity": _engine.player_integrity,
		"enemy_integrity": _engine.enemy_integrity,
		"energy_capacity": _engine.energy_capacity,
		"energy_current": _engine.energy_current,
		"essence_current": _engine.essence_current,
		"essence_name": _engine.essence_name(),
		"essence_max": _engine.essence_max(),
		"turn": _engine.turn,
		"result": _engine.result,
		"message": _engine.last_message,
		"hand": _engine.hand.duplicate(),
		"draw_count": _engine.draw_pile.size(),
		"discard": _engine.discard_pile.duplicate(),
		"player_lanes": _engine.player_lanes.duplicate(true),
		"enemy_lanes": _engine.enemy_lanes.duplicate(true),
		"active_seals": _engine.active_seals.duplicate(),
		"active_relics": _engine.active_relics.duplicate(),
		"cpu_hand_count": _engine.cpu_hand.size(),
		"cpu_draw_count": _engine.cpu_draw_pile.size()
	}

func execute(command: Object) -> Dictionary:
	if command == null:
		return _result(false, "Comando inválido.")
	match str(command.type):
		CommandScript.PLAY_CARD:
			return _execute_play_card(command)
		CommandScript.END_ROUND:
			return _execute_end_round()
		CommandScript.USE_IMPULSE:
			return _execute_use_impulse()
		_:
			return _result(false, "Comando de batalla desconocido.")

func card_definition(card_id: String) -> Dictionary:
	return Catalog.find_by_id(card_id)

func hand_card_definition(index: int) -> Dictionary:
	if _engine == null or index < 0 or index >= _engine.hand.size():
		return {}
	return card_definition(_engine.hand[index])

func inspect_unit(side: String, lane: int) -> Dictionary:
	if _engine == null or lane < 0 or lane >= _engine.LANE_COUNT:
		return {}
	var lanes: Array = _engine.player_lanes if side == "player" else _engine.enemy_lanes
	var unit = lanes[lane]
	if unit == null:
		return {}
	return {
		"unit": (unit as Dictionary).duplicate(true),
		"card": card_definition(str(unit.get("id", "")))
	}

func target_kind_for_hand_card(hand_index: int) -> String:
	var card := hand_card_definition(hand_index)
	if card.is_empty():
		return TargetSpecScript.NONE
	if str(card.get("type", "")) == TYPE_CREATURE:
		return TargetSpecScript.PLAYER_UNIT
	return AbilityResolverScript.target_kind_for_card(card)

func can_target_player_lane(hand_index: int, lane: int) -> bool:
	if _engine == null or lane < 0 or lane >= _engine.LANE_COUNT:
		return false
	var card := hand_card_definition(hand_index)
	if card.is_empty():
		return false
	if str(card.get("type", "")) == TYPE_CREATURE:
		return _engine.player_lanes[lane] == null
	return AbilityResolverScript.can_target_card_lane(_engine, card, lane, "player")

func can_target_enemy_lane(hand_index: int, lane: int) -> bool:
	if _engine == null or lane < 0 or lane >= _engine.LANE_COUNT:
		return false
	var card := hand_card_definition(hand_index)
	if card.is_empty() or str(card.get("type", "")) != TYPE_RITE:
		return false
	return AbilityResolverScript.can_target_card_lane(_engine, card, lane, "enemy")

func play_hand_card(hand_index: int, lane: int = -1) -> Dictionary:
	return execute(CommandScript.play_card(hand_index, lane))

func end_round() -> Dictionary:
	return execute(CommandScript.end_round())

func use_impulse() -> Dictionary:
	return execute(CommandScript.use_impulse())

func _execute_play_card(command: Object) -> Dictionary:
	if _engine == null:
		return _result(false, "No hay una batalla activa.")
	var hand_index := int(command.hand_index)
	var lane := int(command.lane)
	var target_lane := int(command.target_lane)
	var replace_index := int(command.replace_index)
	var card := hand_card_definition(hand_index)
	if card.is_empty():
		return _result(false, "La carta seleccionada no existe.")
	var card_type := str(card.get("type", ""))
	var ok := false
	if card_type == TYPE_CREATURE:
		ok = _engine.play_card(hand_index, lane)
	elif card_type == TYPE_RITE:
		var resolved_target := target_lane if target_lane >= 0 else lane
		var target_kind := AbilityResolverScript.target_kind_for_card(card)
		if target_kind == TargetSpecScript.NONE or target_kind == TargetSpecScript.FIRST_FREE_PLAYER_LANE:
			resolved_target = -1
		ok = _engine.play_card(hand_index, -1, resolved_target)
	elif card_type == TYPE_RELIC or card_type == TYPE_SEAL:
		ok = _engine.play_card(hand_index, -1, -1, replace_index)
	if ok:
		_engine.last_message = "%s responde al Nexo." % str(card.get("name", "La carta"))
	return _result(ok, _engine.last_message)

func _execute_end_round() -> Dictionary:
	if _engine == null:
		return _result(false, "No hay una batalla activa.")
	if _engine.result != "ongoing":
		return _result(false, "La batalla ya terminó.")
	var before_player := _engine.player_integrity
	var before_enemy := _engine.enemy_integrity
	_engine.advance_round()
	if _engine.result == "ongoing":
		var player_damage := before_player - _engine.player_integrity
		var enemy_damage := before_enemy - _engine.enemy_integrity
		if player_damage > 0:
			_engine.last_message = "El Nexo recibió %d de daño. Turno %d." % [player_damage, _engine.turn]
		elif enemy_damage > 0:
			_engine.last_message = "El rival perdió %d de Integridad. Turno %d." % [enemy_damage, _engine.turn]
		else:
			_engine.last_message = "Turno %d · la Energía Rúnica vuelve a fluir." % _engine.turn
	return _result(true, _engine.last_message)

func _execute_use_impulse() -> Dictionary:
	if _engine == null:
		return _result(false, "No hay una batalla activa.")
	var ok := _engine.use_impulse()
	if ok:
		_engine.last_message = "La Runa de Impulso libera Energía temporal."
	return _result(ok, _engine.last_message)

func set_message(message: String) -> void:
	if _engine != null:
		_engine.last_message = message

func deck_summary() -> String:
	if _engine == null:
		return "Mazo no disponible."
	return "Mazo: %d cartas. Su orden permanece oculto." % _engine.draw_pile.size()

func discard_summary() -> String:
	if _engine == null or _engine.discard_pile.is_empty():
		return "El Descarte está vacío."
	var names: Array[String] = []
	for card_id in _engine.discard_pile:
		var card := card_definition(card_id)
		names.append(str(card.get("name", card_id)))
	return "Descarte: " + ", ".join(names)

func _result(ok: bool, message: String) -> Dictionary:
	return {
		"ok": ok,
		"message": message,
		"snapshot": snapshot(),
		"events": _engine.drain_events() if _engine != null else []
	}

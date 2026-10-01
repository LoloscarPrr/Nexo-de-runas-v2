class_name EffectResolver
extends RefCounted

const EffectDefinitionScript = preload("res://scripts/domain/definitions/effect_definition.gd")

static func apply(effect, state, context: Dictionary) -> bool:
	if effect == null or state == null:
		return false
	match str(effect.effect_type):
		EffectDefinitionScript.GAIN_ESSENCE:
			state.call("gain_essence", maxi(0, int(effect.params.get("amount", 0))))
			return true
		"gain_resource":
			return _gain_resource(effect, state)
		EffectDefinitionScript.DRAW_CARD:
			return _draw_cards(effect, state)
		EffectDefinitionScript.DAMAGE_UNIT:
			return _damage_unit(effect, state, context)
		EffectDefinitionScript.MODIFY_STATS:
			return _modify_stats(effect, state, context)
		EffectDefinitionScript.KILL_UNIT:
			return _kill_unit(effect, state, context)
		EffectDefinitionScript.SUMMON_TOKEN:
			return _summon_token(effect, state, context)
		EffectDefinitionScript.REVEAL_TOP:
			return _reveal_top(effect, state)
		_:
			return false

static func _gain_resource(effect, state) -> bool:
	var resource := str(effect.params.get("resource", "essence"))
	var amount := maxi(0, int(effect.params.get("amount", 0)))
	match resource:
		"essence":
			state.call("gain_essence", amount)
			return true
		"energy":
			state.call("grant_temporary_energy", amount)
			return true
		_:
			return false

static func _draw_cards(effect, state) -> bool:
	var amount := maxi(0, int(effect.params.get("amount", 1)))
	for i in range(amount):
		state.call("draw_card")
	return true

static func _damage_unit(effect, state, context: Dictionary) -> bool:
	var side := _effect_side(effect, context)
	var lane := _effect_lane(effect, context)
	if not _occupied(state, side, lane):
		return bool(effect.params.get("optional", false))
	var amount := maxi(0, int(effect.params.get("amount", 0)))
	state.call("_deal_damage_to_unit", side == "player", lane, amount)
	return true

static func _modify_stats(effect, state, context: Dictionary) -> bool:
	var side := _effect_side(effect, context)
	var lane := _effect_lane(effect, context)
	var unit = _unit_at(state, side, lane)
	if not (unit is Dictionary):
		return false
	var attack_bonus := int(effect.params.get("attack", 0))
	var health_bonus := int(effect.params.get("health", 0))
	unit["attack"] = int(unit.get("attack", 0)) + attack_bonus
	unit["hp"] = int(unit.get("hp", 0)) + health_bonus
	unit["max_hp"] = int(unit.get("max_hp", 1)) + health_bonus
	if bool(effect.params.get("temporary", false)):
		unit["temp_attack"] = int(unit.get("temp_attack", 0)) + attack_bonus
		unit["temp_health"] = int(unit.get("temp_health", 0)) + health_bonus
	return true

static func _kill_unit(effect, state, context: Dictionary) -> bool:
	var side := _effect_side(effect, context)
	var lane := _effect_lane(effect, context)
	if not _occupied(state, side, lane):
		return false
	state.call("_kill_unit", side == "player", lane)
	return true

static func _summon_token(effect, state, context: Dictionary) -> bool:
	var lane := int(context.get("resolved_target_lane", -1))
	var lanes = state.get("player_lanes")
	if not (lanes is Array) or lane < 0 or lane >= lanes.size() or lanes[lane] != null:
		return false
	var raw_tags = effect.params.get("tags", [])
	var tags: Array = raw_tags if raw_tags is Array else []
	var token = state.call(
		"_make_token",
		str(effect.params.get("id", "token")),
		str(effect.params.get("name", "TOKEN")),
		int(effect.params.get("attack", 0)),
		maxi(1, int(effect.params.get("health", 1))),
		tags
	)
	if not (token is Dictionary):
		return false
	lanes[lane] = token
	return true

static func _reveal_top(effect, state) -> bool:
	var draw_pile = state.get("draw_pile")
	var revealed = state.get("last_revealed")
	if not (draw_pile is Array) or not (revealed is Array):
		return false
	revealed.clear()
	var amount := mini(maxi(0, int(effect.params.get("amount", 1))), draw_pile.size())
	for i in range(amount):
		revealed.append(draw_pile[i])
	var draw_amount := mini(maxi(0, int(effect.params.get("draw", 0))), amount)
	for i in range(draw_amount):
		state.call("draw_card")
	return true

static func _effect_side(effect, context: Dictionary) -> String:
	return str(effect.params.get("side", context.get("resolved_target_side", "player")))

static func _effect_lane(effect, context: Dictionary) -> int:
	if str(effect.params.get("lane_mode", "target")) == "source":
		return int(context.get("source_lane", -1))
	return int(context.get("resolved_target_lane", context.get("target_lane", -1)))

static func _unit_at(state, side: String, lane: int):
	var lanes = state.get("player_lanes") if side == "player" else state.get("enemy_lanes")
	if not (lanes is Array) or lane < 0 or lane >= lanes.size():
		return null
	return lanes[lane]

static func _occupied(state, side: String, lane: int) -> bool:
	return _unit_at(state, side, lane) != null

class_name EffectDefinition
extends RefCounted

const GAIN_RESOURCE := "gain_resource"
const DAMAGE_UNIT := "damage_unit"
const HEAL_UNIT := "heal_unit"
const DRAW_CARDS := "draw_cards"
const MODIFY_STATS_TEMP := "modify_stats_temp"
const SUMMON_TOKEN := "summon_token"
const REVEAL_TOP := "reveal_top"
const KILL_UNIT := "kill_unit"
const RETURN_CREATURE_FROM_DISCARD := "return_creature_from_discard"
const APPLY_STATUS := "apply_status"
const MOVE_UNIT := "move_unit"
const FORCED_MOVE_UNIT := "forced_move_unit"
const SWAP_UNITS := "swap_units"

static func create(effect_type: String, params: Dictionary = {}) -> Dictionary:
	return {
		"type": effect_type,
		"params": params.duplicate(true)
	}

static func gain_resource(resource: String, amount: int) -> Dictionary:
	return create(GAIN_RESOURCE, {"resource": resource, "amount": amount})

static func damage(amount: int) -> Dictionary:
	return create(DAMAGE_UNIT, {"amount": amount})

static func heal(amount: int) -> Dictionary:
	return create(HEAL_UNIT, {"amount": amount})

static func draw(amount: int) -> Dictionary:
	return create(DRAW_CARDS, {"amount": amount})

static func temp_stats(attack: int, health: int = 0) -> Dictionary:
	return create(MODIFY_STATS_TEMP, {"attack": attack, "health": health})

static func rooted(duration: String = "until_next_turn") -> Dictionary:
	return create(APPLY_STATUS, {"status":"ROOTED","duration":duration})

static func move(forced: bool = false) -> Dictionary:
	return create(FORCED_MOVE_UNIT if forced else MOVE_UNIT)

static func swap_units() -> Dictionary:
	return create(SWAP_UNITS)

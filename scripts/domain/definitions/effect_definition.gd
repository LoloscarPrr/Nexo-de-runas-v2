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
const MODIFY_STATS_PERMANENT := "modify_stats_permanent"
const MOVE_DISCARD_TO_DECK_BOTTOM := "move_discard_to_deck_bottom"
const ADD_COST_MODIFIER := "add_cost_modifier"
const ADD_AURA := "add_aura"
const HEAL_NEXUS := "heal_nexus"
const DAMAGE_NEXUS := "damage_nexus"

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

static func move(forced: bool = false, max_distance: int = -1) -> Dictionary:
	return create(FORCED_MOVE_UNIT if forced else MOVE_UNIT, {"max_distance": max_distance})

static func swap_units() -> Dictionary:
	return create(SWAP_UNITS)

static func permanent_stats(attack: int, health: int = 0) -> Dictionary:
	return create(MODIFY_STATS_PERMANENT, {"attack": attack, "health": health})

static func move_discard_to_deck_bottom(max_cost: int = 999) -> Dictionary:
	return create(MOVE_DISCARD_TO_DECK_BOTTOM, {"max_cost": max_cost})

static func cost_modifier(modifier_id: String, delta: int, floor: int = 1, duration: String = "turn", card_type: String = "", min_base_cost: int = -1) -> Dictionary:
	return create(ADD_COST_MODIFIER, {"id": modifier_id, "delta": delta, "floor": floor, "duration": duration, "card_type": card_type, "min_base_cost": min_base_cost})

static func aura(aura_id: String, attack: int = 0, health: int = 0, radius: int = 1) -> Dictionary:
	return create(ADD_AURA, {"id": aura_id, "attack": attack, "health": health, "radius": radius})

static func heal_nexus(amount: int) -> Dictionary:
	return create(HEAL_NEXUS, {"amount": amount})

static func damage_nexus(amount: int) -> Dictionary:
	return create(DAMAGE_NEXUS, {"amount": amount})

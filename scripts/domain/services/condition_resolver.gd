class_name ConditionResolver
extends RefCounted

const ConditionDefinitionScript = preload("res://scripts/domain/value_objects/condition_definition.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

static func evaluate(condition, state, context: Dictionary) -> bool:
	if condition == null or state == null:
		return false
	match str(condition.condition_type):
		ConditionDefinitionScript.ALWAYS:
			return true
		ConditionDefinitionScript.OTHER_ALLY_HAS_TAG:
			return _other_ally_has_tag(state, int(context.get("source_lane", -1)), str(condition.params.get("tag", "")))
		ConditionDefinitionScript.TARGET_HAS_TAG:
			return _target_has_tag(state, context, str(condition.params.get("tag", "")))
		ConditionDefinitionScript.DISCARD_HAS_CREATURE_MAX_COST:
			return _discard_has_creature(state, int(condition.params.get("max_cost", 999)))
		_:
			return false

static func all_pass(conditions: Array, state, context: Dictionary) -> bool:
	for condition in conditions:
		if not evaluate(condition, state, context):
			return false
	return true

static func _other_ally_has_tag(state, excluded_lane: int, tag: String) -> bool:
	if tag.is_empty():
		return false
	var lanes = state.get("player_lanes")
	if not (lanes is Array):
		return false
	for lane in range(lanes.size()):
		if lane == excluded_lane or lanes[lane] == null:
			continue
		var unit = lanes[lane]
		if unit is Dictionary and Array(unit.get("tags", [])).has(tag):
			return true
	return false

static func _target_has_tag(state, context: Dictionary, tag: String) -> bool:
	if tag.is_empty():
		return false
	var side := str(context.get("resolved_target_side", ""))
	var lane := int(context.get("resolved_target_lane", -1))
	var lanes = state.get("player_lanes") if side == "player" else state.get("enemy_lanes")
	if not (lanes is Array) or lane < 0 or lane >= lanes.size() or lanes[lane] == null:
		return false
	var unit = lanes[lane]
	return unit is Dictionary and Array(unit.get("tags", [])).has(tag)

static func _discard_has_creature(state, max_cost: int) -> bool:
	var discard = state.get("discard_pile")
	if not (discard is Array):
		return false
	for card_id in discard:
		var card := Catalog.find_by_id(str(card_id))
		if str(card.get("type", "")) == Catalog.TYPE_CREATURE and int(card.get("cost", 999)) <= max_cost:
			return true
	return false

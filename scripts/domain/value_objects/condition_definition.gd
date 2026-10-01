class_name ConditionDefinition
extends RefCounted

const ALWAYS := "always"
const OTHER_ALLY_HAS_TAG := "other_ally_has_tag"
const TARGET_HAS_TAG := "target_has_tag"
const DISCARD_HAS_CREATURE_MAX_COST := "discard_has_creature_max_cost"

var condition_type := ALWAYS
var params: Dictionary = {}

static func create(type_value: String = ALWAYS, params_value: Dictionary = {}):
	var condition := ConditionDefinition.new()
	condition.condition_type = type_value
	condition.params = params_value.duplicate(true)
	return condition

static func from_dictionary(data: Dictionary):
	var raw_params = data.get("params", {})
	return create(
		str(data.get("type", ALWAYS)),
		raw_params if raw_params is Dictionary else {}
	)

func to_dict() -> Dictionary:
	return {
		"type": condition_type,
		"params": params.duplicate(true)
	}

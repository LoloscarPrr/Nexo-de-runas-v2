class_name ConditionResolver
extends RefCounted

const ConditionScript = preload("res://scripts/domain/definitions/condition_definition.gd")

static func all_met(conditions: Array, target: Dictionary, context: Dictionary, battle) -> bool:
	for condition in conditions:
		if not is_met(condition, target, context, battle):
			return false
	return true

static func is_met(condition: Dictionary, target: Dictionary, context: Dictionary, battle) -> bool:
	var condition_type := str(condition.get("type", ConditionScript.ALWAYS))
	var params: Dictionary = condition.get("params", {})
	match condition_type:
		ConditionScript.ALWAYS:
			return true
		ConditionScript.TARGET_EXISTS:
			return bool(target.get("valid", false)) and target.get("unit", null) != null
		ConditionScript.TARGET_HAS_TAG:
			var target_unit = target.get("unit", null)
			if target_unit == null:
				return false
			return Array(target_unit.get("tags", [])).has(str(params.get("tag", "")))
		ConditionScript.OTHER_ALLY_HAS_TAG:
			var source_side := str(context.get("source_side", "player"))
			var source_lane := int(context.get("source_lane", -1))
			var lanes: Array = battle.player_lanes if source_side == "player" else battle.enemy_lanes
			var tag := str(params.get("tag", ""))
			for lane in range(lanes.size()):
				if lane == source_lane or lanes[lane] == null:
					continue
				if Array(lanes[lane].get("tags", [])).has(tag):
					return true
			return false
	return false

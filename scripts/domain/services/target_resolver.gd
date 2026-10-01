class_name TargetResolver
extends RefCounted

const TargetSpecScript = preload("res://scripts/domain/value_objects/target_spec.gd")

static func validate(state, spec, context: Dictionary) -> bool:
	if state == null or spec == null:
		return false
	match str(spec.kind):
		TargetSpecScript.NONE:
			return true
		TargetSpecScript.PLAYER_UNIT:
			return _occupied(state, "player", int(context.get("target_lane", -1)))
		TargetSpecScript.ENEMY_UNIT:
			return _occupied(state, "enemy", int(context.get("target_lane", -1)))
		TargetSpecScript.FIRST_FREE_PLAYER_LANE:
			return _first_free_lane(state, "player") >= 0
		_:
			return false

static func enrich_context(state, spec, context: Dictionary) -> Dictionary:
	var resolved := context.duplicate(true)
	if state == null or spec == null:
		return resolved
	var lane := -1
	var side := ""
	match str(spec.kind):
		TargetSpecScript.PLAYER_UNIT:
			lane = int(context.get("target_lane", -1))
			side = "player"
		TargetSpecScript.ENEMY_UNIT:
			lane = int(context.get("target_lane", -1))
			side = "enemy"
		TargetSpecScript.FIRST_FREE_PLAYER_LANE:
			lane = _first_free_lane(state, "player")
			side = "player"
	resolved["resolved_target_lane"] = lane
	resolved["resolved_target_side"] = side
	return resolved

static func target_kind_for_card(ability) -> String:
	if ability == null or ability.target_spec == null:
		return TargetSpecScript.NONE
	return str(ability.target_spec.kind)

static func _occupied(state, side: String, lane: int) -> bool:
	var lanes = _lanes_for_side(state, side)
	return lanes is Array and lane >= 0 and lane < lanes.size() and lanes[lane] != null

static func _first_free_lane(state, side: String) -> int:
	var lanes = _lanes_for_side(state, side)
	if not (lanes is Array):
		return -1
	for lane in range(lanes.size()):
		if lanes[lane] == null:
			return lane
	return -1

static func _lanes_for_side(state, side: String):
	if side == "player":
		return state.get("player_lanes")
	if side == "enemy":
		return state.get("enemy_lanes")
	return []

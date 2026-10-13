class_name TargetResolver
extends RefCounted

const TargetSpecScript = preload("res://scripts/domain/value_objects/target_spec.gd")

static func resolve(target_spec: Dictionary, context: Dictionary, battle) -> Dictionary:
	var target_type := str(target_spec.get("type", TargetSpecScript.NONE))
	var source_side := str(context.get("source_side", "player"))
	var ally_side := "enemy" if source_side == "enemy" else "player"
	var opponent_side := "player" if ally_side == "enemy" else "enemy"
	var ally_lanes: Array = battle.enemy_lanes if ally_side == "enemy" else battle.player_lanes
	var opponent_lanes: Array = battle.player_lanes if opponent_side == "player" else battle.enemy_lanes
	match target_type:
		TargetSpecScript.NONE:
			return {"valid": true, "side": "none", "lane": -1, "unit": null}
		TargetSpecScript.PLAYER_LANE:
			return _lane_target(ally_side, int(context.get("target_lane", -1)), ally_lanes)
		TargetSpecScript.ENEMY_LANE:
			return _lane_target(opponent_side, int(context.get("target_lane", -1)), opponent_lanes)
		TargetSpecScript.OPPOSING_ENEMY_LANE:
			return _lane_target(opponent_side, int(context.get("source_lane", -1)), opponent_lanes)
		TargetSpecScript.FIRST_FREE_PLAYER_LANE:
			for lane in range(battle.LANE_COUNT):
				if ally_lanes[lane] == null:
					return {"valid": true, "side": ally_side, "lane": lane, "unit": null}
			return {"valid": false, "side": ally_side, "lane": -1, "unit": null}
		TargetSpecScript.ADJACENT_ALLY_LANE:
			return _adjacent_target(ally_side, ally_lanes, int(context.get("source_lane", -1)), int(context.get("target_lane", -1)), true)
		TargetSpecScript.EMPTY_ADJACENT_ALLY_LANE:
			return _adjacent_target(ally_side, ally_lanes, int(context.get("source_lane", -1)), int(context.get("target_lane", -1)), false)
		TargetSpecScript.ENEMY_LANES:
			return _multi_lane_target(opponent_side, opponent_lanes, Array(context.get("target_lanes", [])), int(target_spec.get("min_targets", 1)), int(target_spec.get("max_targets", 2)), true)
		TargetSpecScript.TWO_ALLY_LANES:
			return _multi_lane_target(ally_side, ally_lanes, Array(context.get("target_lanes", [])), 2, 2, true)
		TargetSpecScript.SOURCE_UNIT:
			return _lane_target(ally_side, int(context.get("source_lane", -1)), ally_lanes)
		TargetSpecScript.ALL_ENEMY_UNITS:
			var occupied: Array[int] = []
			for lane in range(opponent_lanes.size()):
				if opponent_lanes[lane] != null:
					occupied.append(lane)
			if occupied.is_empty():
				return {"valid": false, "side": opponent_side, "lane": -1, "unit": null, "targets": []}
			return _multi_lane_target(opponent_side, opponent_lanes, occupied, 1, opponent_lanes.size(), true)
		TargetSpecScript.ALL_ALLY_UNITS:
			var allies: Array[int] = []
			for lane in range(ally_lanes.size()):
				if ally_lanes[lane] != null:
					allies.append(lane)
			if allies.is_empty():
				return {"valid": false, "side": ally_side, "lane": -1, "unit": null, "targets": []}
			return _multi_lane_target(ally_side, ally_lanes, allies, 1, ally_lanes.size(), true)
		TargetSpecScript.EMPTY_ADJACENT_ALLY_LANES:
			var source_lane := int(context.get("source_lane", -1))
			var empty_adjacent: Array = []
			for offset in [-1, 1]:
				var lane := source_lane + int(offset)
				if lane >= 0 and lane < ally_lanes.size() and ally_lanes[lane] == null:
					empty_adjacent.append({"valid": true, "side": ally_side, "lane": lane, "unit": null})
			return {"valid": true, "side": ally_side, "lane": -1, "unit": null, "targets": empty_adjacent}
		TargetSpecScript.EMPTY_ALLY_LANES:
			var empty_allies: Array = []
			var max_targets := int(target_spec.get("max_targets", 2))
			for lane in range(ally_lanes.size()):
				if ally_lanes[lane] == null:
					empty_allies.append({"valid": true, "side": ally_side, "lane": lane, "unit": null})
					if empty_allies.size() >= max_targets:
						break
			return {"valid": true, "side": ally_side, "lane": -1, "unit": null, "targets": empty_allies}
		TargetSpecScript.EMPTY_ALLY_LANE:
			var lane := int(context.get("target_lane", -1))
			if lane < 0 or lane >= ally_lanes.size() or ally_lanes[lane] != null:
				return {"valid": false, "side": ally_side, "lane": lane, "unit": ally_lanes[lane] if lane >= 0 and lane < ally_lanes.size() else null}
			return {"valid": true, "side": ally_side, "lane": lane, "unit": null}
		TargetSpecScript.SELECTED_EMPTY_ALLY_LANES:
			return _multi_lane_target(ally_side, ally_lanes, Array(context.get("target_lanes", [])), int(target_spec.get("min_targets", 1)), int(target_spec.get("max_targets", 2)), false)
	return {"valid": false, "side": "none", "lane": -1, "unit": null}

static func _lane_target(side: String, lane: int, lanes: Array) -> Dictionary:
	if lane < 0 or lane >= lanes.size():
		return {"valid": false, "side": side, "lane": lane, "unit": null}
	return {"valid": true, "side": side, "lane": lane, "unit": lanes[lane]}

static func _adjacent_target(side: String, lanes: Array, source_lane: int, requested_lane: int, occupied: bool) -> Dictionary:
	if source_lane < 0 or source_lane >= lanes.size():
		return {"valid": false, "side": side, "lane": -1, "unit": null}
	var candidates: Array[int] = []
	for offset in [-1, 1]:
		var lane := source_lane + int(offset)
		if lane >= 0 and lane < lanes.size():
			candidates.append(lane)
	if requested_lane >= 0:
		if not candidates.has(requested_lane):
			return {"valid": false, "side": side, "lane": requested_lane, "unit": null}
		var requested_unit = lanes[requested_lane]
		if occupied and requested_unit == null:
			return {"valid": false, "side": side, "lane": requested_lane, "unit": null}
		if not occupied and requested_unit != null:
			return {"valid": false, "side": side, "lane": requested_lane, "unit": requested_unit}
		return {"valid": true, "side": side, "lane": requested_lane, "unit": requested_unit}
	for lane in candidates:
		var unit = lanes[lane]
		if occupied and unit != null:
			return {"valid": true, "side": side, "lane": lane, "unit": unit}
		if not occupied and unit == null:
			return {"valid": true, "side": side, "lane": lane, "unit": null}
	return {"valid": false, "side": side, "lane": -1, "unit": null}

static func _multi_lane_target(side: String, lanes: Array, requested_lanes: Array, min_targets: int, max_targets: int, occupied: bool) -> Dictionary:
	var normalized: Array[int] = []
	for raw_lane in requested_lanes:
		var lane := int(raw_lane)
		if normalized.has(lane):
			return {"valid": false, "side": side, "lane": -1, "unit": null, "targets": []}
		normalized.append(lane)
	if normalized.size() < min_targets or normalized.size() > max_targets:
		return {"valid": false, "side": side, "lane": -1, "unit": null, "targets": []}
	normalized.sort()
	var targets: Array = []
	for lane in normalized:
		if lane < 0 or lane >= lanes.size():
			return {"valid": false, "side": side, "lane": -1, "unit": null, "targets": []}
		var unit = lanes[lane]
		if occupied and unit == null:
			return {"valid": false, "side": side, "lane": lane, "unit": null, "targets": []}
		if not occupied and unit != null:
			return {"valid": false, "side": side, "lane": lane, "unit": unit, "targets": []}
		targets.append({"valid": true, "side": side, "lane": lane, "unit": unit})
	return {"valid": true, "side": side, "lane": -1, "unit": null, "targets": targets}

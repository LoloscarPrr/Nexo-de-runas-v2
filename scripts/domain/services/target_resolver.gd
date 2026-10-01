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
	return {"valid": false, "side": "none", "lane": -1, "unit": null}

static func _lane_target(side: String, lane: int, lanes: Array) -> Dictionary:
	if lane < 0 or lane >= lanes.size():
		return {"valid": false, "side": side, "lane": lane, "unit": null}
	return {"valid": true, "side": side, "lane": lane, "unit": lanes[lane]}

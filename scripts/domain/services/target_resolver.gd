class_name TargetResolver
extends RefCounted

const TargetSpecScript = preload("res://scripts/domain/value_objects/target_spec.gd")

static func resolve(target_spec: Dictionary, context: Dictionary, battle) -> Dictionary:
	var target_type := str(target_spec.get("type", TargetSpecScript.NONE))
	match target_type:
		TargetSpecScript.NONE:
			return {"valid": true, "side": "none", "lane": -1, "unit": null}
		TargetSpecScript.PLAYER_LANE:
			return _lane_target("player", int(context.get("target_lane", -1)), battle.player_lanes)
		TargetSpecScript.ENEMY_LANE:
			return _lane_target("enemy", int(context.get("target_lane", -1)), battle.enemy_lanes)
		TargetSpecScript.OPPOSING_ENEMY_LANE:
			return _lane_target("enemy", int(context.get("source_lane", -1)), battle.enemy_lanes)
		TargetSpecScript.FIRST_FREE_PLAYER_LANE:
			for lane in range(battle.LANE_COUNT):
				if battle.player_lanes[lane] == null:
					return {"valid": true, "side": "player", "lane": lane, "unit": null}
			return {"valid": false, "side": "player", "lane": -1, "unit": null}
	return {"valid": false, "side": "none", "lane": -1, "unit": null}

static func _lane_target(side: String, lane: int, lanes: Array) -> Dictionary:
	if lane < 0 or lane >= lanes.size():
		return {"valid": false, "side": side, "lane": lane, "unit": null}
	return {"valid": true, "side": side, "lane": lane, "unit": lanes[lane]}

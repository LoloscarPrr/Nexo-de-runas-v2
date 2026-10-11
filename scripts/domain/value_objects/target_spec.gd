class_name TargetSpec
extends RefCounted

const NONE := "none"
const PLAYER_LANE := "player_lane"
const ENEMY_LANE := "enemy_lane"
const OPPOSING_ENEMY_LANE := "opposing_enemy_lane"
const FIRST_FREE_PLAYER_LANE := "first_free_player_lane"
const ADJACENT_ALLY_LANE := "adjacent_ally_lane"
const EMPTY_ADJACENT_ALLY_LANE := "empty_adjacent_ally_lane"
const ENEMY_LANES := "enemy_lanes"
const TWO_ALLY_LANES := "two_ally_lanes"

static func create(target_type: String, required: bool = false) -> Dictionary:
	return {"type": target_type, "required": required}

static func none() -> Dictionary:
	return create(NONE, false)

static func player_lane(required: bool = true) -> Dictionary:
	return create(PLAYER_LANE, required)

static func enemy_lane(required: bool = true) -> Dictionary:
	return create(ENEMY_LANE, required)

static func opposing_enemy_lane() -> Dictionary:
	return create(OPPOSING_ENEMY_LANE, false)

static func first_free_player_lane() -> Dictionary:
	return create(FIRST_FREE_PLAYER_LANE, false)

static func adjacent_ally_lane(required: bool = true) -> Dictionary:
	return create(ADJACENT_ALLY_LANE, required)

static func empty_adjacent_ally_lane(required: bool = true) -> Dictionary:
	return create(EMPTY_ADJACENT_ALLY_LANE, required)

static func enemy_lanes(max_targets: int = 2, min_targets: int = 1) -> Dictionary:
	var spec := create(ENEMY_LANES, true)
	spec["max_targets"] = maxi(1, max_targets)
	spec["min_targets"] = clampi(min_targets, 1, int(spec["max_targets"]))
	return spec

static func two_ally_lanes() -> Dictionary:
	return create(TWO_ALLY_LANES, true)

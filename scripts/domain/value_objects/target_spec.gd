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
const SOURCE_UNIT := "source_unit"
const ALL_ENEMY_UNITS := "all_enemy_units"
const ALL_ALLY_UNITS := "all_ally_units"
const EMPTY_ADJACENT_ALLY_LANES := "empty_adjacent_ally_lanes"
const EMPTY_ALLY_LANES := "empty_ally_lanes"
const EMPTY_ALLY_LANE := "empty_ally_lane"
const SELECTED_EMPTY_ALLY_LANES := "selected_empty_ally_lanes"
const FIRST_DAMAGED_ALLY_UNIT := "first_damaged_ally_unit"
const FIRST_ALLY_UNIT := "first_ally_unit"

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

static func source_unit() -> Dictionary:
	return create(SOURCE_UNIT, true)

static func all_enemy_units() -> Dictionary:
	return create(ALL_ENEMY_UNITS, true)

static func all_ally_units() -> Dictionary:
	return create(ALL_ALLY_UNITS, true)

static func empty_adjacent_ally_lanes() -> Dictionary:
	return create(EMPTY_ADJACENT_ALLY_LANES, false)

static func empty_ally_lanes(max_targets: int = 2) -> Dictionary:
	var spec := create(EMPTY_ALLY_LANES, false)
	spec["max_targets"] = maxi(1, max_targets)
	return spec

static func empty_ally_lane() -> Dictionary:
	return create(EMPTY_ALLY_LANE, true)

static func selected_empty_ally_lanes(max_targets: int = 2, min_targets: int = 1) -> Dictionary:
	var spec := create(SELECTED_EMPTY_ALLY_LANES, true)
	spec["max_targets"] = maxi(1, max_targets)
	spec["min_targets"] = clampi(min_targets, 1, int(spec["max_targets"]))
	return spec

static func first_damaged_ally_unit() -> Dictionary:
	return create(FIRST_DAMAGED_ALLY_UNIT, false)

static func first_ally_unit() -> Dictionary:
	return create(FIRST_ALLY_UNIT, false)

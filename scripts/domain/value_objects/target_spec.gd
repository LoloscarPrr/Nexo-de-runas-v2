class_name TargetSpec
extends RefCounted

const NONE := "none"
const PLAYER_LANE := "player_lane"
const ENEMY_LANE := "enemy_lane"
const OPPOSING_ENEMY_LANE := "opposing_enemy_lane"
const FIRST_FREE_PLAYER_LANE := "first_free_player_lane"

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

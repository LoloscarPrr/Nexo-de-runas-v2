class_name BoardState
extends RefCounted

const LaneStateScript = preload("res://scripts/domain/entities/lane_state.gd")

const DEFAULT_LANE_COUNT := 5
const SIDE_PLAYER := "player"
const SIDE_ENEMY := "enemy"

var lane_count := DEFAULT_LANE_COUNT
var player_lanes: Array = []
var enemy_lanes: Array = []

func _init(initial_lane_count: int = DEFAULT_LANE_COUNT) -> void:
	setup(initial_lane_count)

func setup(new_lane_count: int = DEFAULT_LANE_COUNT) -> void:
	lane_count = maxi(1, new_lane_count)
	player_lanes = _make_lane_states(SIDE_PLAYER, lane_count)
	enemy_lanes = _make_lane_states(SIDE_ENEMY, lane_count)

static func make_empty_slots(count: int = DEFAULT_LANE_COUNT) -> Array:
	var slots: Array = []
	for _i in range(maxi(1, count)):
		slots.append(null)
	return slots

func valid_lane(index: int) -> bool:
	return index >= 0 and index < lane_count

func lane(side: String, index: int):
	if not valid_lane(index):
		return null
	if side == SIDE_PLAYER:
		return player_lanes[index]
	if side == SIDE_ENEMY:
		return enemy_lanes[index]
	return null

func occupy(side: String, index: int, instance_id: String) -> bool:
	var target = lane(side, index)
	return target != null and target.occupy(instance_id)

func clear_lane(side: String, index: int) -> String:
	var target = lane(side, index)
	if target == null:
		return ""
	return target.clear()

func snapshot() -> Dictionary:
	return {
		"lane_count": lane_count,
		"player_lanes": _serialize_lanes(player_lanes),
		"enemy_lanes": _serialize_lanes(enemy_lanes)
	}

func _make_lane_states(owner_id: String, count: int) -> Array:
	var lanes: Array = []
	for i in range(count):
		lanes.append(LaneStateScript.new(i, owner_id))
	return lanes

func _serialize_lanes(lanes: Array) -> Array:
	var result: Array = []
	for lane_state in lanes:
		result.append(lane_state.to_dict())
	return result

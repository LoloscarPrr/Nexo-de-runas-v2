class_name BattleCommand
extends RefCounted

const PLAY_CARD := "play_card"
const END_ROUND := "end_round"
const USE_IMPULSE := "use_impulse"
const DISCARD_CARD := "discard_card"

var type := ""
var hand_index := -1
var lane := -1
var target_lane := -1
var replace_index := -1
var target_lanes: Array[int] = []
var destination_lane := -1
var target_side := ""

static func play_card(hand_index_value: int, lane_value: int = -1, target_lane_value: int = -1, replace_index_value: int = -1, target_lanes_value: Array = [], destination_lane_value: int = -1, target_side_value: String = ""):
	var command := BattleCommand.new()
	command.type = PLAY_CARD
	command.hand_index = hand_index_value
	command.lane = lane_value
	command.target_lane = target_lane_value
	command.replace_index = replace_index_value
	for raw_lane in target_lanes_value:
		command.target_lanes.append(int(raw_lane))
	command.destination_lane = destination_lane_value
	command.target_side = target_side_value
	return command

static func end_round(target_lane_value: int = -1):
	var command := BattleCommand.new()
	command.type = END_ROUND
	command.target_lane = target_lane_value
	return command

static func use_impulse():
	var command := BattleCommand.new()
	command.type = USE_IMPULSE
	return command

static func discard_card(hand_index_value: int):
	var command := BattleCommand.new()
	command.type = DISCARD_CARD
	command.hand_index = hand_index_value
	return command

func to_dict() -> Dictionary:
	return {
		"type": type,
		"hand_index": hand_index,
		"lane": lane,
		"target_lane": target_lane,
		"replace_index": replace_index,
		"target_lanes": target_lanes.duplicate(),
		"destination_lane": destination_lane,
		"target_side": target_side
	}

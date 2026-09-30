class_name BattleCommand
extends RefCounted

const PLAY_CARD := "play_card"
const END_ROUND := "end_round"
const USE_IMPULSE := "use_impulse"

var type := ""
var hand_index := -1
var lane := -1
var target_lane := -1
var replace_index := -1

static func play_card(hand_index_value: int, lane_value: int = -1, target_lane_value: int = -1, replace_index_value: int = -1):
	var command := BattleCommand.new()
	command.type = PLAY_CARD
	command.hand_index = hand_index_value
	command.lane = lane_value
	command.target_lane = target_lane_value
	command.replace_index = replace_index_value
	return command

static func end_round():
	var command := BattleCommand.new()
	command.type = END_ROUND
	return command

static func use_impulse():
	var command := BattleCommand.new()
	command.type = USE_IMPULSE
	return command

func to_dict() -> Dictionary:
	return {
		"type": type,
		"hand_index": hand_index,
		"lane": lane,
		"target_lane": target_lane,
		"replace_index": replace_index
	}

class_name LaneState
extends RefCounted

var index := -1
var owner_id := ""
var occupant_instance_id := ""

func _init(lane_index: int = -1, lane_owner_id: String = "") -> void:
	index = lane_index
	owner_id = lane_owner_id

func is_empty() -> bool:
	return occupant_instance_id.is_empty()

func occupy(instance_id: String) -> bool:
	if instance_id.is_empty() or not is_empty():
		return false
	occupant_instance_id = instance_id
	return true

func clear() -> String:
	var previous := occupant_instance_id
	occupant_instance_id = ""
	return previous

func to_dict() -> Dictionary:
	return {
		"index": index,
		"owner_id": owner_id,
		"occupant_instance_id": occupant_instance_id
	}

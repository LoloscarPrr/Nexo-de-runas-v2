class_name GameEvent
extends RefCounted

var type := ""
var source_id := ""
var target_ids: Array[String] = []
var payload: Dictionary = {}
var sequence := 0

static func create(event_type: String, event_source_id: String = "", event_target_ids: Array = [], event_payload: Dictionary = {}, event_sequence: int = 0):
	var event := GameEvent.new()
	event.type = event_type
	event.source_id = event_source_id
	for target_id in event_target_ids:
		event.target_ids.append(str(target_id))
	event.payload = event_payload.duplicate(true)
	event.sequence = event_sequence
	return event

func to_dict() -> Dictionary:
	return {
		"type": type,
		"source_id": source_id,
		"target_ids": target_ids.duplicate(),
		"payload": payload.duplicate(true),
		"sequence": sequence
	}

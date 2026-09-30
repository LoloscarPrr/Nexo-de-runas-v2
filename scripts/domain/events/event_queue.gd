class_name EventQueue
extends RefCounted

var _events: Array = []
var _next_sequence := 1

func push(event: Object) -> void:
	if event == null:
		return
	event.sequence = _next_sequence
	_next_sequence += 1
	_events.append(event)

func size() -> int:
	return _events.size()

func clear() -> void:
	_events.clear()
	_next_sequence = 1

func drain() -> Array:
	var drained := _events.duplicate()
	_events.clear()
	return drained

func drain_serialized() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in drain():
		result.append(event.to_dict())
	return result

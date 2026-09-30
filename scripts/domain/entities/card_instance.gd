class_name CardInstance
extends RefCounted

const ZONE_DECK := "deck"
const ZONE_HAND := "hand"
const ZONE_BOARD := "board"
const ZONE_DISCARD := "discard"
const ZONE_EXILE := "exile"

var instance_id := ""
var definition_id := ""
var owner_id := ""
var controller_id := ""
var zone := ZONE_DECK
var current_health := 0
var modifiers: Array[Dictionary] = []
var statuses: Array[Dictionary] = []
var ability_state: Dictionary = {}

static func from_definition(definition: Object, new_instance_id: String, new_owner_id: String):
	var instance := CardInstance.new()
	instance.instance_id = new_instance_id
	instance.definition_id = str(definition.get("id")) if definition is Dictionary else str(definition.id)
	instance.owner_id = new_owner_id
	instance.controller_id = new_owner_id
	instance.current_health = int(definition.get("health", definition.get("hp", 0))) if definition is Dictionary else int(definition.base_health)
	return instance

func is_valid() -> bool:
	return not instance_id.is_empty() and not definition_id.is_empty() and not owner_id.is_empty()

func move_to(new_zone: String) -> void:
	zone = new_zone

func add_modifier(modifier: Dictionary) -> void:
	modifiers.append(modifier.duplicate(true))

func add_status(status: Dictionary) -> void:
	statuses.append(status.duplicate(true))

func to_dict() -> Dictionary:
	return {
		"instance_id": instance_id,
		"definition_id": definition_id,
		"owner_id": owner_id,
		"controller_id": controller_id,
		"zone": zone,
		"current_health": current_health,
		"modifiers": modifiers.duplicate(true),
		"statuses": statuses.duplicate(true),
		"ability_state": ability_state.duplicate(true)
	}

class_name AbilityDefinition
extends RefCounted

const ON_PLAY := "on_play"
const ON_SUMMON := "on_summon"
const ON_DEATH := "on_death"
const ON_ATTACK := "on_attack"
const ON_DAMAGE := "on_damage"
const TURN_START := "turn_start"
const TURN_END := "turn_end"

static func create(ability_id: String, trigger: String, target: Dictionary, effects: Array, conditions: Array = []) -> Dictionary:
	return {
		"id": ability_id,
		"trigger": trigger,
		"target": target.duplicate(true),
		"conditions": conditions.duplicate(true),
		"effects": effects.duplicate(true)
	}

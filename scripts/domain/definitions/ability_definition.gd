class_name AbilityDefinition
extends RefCounted

const ConditionDefinitionScript = preload("res://scripts/domain/value_objects/condition_definition.gd")
const TargetSpecScript = preload("res://scripts/domain/value_objects/target_spec.gd")
const EffectDefinitionScript = preload("res://scripts/domain/definitions/effect_definition.gd")

const ON_PLAY := "on_play"
const ON_DEATH := "on_death"
const ON_ATTACK := "on_attack"
const ON_DAMAGE := "on_damage"
const TURN_START := "turn_start"
const TURN_END := "turn_end"

var id := ""
var trigger := ""
var conditions: Array = []
var target_spec = TargetSpecScript.create()
var effects: Array = []

static func from_dictionary(data: Dictionary):
	var ability := AbilityDefinition.new()
	ability.id = str(data.get("id", ""))
	ability.trigger = str(data.get("trigger", ""))
	ability.conditions.clear()
	for raw_condition in Array(data.get("conditions", [])):
		if raw_condition is Dictionary:
			ability.conditions.append(ConditionDefinitionScript.from_dictionary(raw_condition))
	var raw_target = data.get("target", {})
	if raw_target is Dictionary:
		ability.target_spec = TargetSpecScript.from_dictionary(raw_target)
	ability.effects.clear()
	for raw_effect in Array(data.get("effects", [])):
		if raw_effect is Dictionary:
			ability.effects.append(EffectDefinitionScript.from_dictionary(raw_effect))
	return ability

func validate() -> Array[String]:
	var errors: Array[String] = []
	if id.is_empty():
		errors.append("AbilityDefinition requiere id.")
	if trigger.is_empty():
		errors.append("AbilityDefinition requiere trigger.")
	if effects.is_empty():
		errors.append("AbilityDefinition requiere al menos un efecto.")
	for effect in effects:
		errors.append_array(effect.validate())
	return errors

func to_dict() -> Dictionary:
	var serialized_conditions: Array = []
	for condition in conditions:
		serialized_conditions.append(condition.to_dict())
	var serialized_effects: Array = []
	for effect in effects:
		serialized_effects.append(effect.to_dict())
	return {
		"id": id,
		"trigger": trigger,
		"conditions": serialized_conditions,
		"target": target_spec.to_dict(),
		"effects": serialized_effects
	}

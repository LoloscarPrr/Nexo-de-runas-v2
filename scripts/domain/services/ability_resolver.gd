class_name AbilityResolver
extends RefCounted

const AbilityCatalogScript = preload("res://scripts/domain/definitions/ability_catalog.gd")
const TargetResolverScript = preload("res://scripts/domain/services/target_resolver.gd")
const ConditionResolverScript = preload("res://scripts/domain/services/condition_resolver.gd")
const EffectResolverScript = preload("res://scripts/domain/services/effect_resolver.gd")
const GameEventScript = preload("res://scripts/domain/events/game_event.gd")

static func resolve(effect_id: String, trigger: String, context: Dictionary, battle) -> bool:
	var resolved_any := false
	for ability in AbilityCatalogScript.abilities_for(effect_id):
		if str(ability.get("trigger", "")) != trigger:
			continue
		var target_spec: Dictionary = ability.get("target", {})
		var target := TargetResolverScript.resolve(target_spec, context, battle)
		if not bool(target.get("valid", false)):
			continue
		var conditions: Array = ability.get("conditions", [])
		if not ConditionResolverScript.all_met(conditions, target, context, battle):
			continue
		var all_effects_ok := true
		for effect in Array(ability.get("effects", [])):
			if not EffectResolverScript.apply(effect, target, context, battle):
				all_effects_ok = false
				break
		if all_effects_ok:
			resolved_any = true
			battle.event_queue.push(GameEventScript.create("ABILITY_TRIGGERED", str(context.get("source_card_id", "")), [], {"ability_id": str(ability.get("id", "")), "trigger": trigger}))
	return resolved_any

static func can_resolve(effect_id: String, trigger: String, context: Dictionary, battle) -> bool:
	for ability in AbilityCatalogScript.abilities_for(effect_id):
		if str(ability.get("trigger", "")) != trigger:
			continue
		var target := TargetResolverScript.resolve(Dictionary(ability.get("target", {})), context, battle)
		if bool(target.get("valid", false)) and ConditionResolverScript.all_met(Array(ability.get("conditions", [])), target, context, battle):
			return true
	return false

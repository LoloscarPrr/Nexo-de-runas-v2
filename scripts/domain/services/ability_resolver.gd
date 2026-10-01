class_name AbilityResolver
extends RefCounted

const AbilityCatalog = preload("res://scripts/domain/canonical_ability_catalog.gd")
const AbilityDefinitionScript = preload("res://scripts/domain/definitions/ability_definition.gd")
const TargetResolverScript = preload("res://scripts/domain/services/target_resolver.gd")
const ConditionResolverScript = preload("res://scripts/domain/services/condition_resolver.gd")
const EffectResolverScript = preload("res://scripts/domain/services/effect_resolver.gd")
const GameEventScript = preload("res://scripts/domain/events/game_event.gd")

static func ability_for_card(card: Dictionary):
	return AbilityCatalog.for_card(card)

static func has_ability(card: Dictionary) -> bool:
	return ability_for_card(card) != null

static func target_kind_for_card(card: Dictionary) -> String:
	var ability = ability_for_card(card)
	return TargetResolverScript.target_kind_for_card(ability)

static func can_target_card_lane(state, card: Dictionary, lane: int, side: String) -> bool:
	var ability = ability_for_card(card)
	if ability == null or ability.trigger != AbilityDefinitionScript.ON_PLAY:
		return false
	if str(ability.target_spec.target_side()) != side:
		return false
	return can_resolve_card(state, card, AbilityDefinitionScript.ON_PLAY, {"target_lane": lane})

static func can_resolve_card(state, card: Dictionary, trigger: String, context: Dictionary = {}) -> bool:
	var ability = ability_for_card(card)
	if ability == null or str(ability.trigger) != trigger:
		return false
	if not TargetResolverScript.validate(state, ability.target_spec, context):
		return false
	var resolved_context := TargetResolverScript.enrich_context(state, ability.target_spec, context)
	return ConditionResolverScript.all_pass(ability.conditions, state, resolved_context)

static func resolve_card(state, card: Dictionary, trigger: String, context: Dictionary = {}) -> bool:
	var ability = ability_for_card(card)
	if ability == null or str(ability.trigger) != trigger:
		return false
	if not TargetResolverScript.validate(state, ability.target_spec, context):
		return false
	var resolved_context := TargetResolverScript.enrich_context(state, ability.target_spec, context)
	if not ConditionResolverScript.all_pass(ability.conditions, state, resolved_context):
		return false
	var source_id := str(card.get("id", ""))
	_emit(state, "ABILITY_TRIGGERED", source_id, {
		"ability_id": ability.id,
		"trigger": trigger,
		"target_lane": int(resolved_context.get("resolved_target_lane", -1)),
		"target_side": str(resolved_context.get("resolved_target_side", ""))
	})
	for effect in ability.effects:
		if not EffectResolverScript.apply(effect, state, resolved_context):
			return false
		_emit(state, "EFFECT_RESOLVED", source_id, {
			"ability_id": ability.id,
			"effect_type": str(effect.effect_type),
			"params": effect.params.duplicate(true)
		})
	return true

static func _emit(state, event_type: String, source_id: String, payload: Dictionary) -> void:
	var queue = state.get("event_queue")
	if queue == null:
		return
	queue.call("push", GameEventScript.create(event_type, source_id, [], payload))

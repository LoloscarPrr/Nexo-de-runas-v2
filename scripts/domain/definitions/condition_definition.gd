class_name ConditionDefinition
extends RefCounted

const ALWAYS := "always"
const OTHER_ALLY_HAS_TAG := "other_ally_has_tag"
const TARGET_HAS_TAG := "target_has_tag"
const TARGET_EXISTS := "target_exists"
const ADJACENT_ALLY_EXISTS := "adjacent_ally_exists"
const ATTACK_BLOCKED := "attack_blocked"
const CONTROLS_RELIC := "controls_relic"

static func create(condition_type: String, params: Dictionary = {}) -> Dictionary:
	return {"type": condition_type, "params": params.duplicate(true)}

static func always() -> Dictionary:
	return create(ALWAYS)

static func other_ally_has_tag(tag: String) -> Dictionary:
	return create(OTHER_ALLY_HAS_TAG, {"tag": tag})

static func target_has_tag(tag: String) -> Dictionary:
	return create(TARGET_HAS_TAG, {"tag": tag})

static func target_exists() -> Dictionary:
	return create(TARGET_EXISTS)

static func adjacent_ally_exists() -> Dictionary:
	return create(ADJACENT_ALLY_EXISTS)

static func attack_blocked() -> Dictionary:
	return create(ATTACK_BLOCKED)

static func controls_relic() -> Dictionary:
	return create(CONTROLS_RELIC)

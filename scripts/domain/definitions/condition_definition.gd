class_name ConditionDefinition
extends RefCounted

const ALWAYS := "always"
const OTHER_ALLY_HAS_TAG := "other_ally_has_tag"
const TARGET_HAS_TAG := "target_has_tag"
const TARGET_EXISTS := "target_exists"

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

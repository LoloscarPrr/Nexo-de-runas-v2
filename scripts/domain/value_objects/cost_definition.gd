class_name CostDefinition
extends RefCounted

var components: Array[Dictionary] = []

static func energy(amount: int):
	return single("energy", amount, true)

static func essence(amount: int):
	return single("essence", amount, true)

static func single(resource_type: String, amount: int, consume: bool = true):
	var cost := CostDefinition.new()
	cost.add_component(resource_type, amount, consume)
	return cost

func add_component(resource_type: String, amount: int, consume: bool = true, metadata: Dictionary = {}) -> void:
	components.append({
		"resource": resource_type,
		"amount": maxi(0, amount),
		"consume": consume,
		"metadata": metadata.duplicate(true)
	})

func is_free() -> bool:
	for component in components:
		if int(component.get("amount", 0)) > 0:
			return false
	return true

func to_dict() -> Dictionary:
	return {"components": components.duplicate(true)}

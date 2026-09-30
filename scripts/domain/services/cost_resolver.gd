class_name CostResolver
extends RefCounted

static func validate(cost: Object, payer: Object) -> String:
	if cost == null:
		return ""
	if payer == null or not payer.has_method("resource_amount"):
		return "El pagador no expone recursos válidos."
	for component in cost.components:
		var resource_type := str(component.get("resource", ""))
		var amount := int(component.get("amount", 0))
		if resource_type.is_empty():
			return "El coste contiene un recurso inválido."
		if int(payer.resource_amount(resource_type)) < amount:
			return "Recurso insuficiente: %s." % resource_type
	return ""

static func can_pay(cost: Object, payer: Object) -> bool:
	return validate(cost, payer).is_empty()

static func pay(cost: Object, payer: Object) -> bool:
	if not can_pay(cost, payer):
		return false
	for component in cost.components:
		if not bool(component.get("consume", true)):
			continue
		var resource_type := str(component.get("resource", ""))
		var amount := int(component.get("amount", 0))
		if amount > 0 and not payer.spend_resource(resource_type, amount):
			return false
	return true

class_name SaveRepositoryPort
extends RefCounted

## Application port. Infrastructure implements this contract.
## Domain and presentation must not know how bytes are persisted.

func save(slot: String, payload: Dictionary) -> Error:
	push_error("SaveRepositoryPort.save() must be implemented by infrastructure.")
	return ERR_UNAVAILABLE

func load(slot: String) -> Dictionary:
	push_error("SaveRepositoryPort.load() must be implemented by infrastructure.")
	return {}

func exists(slot: String) -> bool:
	return false

func delete(slot: String) -> Error:
	return ERR_UNAVAILABLE

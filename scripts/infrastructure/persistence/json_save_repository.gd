class_name JsonSaveRepository
extends "res://scripts/application/ports/save_repository_port.gd"

const SCHEMA_VERSION := 1

var root_path := "user://saves"

func _init(custom_root: String = "") -> void:
	if not custom_root.is_empty():
		root_path = custom_root

func save(slot: String, payload: Dictionary) -> Error:
	var safe_slot := _safe_slot(slot)
	if safe_slot.is_empty():
		return ERR_INVALID_PARAMETER
	var absolute_root := ProjectSettings.globalize_path(root_path)
	var dir_error := DirAccess.make_dir_recursive_absolute(absolute_root)
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		return dir_error
	var file := FileAccess.open(_path_for(safe_slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"payload": payload
	}))
	file.close()
	return OK

func load(slot: String) -> Dictionary:
	var safe_slot := _safe_slot(slot)
	if safe_slot.is_empty():
		return {}
	var path := _path_for(safe_slot)
	if not FileAccess.file_exists(path):
		return {}
	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var envelope: Dictionary = parsed
	if int(envelope.get("schema_version", 0)) > SCHEMA_VERSION:
		push_warning("Save schema is newer than this build.")
	var payload = envelope.get("payload", {})
	return payload.duplicate(true) if typeof(payload) == TYPE_DICTIONARY else {}

func exists(slot: String) -> bool:
	var safe_slot := _safe_slot(slot)
	return not safe_slot.is_empty() and FileAccess.file_exists(_path_for(safe_slot))

func delete(slot: String) -> Error:
	var safe_slot := _safe_slot(slot)
	if safe_slot.is_empty():
		return ERR_INVALID_PARAMETER
	var path := _path_for(safe_slot)
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _path_for(slot: String) -> String:
	return root_path.path_join("%s.json" % slot)

func _safe_slot(value: String) -> String:
	var cleaned := value.strip_edges().to_lower()
	for forbidden in ["/", "\\", "..", ":", "*"]:
		cleaned = cleaned.replace(forbidden, "_")
	return cleaned

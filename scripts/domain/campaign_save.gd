class_name CampaignSave
extends RefCounted

const CampaignStateScript = preload("res://scripts/domain/campaign_state.gd")
const SAVE_PATH := "user://campaign_act1_v1.json"

static func exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func save_state(state) -> bool:
	if state == null:
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state.to_dict()))
	file.flush()
	return true

static func load_state():
	if not exists():
		return null
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return null
	var state = CampaignStateScript.new()
	if not state.load_from_dict(parsed):
		return null
	return state

static func clear() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

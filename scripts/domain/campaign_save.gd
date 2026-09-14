class_name CampaignSave
extends RefCounted
## Atomic replacement on Android; previous save remains if write/rename fails.
const PATH := "user://campaign_v1.json"

static func write_run(run: CampaignCore, path: String = PATH) -> Error:
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(run.snapshot()))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temp, path)

static func read_run(path: String = PATH) -> CampaignCore:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1048576:
		return null
	var payload: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return CampaignCore.restore(payload)

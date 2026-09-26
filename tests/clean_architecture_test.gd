extends SceneTree

var failures := 0

const RULES := [
	{
		"root": "res://scripts/domain",
		"forbidden": [
			"res://scripts/application/",
			"res://scripts/infrastructure/",
			"res://scripts/presentation/",
			"res://scripts/ui/"
		]
	},
	{
		"root": "res://scripts/application",
		"forbidden": [
			"res://scripts/infrastructure/",
			"res://scripts/presentation/",
			"res://scripts/ui/"
		]
	},
	{
		"root": "res://scripts/infrastructure",
		"forbidden": [
			"res://scripts/presentation/",
			"res://scripts/ui/"
		]
	},
	{
		"root": "res://scripts/presentation",
		"forbidden": [
			"res://scripts/domain/",
			"res://scripts/infrastructure/",
			"res://scripts/ui/"
		]
	}
]

func _initialize() -> void:
	for rule in RULES:
		_scan_layer(str(rule.root), Array(rule.forbidden))
	print("Clean Architecture checks: %d failures" % failures)
	quit(1 if failures else 0)

func _scan_layer(root_path: String, forbidden: Array) -> void:
	for path in _collect_gd_files(root_path):
		var source := FileAccess.get_file_as_string(path)
		for dependency in forbidden:
			if source.contains(str(dependency)):
				push_error("Architecture violation: %s depends on %s" % [path, dependency])
				failures += 1

func _collect_gd_files(root_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(root_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue
		var full_path := root_path.path_join(entry)
		if dir.current_is_dir():
			result.append_array(_collect_gd_files(full_path))
		elif entry.ends_with(".gd"):
			result.append(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
	return result

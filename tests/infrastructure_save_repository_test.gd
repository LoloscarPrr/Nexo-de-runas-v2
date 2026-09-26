extends SceneTree

const RepositoryScript = preload("res://scripts/infrastructure/persistence/json_save_repository.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var repository := RepositoryScript.new("user://test_clean_architecture_saves")
	var slot := "architecture_smoke"
	repository.delete(slot)
	var payload := {"domain": "forest", "turn": 3, "nested": {"integrity": 17}}
	check(repository.save(slot, payload) == OK, "JSON repository saves through infrastructure adapter")
	check(repository.exists(slot), "JSON repository reports saved slot")
	var loaded := repository.load(slot)
	check(str(loaded.get("domain", "")) == "forest", "JSON repository restores strings")
	check(int(loaded.get("turn", 0)) == 3, "JSON repository restores numbers")
	check(int(Dictionary(loaded.get("nested", {})).get("integrity", 0)) == 17, "JSON repository restores nested data")
	check(repository.delete(slot) == OK, "JSON repository deletes slot")
	print("Infrastructure save repository checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not ResourceLoader.exists("res://assets/card_art/lobo.png"):
		_fail("Missing bundled card art: lobo.png")
		return
	if not ResourceLoader.exists("res://assets/card_art/ardilla.png"):
		_fail("Missing bundled card art: ardilla.png")
		return

	root.size = Vector2i(1280, 720)
	await process_frame

	var view = load("res://scripts/ui/mockup_campaign_view.gd").new()
	root.add_child(view)
	view.position = Vector2.ZERO
	view.size = Vector2(1280, 720)
	view.state = load("res://scripts/domain/campaign_state.gd").new()
	view._start_battle("battle_1")
	await process_frame
	await process_frame

	for child in view.get_children():
		if child is Control:
			if child.position.x < -1 or child.position.y < -1:
				_fail("Control starts outside viewport: %s pos=%s" % [child.name, child.position])
				return
			if child.position.x + child.size.x > 1282 or child.position.y + child.size.y > 722:
				_fail("Control exceeds viewport: %s pos=%s size=%s" % [child.name, child.position, child.size])
				return

	if view.battle_state.hand.size() < 4:
		_fail("Expected four opening cards, got %d" % view.battle_state.hand.size())
		return

	view._select_hand(3)
	view._on_player_lane_pressed(0)
	view._select_hand(0)
	view._on_player_lane_pressed(0)
	await process_frame
	print("Mockup battle UI instantiated; real card art loaded; controls fit 1280x720")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	print("BATTLE_UI_TEST_FAILURE: %s" % message)
	quit(1)

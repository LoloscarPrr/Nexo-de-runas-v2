extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var view = load("res://scripts/ui/mockup_campaign_view.gd").new()
	root.add_child(view)
	view.size = Vector2(1280, 720)
	assert(ResourceLoader.exists("res://assets/card_art/lobo.png"))
	assert(ResourceLoader.exists("res://assets/card_art/ardilla.png"))
	view.state = load("res://scripts/domain/campaign_state.gd").new()
	view._start_battle("battle_1")
	await process_frame
	await process_frame
	for child in view.get_children():
		if child is Control:
			assert(child.position.x >= 0 and child.position.y >= 0)
			assert(child.position.x + child.size.x <= 1281)
			assert(child.position.y + child.size.y <= 721)
	view._select_hand(3)
	view._on_player_lane_pressed(0)
	view._select_hand(0)
	view._on_player_lane_pressed(0)
	await process_frame
	print("Mockup battle UI instantiated; real card art loaded; controls fit 1280x720")
	quit()

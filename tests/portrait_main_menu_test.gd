extends SceneTree

const MainScript = preload("res://scripts/main.gd")

var failures := 0
var app

func _initialize() -> void:
	app = MainScript.new()
	root.add_child(app)
	call_deferred("_run_checks")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run_checks() -> void:
	await process_frame
	await process_frame
	await process_frame

	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")
	check(not source.contains("SCREEN_LANDSCAPE"), "Main navigation never forces landscape orientation")
	check(not source.contains("1280") and not source.contains("720"), "Portrait menu has no recycled 1280x720 layout constants")
	check(not source.contains("PREPARA TU VIAJE"), "Main menu removes filler section copy")
	check(not source.contains("El Nexo aguarda"), "Main menu removes the old persistent filler status")
	check(int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)) < int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)), "Canonical project viewport is portrait")

	var menu: Control = app.find_child("MainMenuPortrait", true, false) as Control
	var content: VBoxContainer = app.find_child("MainMenuContent", true, false) as VBoxContainer
	var top_bar: HBoxContainer = app.find_child("MainMenuTopBar", true, false) as HBoxContainer
	var logo: Control = app.find_child("MainMenuLogo", true, false) as Control
	var hero: Control = app.find_child("MainMenuHero", true, false) as Control
	var hero_spacer: Control = app.find_child("MainMenuHeroSpacer", true, false) as Control
	var lower_scene_space: Control = app.find_child("MainMenuLowerSceneSpace", true, false) as Control
	var play: Button = app.find_child("MainPlayButton", true, false) as Button
	var grid: GridContainer = app.find_child("MainMenuGrid", true, false) as GridContainer
	var settings: Button = app.find_child("MainSettingsButton", true, false) as Button
	var status: Label = app.find_child("MainStatusToast", true, false) as Label
	var backdrop: Control = app.find_child("MainMenuBackdrop", true, false) as Control

	check(menu != null and menu.visible, "Portrait main menu is the initial visible screen")
	check(content != null and content.size_flags_vertical == Control.SIZE_EXPAND_FILL, "Portrait menu uses an adaptive vertical container")
	check(top_bar != null and top_bar.get_child_count() == 2, "Logo and settings share a compact top bar")
	check(logo != null and not (logo is PanelContainer), "Logo is ornamental rather than a rectangular panel")
	check(hero != null and hero.custom_minimum_size.y >= 590.0 and hero.custom_minimum_size.y <= 640.0, "Portrait menu reserves a bounded Guardian stage before navigation")
	check(hero != null and hero.size_flags_vertical != Control.SIZE_EXPAND_FILL, "Hero scene cannot expand and recreate the giant middle gap")
	check(hero_spacer != null and hero_spacer.size_flags_vertical != Control.SIZE_EXPAND_FILL and hero_spacer.custom_minimum_size.y >= 500.0, "Guardian receives a bounded clear zone above the title and CTA")
	check(lower_scene_space != null and lower_scene_space.size_flags_vertical == Control.SIZE_EXPAND_FILL, "Flexible empty space lives below navigation as scenic floor")
	check(backdrop != null, "Portrait menu keeps a dedicated scenic backdrop")
	check(play != null and play.custom_minimum_size.y >= 104.0, "Primary play action remains dominant and touch friendly")
	check(grid != null and grid.columns == 2 and grid.get_child_count() == 4, "Secondary navigation is a compact 2x2 grid")
	if grid != null and grid.get_child_count() > 0 and play != null:
		var first_secondary := grid.get_child(0) as Control
		check(first_secondary != null and play.custom_minimum_size.y > first_secondary.custom_minimum_size.y, "Secondary navigation does not compete with JUGAR")
	check(settings != null and settings.text == "⚙" and settings.custom_minimum_size.x <= 80.0, "Settings is a compact gear action in the top bar")
	check(status != null and status.text.is_empty() and status.modulate.a <= 0.01, "Navigation feedback is transient instead of a permanent bottom panel")
	check(app.battle_screen != null and not app.battle_screen.visible, "Battle stays hidden until JUGAR is pressed")
	var pilot: Button = app.find_child("MainVisualPilotButton", true, false) as Button
	check(pilot != null, "Pilot battle is reachable from the APK main menu")
	if pilot != null:
		pilot.pressed.emit()
		await process_frame
		var opening: Dictionary = app.battle_screen.current_snapshot()
		check(app.battle_screen.visible and not menu.visible, "Pilot button opens the actual battle screen")
		check(Array(opening.get("hand", [])).slice(0, 3) == ["bs_001_brote_del_claro", "bs_006_lobo_de_manada", "bs_013_avatar_del_bosque"], "All three pilot cards are accessible in the opening hand")
		check(opening.get("energy_capacity") == 1 and opening.get("player_integrity") == 20, "Pilot mode keeps ordinary starting resources and Integrity")
		check(not quit_on_go_back, "Android Back is handled by navigation before quitting")
		app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		check(app.battle_screen.battle_menu.visible and app.battle_screen.visible, "Android Back opens the battle menu without leaving the match")
		app.battle_screen.find_child("ResumeBattle", true, false).pressed.emit()
		check(not app.battle_screen.battle_menu.visible and app.battle_screen.current_snapshot() == opening, "Continue preserves the entire current match")
		app.battle_screen._inspect_hand_card(0)
		app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		check(not app.battle_screen.card_detail.visible and not app.battle_screen.battle_menu.visible, "Android Back closes inspection before showing navigation")
		app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		app.battle_screen.find_child("ReturnToMainMenu", true, false).pressed.emit()
		check(menu.visible and not app.battle_screen.visible, "Battle menu returns to the actual main menu")
		app._return_to_menu()
		app._start_canonical_battle()
		check(app.battle_screen.current_snapshot().get("hand") == ["bs_001_brote_del_claro", "bs_001_brote_del_claro", "bs_003_lobo_joven", "bs_003_lobo_joven"], "JUGAR still opens the existing starter deck")

	print("Portrait main menu checks: %d failures" % failures)
	quit(1 if failures else 0)

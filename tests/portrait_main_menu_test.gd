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
	check(hero != null and hero.custom_minimum_size.y >= 480.0, "Portrait menu keeps a large hero scene")
	check(hero != null and hero.size_flags_vertical != Control.SIZE_EXPAND_FILL, "Hero scene cannot expand and recreate the giant middle gap")
	check(hero_spacer != null and hero_spacer.size_flags_vertical != Control.SIZE_EXPAND_FILL, "Hero spacer has bounded height instead of swallowing the screen")
	check(lower_scene_space != null and lower_scene_space.size_flags_vertical == Control.SIZE_EXPAND_FILL, "Flexible empty space lives below navigation as scenic floor")
	check(backdrop != null, "Portrait menu keeps a dedicated scenic backdrop")
	check(play != null and play.custom_minimum_size.y >= 100.0, "Primary play action remains dominant and touch friendly")
	check(grid != null and grid.columns == 2 and grid.get_child_count() == 4, "Secondary navigation is a compact 2x2 grid")
	if grid != null and grid.get_child_count() > 0 and play != null:
		var first_secondary := grid.get_child(0) as Control
		check(first_secondary != null and play.custom_minimum_size.y > first_secondary.custom_minimum_size.y, "Secondary navigation does not compete with JUGAR")
	check(settings != null and settings.text == "⚙" and settings.custom_minimum_size.x <= 80.0, "Settings is a compact gear action in the top bar")
	check(status != null and status.text.is_empty() and status.modulate.a <= 0.01, "Navigation feedback is transient instead of a permanent bottom panel")
	check(app.battle_screen != null and not app.battle_screen.visible, "Battle stays hidden until JUGAR is pressed")

	print("Portrait main menu checks: %d failures" % failures)
	quit(1 if failures else 0)

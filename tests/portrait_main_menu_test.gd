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
	check(int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)) < int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)), "Canonical project viewport is portrait")

	var menu: Control = app.find_child("MainMenuPortrait", true, false) as Control
	var content: Control = app.find_child("MainMenuContent", true, false) as Control
	var logo: Control = app.find_child("MainMenuLogo", true, false) as Control
	var hero: Control = app.find_child("MainMenuHero", true, false) as Control
	var play: Button = app.find_child("MainPlayButton", true, false) as Button
	var grid: GridContainer = app.find_child("MainMenuGrid", true, false) as GridContainer
	var settings: Button = app.find_child("MainSettingsButton", true, false) as Button
	var status: Label = app.find_child("MainStatus", true, false) as Label

	check(menu != null and menu.visible, "Portrait main menu is the initial visible screen")
	check(content != null, "Portrait menu uses an adaptive vertical content container")
	check(logo != null, "Portrait menu exposes the Nexo logo block")
	check(hero != null and hero.size.y >= 300.0, "Portrait menu reserves a vertical hero area")
	check(play != null and play.size.y >= 100.0, "Primary play action is large enough for touch")
	check(grid != null and grid.get_child_count() == 4, "Secondary navigation is a compact two-column grid")
	check(settings != null, "Settings remains available in the portrait menu")
	check(status != null, "Portrait menu keeps a navigation status area")
	check(app.battle_screen != null and not app.battle_screen.visible, "Battle stays hidden until JUGAR is pressed")

	print("Portrait main menu checks: %d failures" % failures)
	quit(1 if failures else 0)

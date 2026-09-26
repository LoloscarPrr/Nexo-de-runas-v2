extends Control

## Entrada de migración hacia el Nexo de Runas canónico.
## La batalla nueva convive temporalmente con la campaña legado para conservar saves.

const CampaignViewScript = preload("res://scripts/ui/mockup_campaign_view.gd")
const CampaignBackdropScript = preload("res://scripts/ui/campaign_backdrop.gd")
const CanonicalBattleViewScript = preload("res://scripts/ui/canonical_battle_view.gd")

const NIGHT := Color8(5, 8, 4)
const INK := Color8(225, 225, 180)
const MUTED := Color8(133, 145, 91)
const AMBER := Color8(210, 184, 85)
const BLOOD := Color8(121, 43, 34)
const EDGE := Color8(76, 89, 40)

var menu_screen: Control
var campaign_screen
var battle_screen: CanonicalBattleView
var continue_button: Button

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_background()
	_build_menu()
	_build_campaign()
	_build_canonical_battle()
	_show(menu_screen)

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = NIGHT
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

func _build_campaign() -> void:
	campaign_screen = CampaignViewScript.new()
	campaign_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	campaign_screen.connect("exit_requested", _return_to_menu)
	add_child(campaign_screen)

func _build_canonical_battle() -> void:
	battle_screen = CanonicalBattleViewScript.new()
	battle_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle_screen.connect("exit_requested", _return_to_menu)
	add_child(battle_screen)

func _build_menu() -> void:
	menu_screen = Control.new()
	menu_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_screen)

	var backdrop := CampaignBackdropScript.new()
	backdrop.mode = "menu"
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_screen.add_child(backdrop)

	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	_place_in(menu_screen, _label("NEXO DE RUNAS", 52, INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, vh * 0.22, vw * 0.46, 68))
	_place_in(menu_screen, _label("CUATRO DOMINIOS · UN SOLO NEXO", 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.29, vh * 0.31, vw * 0.42, 28))

	var button_w := minf(500.0, vw * 0.41)
	var button_x := vw * 0.5 - button_w * 0.5
	var play := _menu_button("JUGAR", "BOSQUE SALVAJE · BATALLA CANÓNICA")
	play.pressed.connect(_start_canonical_battle)
	_place_in(menu_screen, play, Rect2(button_x, vh * 0.56, button_w, 78))

	continue_button = _menu_button("CONTINUAR", "COMPATIBILIDAD CON EXPEDICIÓN ANTERIOR")
	continue_button.pressed.connect(_continue_game)
	_place_in(menu_screen, continue_button, Rect2(button_x, vh * 0.70, button_w, 70))

	_place_in(menu_screen, _label("BOSQUE   ·   CRIPTA   ·   TORRE   ·   FUNDICIÓN", 11, AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.29, vh - 43, vw * 0.42, 24))

func _start_canonical_battle() -> void:
	battle_screen.start_battle()
	_show(battle_screen)

func _continue_game() -> void:
	campaign_screen.continue_game()
	_show(campaign_screen)

func _return_to_menu() -> void:
	_show(menu_screen)

func _show(target: Control) -> void:
	menu_screen.visible = target == menu_screen
	campaign_screen.visible = target == campaign_screen
	battle_screen.visible = target == battle_screen
	if target == menu_screen and continue_button != null and campaign_screen != null:
		continue_button.disabled = not campaign_screen.has_save()

func _menu_button(title_text: String, subtitle_text: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [title_text, subtitle_text]
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color8(238, 230, 166))
	button.add_theme_color_override("font_pressed_color", Color8(248, 228, 179))
	button.add_theme_color_override("font_disabled_color", Color8(74, 82, 46))
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.045, 0.065, 0.032, 0.94), EDGE, 2, 5))
	button.add_theme_stylebox_override("hover", _panel_style(Color(0.08, 0.11, 0.045, 0.97), AMBER, 3, 5))
	button.add_theme_stylebox_override("pressed", _panel_style(Color(0.16, 0.07, 0.045, 0.98), BLOOD, 3, 5))
	button.add_theme_stylebox_override("disabled", _panel_style(Color(0.035, 0.05, 0.026, 0.86), Color8(46, 55, 31), 2, 5))
	return button

func _label(text_value: String, size_value: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _place_in(parent: Control, control: Control, rect: Rect2) -> void:
	parent.add_child(control)
	control.position = rect.position
	control.size = rect.size
	control.set_deferred("size", rect.size)

func _panel_style(color: Color, border_color: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

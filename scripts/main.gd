extends Control

## Nexo de Runas V2 — entrada principal de la experiencia Acto 1.
## El mockup es la referencia visual canónica: incluso el menú existe dentro
## de la misma cabaña/mesa física y no como una pantalla UI independiente.

const CampaignViewScript = preload("res://scripts/ui/mockup_campaign_view.gd")
const CampaignBackdropScript = preload("res://scripts/ui/campaign_backdrop.gd")

const NIGHT := Color8(5, 8, 4)
const INK := Color8(199, 213, 103)
const MUTED := Color8(113, 125, 67)
const AMBER := Color8(198, 218, 88)
const BLOOD := Color8(121, 43, 34)
const EDGE := Color8(76, 89, 40)
const WOOD_DEEP := Color8(9, 14, 7)
const WOOD := Color8(21, 29, 14)

var menu_screen: Control
var campaign_screen
var continue_button: Button

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_background()
	_build_menu()
	_build_campaign()
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

	_place_in(menu_screen, _label("NEXO DE RUNAS", 52, INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, vh * 0.245, vw * 0.40, 68))
	_place_in(menu_screen, _label("TODO VUELVE AL CICLO", 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.29, vh * 0.335, vw * 0.36, 28))

	var button_w := minf(460.0, vw * 0.38)
	var button_x := vw * 0.5 - button_w * 0.5
	var new_game := _menu_button("NUEVA PARTIDA", "INICIAR EL CICLO")
	new_game.pressed.connect(_start_new_game)
	_place_in(menu_screen, new_game, Rect2(button_x, vh * 0.60, button_w, 72))

	continue_button = _menu_button("CONTINUAR", "VOLVER AL TABLERO")
	continue_button.pressed.connect(_continue_game)
	_place_in(menu_screen, continue_button, Rect2(button_x, vh * 0.715, button_w, 72))

	_place_in(menu_screen, _label("SANGRE   ·   HUESOS   ·   SELLOS   ·   CICLO", 11, AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.32, vh - 42, vw * 0.36, 24))

func _start_new_game() -> void:
	campaign_screen.start_new_game()
	_show(campaign_screen)

func _continue_game() -> void:
	campaign_screen.continue_game()
	_show(campaign_screen)

func _return_to_menu() -> void:
	_show(menu_screen)

func _show(target: Control) -> void:
	menu_screen.visible = target == menu_screen
	campaign_screen.visible = target == campaign_screen
	if target == menu_screen and continue_button != null and campaign_screen != null:
		continue_button.disabled = not campaign_screen.has_save()

func _menu_button(title_text: String, subtitle_text: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [title_text, subtitle_text]
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color8(222, 232, 125))
	button.add_theme_color_override("font_pressed_color", Color8(248, 228, 179))
	button.add_theme_color_override("font_disabled_color", Color8(74, 82, 46))
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.045, 0.065, 0.032, 0.94), EDGE, 2, 3))
	button.add_theme_stylebox_override("hover", _panel_style(Color(0.08, 0.11, 0.045, 0.97), AMBER, 3, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(Color(0.16, 0.07, 0.045, 0.98), BLOOD, 3, 3))
	button.add_theme_stylebox_override("disabled", _panel_style(Color(0.035, 0.05, 0.026, 0.86), Color8(46, 55, 31), 2, 3))
	return button

func _label(text_value: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
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

extends Control

## Nexo de Runas V2 — flujo principal enfocado exclusivamente en Acto 1.
## El antiguo constructor por facciones y Batalla local quedan fuera del menú activo.

const CampaignViewScript = preload("res://scripts/ui/immersive_campaign_view.gd")

const NIGHT := Color8(7, 5, 4)
const CABIN := Color8(18, 13, 9)
const WOOD := Color8(35, 25, 16)
const INK := Color8(234, 220, 181)
const MUTED := Color8(150, 132, 98)
const AMBER := Color8(188, 126, 57)
const BLOOD := Color8(132, 40, 33)
const EDGE := Color8(75, 52, 29)

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

	var inner := ColorRect.new()
	inner.color = CABIN
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 34
	inner.offset_right = -34
	inner.offset_top = 18
	inner.offset_bottom = -18
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(inner)

func _build_campaign() -> void:
	campaign_screen = CampaignViewScript.new()
	campaign_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	campaign_screen.connect("exit_requested", _return_to_menu)
	add_child(campaign_screen)

func _build_menu() -> void:
	menu_screen = MarginContainer.new()
	menu_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_screen.add_theme_constant_override("margin_left", 90)
	menu_screen.add_theme_constant_override("margin_right", 90)
	menu_screen.add_theme_constant_override("margin_top", 70)
	menu_screen.add_theme_constant_override("margin_bottom", 70)
	add_child(menu_screen)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(CABIN, EDGE, 2))
	menu_screen.add_child(panel)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 18)
	panel.add_child(root)

	var whisper := _label("LA PUERTA ESTÁ ABIERTA", 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(whisper)
	root.add_child(_label("NEXO DE RUNAS", 52, INK, HORIZONTAL_ALIGNMENT_CENTER))
	root.add_child(_label("La cabaña no está vacía.", 17, AMBER, HORIZONTAL_ALIGNMENT_CENTER))

	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(650, 8)
	root.add_child(rule)

	var new_game := _menu_button("NUEVA PARTIDA", "Comenzar una expedición desde el sendero")
	new_game.pressed.connect(_start_new_game)
	root.add_child(new_game)

	continue_button = _menu_button("CONTINUAR", "Regresar a la mesa donde la dejaste")
	continue_button.pressed.connect(_continue_game)
	root.add_child(continue_button)

	root.add_child(_label("Acto 1 en reconstrucción · Sangre · Huesos · Sacrificios", 12, MUTED, HORIZONTAL_ALIGNMENT_CENTER))

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
	button.custom_minimum_size = Vector2(670, 78)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", Color8(83, 73, 57))
	button.add_theme_stylebox_override("normal", _panel_style(Color8(25, 18, 12), EDGE, 2))
	button.add_theme_stylebox_override("hover", _panel_style(WOOD, AMBER, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(Color8(51, 29, 21), BLOOD, 3))
	return button

func _label(text_value: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style(color: Color, border_color: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

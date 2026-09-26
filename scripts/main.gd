extends Control

## Entrada principal durante la migración al Nexo de Runas canónico.
## La campaña legado sigue cargada para conservar saves, pero deja de dominar la UI.

const CampaignViewScript = preload("res://scripts/ui/mockup_campaign_view.gd")
const CanonicalBattleViewScript = preload("res://scripts/ui/canonical_battle_view.gd")
const MenuBackdropScript = preload("res://scripts/ui/canonical_main_menu_backdrop.gd")

const INK := Color("eadca8")
const MUTED := Color("9b986c")
const GOLD := Color("d2aa54")
const MOSS := Color("6b7b3a")
const WOOD := Color("1b130b")
const WOOD_LIGHT := Color("2b1d0f")
const BLOOD := Color("78362c")

var menu_screen: Control
var campaign_screen
var battle_screen: CanonicalBattleView
var menu_status: Label

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_background()
	_build_menu()
	_build_campaign()
	_build_canonical_battle()
	_show(menu_screen)

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = Color("050704")
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

	var backdrop := MenuBackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_screen.add_child(backdrop)

	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	var title := _label("NEXO DE RUNAS", 38, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_place_in(menu_screen, title, Rect2(vw * 0.33, 24, vw * 0.34, 54))
	var subtitle := _label("CARTAS · DOMINIOS · DESTINOS", 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place_in(menu_screen, subtitle, Rect2(vw * 0.36, 70, vw * 0.28, 22))

	# Acción principal sobre el libro central.
	var play := _menu_button("JUGAR", "ENTRAR AL NEXO", true)
	play.pressed.connect(_start_canonical_battle)
	_place_in(menu_screen, play, Rect2(vw * 0.39, vh * 0.50, vw * 0.22, 92))

	# Herramientas físicas alrededor de la mesa. Ya ocupan su posición canónica
	# aunque algunas todavía estén en construcción durante esta vertical slice.
	var deckbuilder := _menu_button("CONSTRUCTOR DE MAZOS", "PREPARAR TU SENDERO")
	deckbuilder.pressed.connect(func(): _notice("El Constructor de Mazos será la siguiente sala en conectarse al nuevo core."))
	_place_in(menu_screen, deckbuilder, Rect2(vw * 0.075, vh * 0.47, vw * 0.23, 76))

	var collection := _menu_button("COLECCIÓN", "CARTAS DESCUBIERTAS")
	collection.pressed.connect(func(): _notice("La Colección conservará este mismo lenguaje físico de cartas."))
	_place_in(menu_screen, collection, Rect2(vw * 0.10, vh * 0.66, vw * 0.20, 72))

	var profile := _menu_button("PERFIL", "VIAJERO DEL NEXO")
	profile.pressed.connect(func(): _notice("Perfil está reservado en el canon y se conectará después del core de batalla."))
	_place_in(menu_screen, profile, Rect2(vw * 0.72, vh * 0.43, vw * 0.20, 70))

	var achievements := _menu_button("LOGROS", "MARCAS DEL VIAJE")
	achievements.pressed.connect(func(): _notice("Logros está reservado; todavía no modifica tu progreso."))
	_place_in(menu_screen, achievements, Rect2(vw * 0.73, vh * 0.60, vw * 0.19, 70))

	var settings := _menu_button("AJUSTES", "AUDIO · GRÁFICOS · CONTROLES")
	settings.pressed.connect(func(): _notice("Ajustes se conectará cuando terminemos la plantilla visual de batalla."))
	_place_in(menu_screen, settings, Rect2(vw * 0.70, vh * 0.77, vw * 0.22, 68))

	menu_status = _label("El Nexo aguarda.", 11, INK, HORIZONTAL_ALIGNMENT_CENTER)
	menu_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_in(menu_screen, menu_status, Rect2(vw * 0.32, vh - 58, vw * 0.36, 34))

func _start_canonical_battle() -> void:
	battle_screen.start_battle()
	_show(battle_screen)

func _return_to_menu() -> void:
	_show(menu_screen)
	_notice("El Nexo aguarda.")

func _notice(text_value: String) -> void:
	if menu_status != null:
		menu_status.text = text_value

func _show(target: Control) -> void:
	menu_screen.visible = target == menu_screen
	campaign_screen.visible = target == campaign_screen
	battle_screen.visible = target == battle_screen

func _menu_button(title_text: String, subtitle_text: String, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [title_text, subtitle_text]
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15 if primary else 13)
	button.add_theme_color_override("font_color", Color("f1e2ad"))
	button.add_theme_color_override("font_hover_color", Color("fff0ba"))
	button.add_theme_color_override("font_pressed_color", Color("fff2c2"))
	var normal := Color("302012") if primary else Color("19130c")
	var edge := Color("b08639") if primary else Color("6f7138")
	button.add_theme_stylebox_override("normal", _panel_style(normal, edge, 3 if primary else 2, 7))
	button.add_theme_stylebox_override("hover", _panel_style(WOOD_LIGHT, GOLD, 3, 7))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("34160e"), BLOOD, 3, 7))
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

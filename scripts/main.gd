extends Control

## Entrada principal canónica de Nexo de Runas.
## El menú y la batalla usan una composición móvil vertical; la Presentation no
## decide reglas de juego y sólo conecta navegación con las pantallas existentes.

const CampaignViewScript = preload("res://scripts/ui/mockup_campaign_view.gd")
const CanonicalBattleViewScript = preload("res://scripts/presentation/battle/vertical_battle_view_faithful.gd")
const MenuBackdropScript = preload("res://scripts/ui/canonical_main_menu_backdrop.gd")

const INK := Color("eadca8")
const MUTED := Color("a9a17b")
const GOLD := Color("d8a84c")
const GOLD_BRIGHT := Color("f0c56a")
const WOOD := Color("17100a")
const WOOD_LIGHT := Color("2d1c0e")
const BLOOD := Color("743126")
const FOREST := Color("183a20")
const FOREST_GLOW := Color("66d85b")

var menu_screen: Control
var campaign_screen
var battle_screen: Control
var menu_status: Label

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
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
	menu_screen.name = "MainMenuPortrait"
	menu_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_screen)

	var backdrop := MenuBackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_screen.add_child(backdrop)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 34)
	outer.add_theme_constant_override("margin_right", 34)
	outer.add_theme_constant_override("margin_top", 42)
	outer.add_theme_constant_override("margin_bottom", 34)
	menu_screen.add_child(outer)

	var root := VBoxContainer.new()
	root.name = "MainMenuContent"
	root.add_theme_constant_override("separation", 14)
	outer.add_child(root)

	var logo := PanelContainer.new()
	logo.name = "MainMenuLogo"
	logo.custom_minimum_size = Vector2(0, 122)
	logo.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.028, 0.014, 0.94), GOLD, 4, 10))
	root.add_child(logo)

	var logo_stack := VBoxContainer.new()
	logo_stack.add_theme_constant_override("separation", -2)
	logo.add_child(logo_stack)
	var title := _label("◆  NEXO DE RUNAS  ◆", 38, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.92))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	logo_stack.add_child(title)
	var subtitle := _label("CARTAS · DOMINIOS · DESTINOS", 12, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	logo_stack.add_child(subtitle)

	var hero := PanelContainer.new()
	hero.name = "MainMenuHero"
	hero.custom_minimum_size = Vector2(0, 360)
	hero.add_theme_stylebox_override("panel", _panel_style(Color(0.02, 0.055, 0.025, 0.66), Color(0.38, 0.50, 0.25, 0.82), 2, 18))
	root.add_child(hero)

	var hero_stack := VBoxContainer.new()
	hero_stack.add_theme_constant_override("separation", 8)
	hero.add_child(hero_stack)
	var sigil := _label("◈", 86, FOREST_GLOW, HORIZONTAL_ALIGNMENT_CENTER)
	sigil.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero_stack.add_child(sigil)
	var hero_title := _label("EL NEXO DESPIERTA", 25, INK, HORIZONTAL_ALIGNMENT_CENTER)
	hero_stack.add_child(hero_title)
	var hero_copy := _label("Cinco carriles. Cuatro dominios.\nUn solo sendero hacia el Nexo.", 14, Color("c4bd91"), HORIZONTAL_ALIGNMENT_CENTER)
	hero_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_stack.add_child(hero_copy)

	var play := _menu_button("JUGAR", "ENTRAR AL NEXO", true)
	play.name = "MainPlayButton"
	play.custom_minimum_size = Vector2(0, 116)
	play.pressed.connect(_start_canonical_battle)
	root.add_child(play)

	var section := _label("PREPARA TU VIAJE", 13, Color("c79a4b"), HORIZONTAL_ALIGNMENT_CENTER)
	section.custom_minimum_size = Vector2(0, 30)
	root.add_child(section)

	var grid := GridContainer.new()
	grid.name = "MainMenuGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	root.add_child(grid)

	var deckbuilder := _menu_button("CONSTRUCTOR", "PREPARAR MAZO")
	deckbuilder.custom_minimum_size = Vector2(0, 94)
	deckbuilder.pressed.connect(func(): _notice("El Constructor de Mazos será la siguiente sala en conectarse al nuevo core."))
	grid.add_child(deckbuilder)

	var collection := _menu_button("COLECCIÓN", "CARTAS DESCUBIERTAS")
	collection.custom_minimum_size = Vector2(0, 94)
	collection.pressed.connect(func(): _notice("La Colección conservará el mismo lenguaje físico de cartas."))
	grid.add_child(collection)

	var profile := _menu_button("PERFIL", "VIAJERO DEL NEXO")
	profile.custom_minimum_size = Vector2(0, 94)
	profile.pressed.connect(func(): _notice("Perfil está reservado para el progreso del viajero."))
	grid.add_child(profile)

	var achievements := _menu_button("LOGROS", "MARCAS DEL VIAJE")
	achievements.custom_minimum_size = Vector2(0, 94)
	achievements.pressed.connect(func(): _notice("Logros está reservado; todavía no modifica tu progreso."))
	grid.add_child(achievements)

	var settings := _menu_button("AJUSTES", "AUDIO · GRÁFICOS · CONTROLES")
	settings.name = "MainSettingsButton"
	settings.custom_minimum_size = Vector2(0, 82)
	settings.pressed.connect(func(): _notice("Ajustes se conectará después de cerrar la Presentation de batalla."))
	root.add_child(settings)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	var status_frame := PanelContainer.new()
	status_frame.custom_minimum_size = Vector2(0, 62)
	status_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.025, 0.015, 0.80), Color("5e502d"), 1, 8))
	root.add_child(status_frame)
	menu_status = _label("El Nexo aguarda.", 12, INK, HORIZONTAL_ALIGNMENT_CENTER)
	menu_status.name = "MainStatus"
	menu_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_frame.add_child(menu_status)

func _start_canonical_battle() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	battle_screen.start_battle()
	_show(battle_screen)

func _return_to_menu() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
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
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 19 if primary else 14)
	button.add_theme_color_override("font_color", Color("f2e2ad"))
	button.add_theme_color_override("font_hover_color", Color("fff0ba"))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	var normal := Color("185622") if primary else Color("17120c")
	var edge := Color("e0ad46") if primary else Color("796138")
	button.add_theme_stylebox_override("normal", _panel_style(normal, edge, 4 if primary else 2, 12))
	button.add_theme_stylebox_override("hover", _panel_style(Color("24702d") if primary else WOOD_LIGHT, GOLD_BRIGHT, 4 if primary else 3, 12))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("103f18") if primary else Color("34160e"), BLOOD if not primary else Color("f0c85f"), 4, 12))
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
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	return style

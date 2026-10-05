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
const WOOD_LIGHT := Color("2d1c0e")
const BLOOD := Color("743126")
const FOREST_GLOW := Color("66d85b")

var menu_screen: Control
var campaign_screen
var battle_screen: Control
var menu_status: Label
var status_tween: Tween

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
	backdrop.name = "MainMenuBackdrop"
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_screen.add_child(backdrop)

	var safe := MarginContainer.new()
	safe.name = "MainMenuSafeArea"
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 28)
	safe.add_theme_constant_override("margin_right", 28)
	safe.add_theme_constant_override("margin_top", 24)
	safe.add_theme_constant_override("margin_bottom", 24)
	menu_screen.add_child(safe)

	var root := VBoxContainer.new()
	root.name = "MainMenuContent"
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	safe.add_child(root)

	var top_bar := HBoxContainer.new()
	top_bar.name = "MainMenuTopBar"
	top_bar.custom_minimum_size = Vector2(0, 92)
	top_bar.add_theme_constant_override("separation", 8)
	root.add_child(top_bar)

	var logo := VBoxContainer.new()
	logo.name = "MainMenuLogo"
	logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	logo.add_theme_constant_override("separation", -5)
	top_bar.add_child(logo)

	var title := _label("✦  NEXO DE RUNAS  ✦", 34, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	logo.add_child(title)
	var logo_rule := _label("────── ◇ ──────", 13, Color("a36c32"), HORIZONTAL_ALIGNMENT_LEFT)
	logo.add_child(logo_rule)

	var settings := Button.new()
	settings.name = "MainSettingsButton"
	settings.text = "⚙"
	settings.tooltip_text = "Ajustes"
	settings.focus_mode = Control.FOCUS_NONE
	settings.custom_minimum_size = Vector2(72, 72)
	settings.add_theme_font_size_override("font_size", 31)
	settings.add_theme_color_override("font_color", GOLD_BRIGHT)
	settings.add_theme_color_override("font_hover_color", Color.WHITE)
	settings.add_theme_stylebox_override("normal", _panel_style(Color(0.05, 0.035, 0.02, 0.58), Color(0.55, 0.38, 0.18, 0.78), 1, 36, 8))
	settings.add_theme_stylebox_override("hover", _panel_style(Color(0.09, 0.065, 0.03, 0.78), GOLD, 2, 36, 8))
	settings.add_theme_stylebox_override("pressed", _panel_style(Color(0.14, 0.08, 0.025, 0.90), GOLD_BRIGHT, 2, 36, 8))
	settings.pressed.connect(func(): _notice("Ajustes se conectará después de cerrar la Presentation de batalla."))
	top_bar.add_child(settings)

	# Zona heroica abierta: no hay panel oscuro delante del Guardián. El fondo lo
	# dibuja a gran escala y aquí sólo se ancla el mensaje sobre la escena.
	var hero := VBoxContainer.new()
	hero.name = "MainMenuHero"
	hero.custom_minimum_size = Vector2(0, 390)
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.add_theme_constant_override("separation", 2)
	root.add_child(hero)

	var hero_spacer := Control.new()
	hero_spacer.custom_minimum_size = Vector2(0, 255)
	hero_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.add_child(hero_spacer)

	var hero_title := _label("EL NEXO DESPIERTA", 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	hero_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hero_title.add_theme_constant_override("shadow_offset_x", 2)
	hero_title.add_theme_constant_override("shadow_offset_y", 2)
	hero.add_child(hero_title)
	var hero_copy := _label("El Guardián custodia el umbral.", 13, Color("c9c09a"), HORIZONTAL_ALIGNMENT_CENTER)
	hero_copy.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hero.add_child(hero_copy)

	var play := _menu_button("JUGAR", "Entrar al Nexo", true)
	play.name = "MainPlayButton"
	play.custom_minimum_size = Vector2(0, 112)
	play.pressed.connect(_start_canonical_battle)
	root.add_child(play)

	var grid := GridContainer.new()
	grid.name = "MainMenuGrid"
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_SHRINK_END
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	root.add_child(grid)

	var deckbuilder := _menu_button("CONSTRUCTOR", "Mazos")
	deckbuilder.name = "MainDeckbuilderButton"
	deckbuilder.custom_minimum_size = Vector2(0, 82)
	deckbuilder.pressed.connect(func(): _notice("El Constructor de Mazos será la siguiente sala en conectarse al nuevo core."))
	grid.add_child(deckbuilder)

	var collection := _menu_button("COLECCIÓN", "Cartas")
	collection.name = "MainCollectionButton"
	collection.custom_minimum_size = Vector2(0, 82)
	collection.pressed.connect(func(): _notice("La Colección conservará el mismo lenguaje físico de cartas."))
	grid.add_child(collection)

	var profile := _menu_button("PERFIL", "Viajero")
	profile.name = "MainProfileButton"
	profile.custom_minimum_size = Vector2(0, 82)
	profile.pressed.connect(func(): _notice("Perfil está reservado para el progreso del viajero."))
	grid.add_child(profile)

	var achievements := _menu_button("LOGROS", "Marcas")
	achievements.name = "MainAchievementsButton"
	achievements.custom_minimum_size = Vector2(0, 82)
	achievements.pressed.connect(func(): _notice("Logros está reservado; todavía no modifica tu progreso."))
	grid.add_child(achievements)

	# Feedback transitorio, no bloque permanente: conserva el comportamiento de
	# navegación actual sin convertir la parte baja en otra caja de interfaz.
	menu_status = _label("", 12, INK, HORIZONTAL_ALIGNMENT_CENTER)
	menu_status.name = "MainStatusToast"
	menu_status.custom_minimum_size = Vector2(0, 32)
	menu_status.modulate.a = 0.0
	menu_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(menu_status)

func _start_canonical_battle() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	battle_screen.start_battle()
	_show(battle_screen)

func _return_to_menu() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	_show(menu_screen)

func _notice(text_value: String) -> void:
	if menu_status == null:
		return
	if status_tween != null and status_tween.is_valid():
		status_tween.kill()
	menu_status.text = text_value
	menu_status.modulate.a = 1.0
	status_tween = create_tween()
	status_tween.tween_interval(2.6)
	status_tween.tween_property(menu_status, "modulate:a", 0.0, 0.45)

func _show(target: Control) -> void:
	menu_screen.visible = target == menu_screen
	campaign_screen.visible = target == campaign_screen
	battle_screen.visible = target == battle_screen

func _menu_button(title_text: String, subtitle_text: String, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [title_text, subtitle_text]
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 20 if primary else 14)
	button.add_theme_color_override("font_color", Color("f2e2ad"))
	button.add_theme_color_override("font_hover_color", Color("fff0ba"))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	var normal := Color(0.08, 0.24, 0.10, 0.94) if primary else Color(0.055, 0.045, 0.028, 0.82)
	var edge := Color("e0ad46") if primary else Color(0.45, 0.34, 0.18, 0.72)
	button.add_theme_stylebox_override("normal", _panel_style(normal, edge, 4 if primary else 1, 16 if primary else 13, 14 if primary else 10))
	button.add_theme_stylebox_override("hover", _panel_style(Color("24702d") if primary else WOOD_LIGHT, GOLD_BRIGHT, 4 if primary else 2, 16 if primary else 13, 14 if primary else 10))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("103f18") if primary else Color("34160e"), BLOOD if not primary else Color("f0c85f"), 4 if primary else 2, 16 if primary else 13, 14 if primary else 10))
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

func _panel_style(color: Color, border_color: Color, width: int, radius: int, padding: int = 12) -> StyleBoxFlat:
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
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	return style

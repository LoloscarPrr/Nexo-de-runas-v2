class_name VerticalBattleViewFaithful
extends "res://scripts/presentation/battle/vertical_battle_view_polished.gd"

## Segunda pasada visual: conserva el wiring de batalla y reemplaza únicamente
## Presentation para acercarla literalmente al mockup aprobado.

const FaithfulCardScript = preload("res://scripts/presentation/battle/vertical_battle_card_faithful.gd")
const OrnamentScript = preload("res://scripts/presentation/battle/vertical_battle_ornament.gd")
const FaithfulLaneScript = preload("res://scripts/presentation/battle/vertical_lane_slot.gd")
const DetailScript = preload("res://scripts/presentation/battle/vertical_card_detail.gd")
const ResultScript = preload("res://scripts/presentation/battle/vertical_battle_result.gd")

const PARCHMENT_F := Color("ead7a3")
const GREEN_F := Color("62df58")
const ORANGE_F := Color("ec762d")
const PANEL_DARK_F := Color(0.025, 0.022, 0.016, 0.92)

## Optional review deck. Uses existing canonical IDs and ordinary battle rules.
const VISUAL_PILOT_DECK: Array[String] = [
	"bs_001_brote_del_claro", "bs_006_lobo_de_manada", "bs_013_avatar_del_bosque", "bs_001_brote_del_claro",
	"bs_003_lobo_joven", "bs_003_lobo_joven", "bs_004_cierva_guardabosques", "bs_004_cierva_guardabosques",
	"bs_006_lobo_de_manada", "bs_007_chaman_del_roble", "bs_007_chaman_del_roble",
	"bs_008_jabali_de_corteza", "bs_008_jabali_de_corteza", "bs_010_oso_musgoso", "bs_010_oso_musgoso",
	"bs_014_savia_vital", "bs_014_savia_vital", "bs_015_crecimiento_repentino", "bs_015_crecimiento_repentino",
	"bs_019_totem_de_savia"
]

var card_detail
var battle_menu: Control
var result_screen
var _result_presented := false
var _hand_scroll: ScrollContainer
var _essence_caption: Label
var _energy_pips: Label
var _relics_count: Label
var _discard_count: Label

func _build_view() -> void:
	super._build_view()
	card_detail = DetailScript.new()
	add_child(card_detail)
	_hand_scroll = hand_strip.get_parent() as ScrollContainer
	_hand_scroll.scroll_started.connect(_cancel_hand_gestures)
	_build_battle_menu()
	result_screen = ResultScript.new()
	add_child(result_screen)
	result_screen.rematch_requested.connect(_on_rematch_requested)
	result_screen.board_requested.connect(func(): result_screen.hide())
	result_screen.exit_requested.connect(func():
		result_screen.hide()
		exit_requested.emit())

func start_battle(domain: String = "forest", player_deck: Array[String] = []) -> void:
	_reset_result_navigation()
	card_detail.hide_detail()
	battle_menu.hide()
	_hand_scroll.scroll_horizontal = 0
	super.start_battle(domain, player_deck)

func start_visual_pilot_battle() -> void:
	_reset_result_navigation()
	card_detail.hide_detail()
	battle_menu.hide()
	_hand_scroll.scroll_horizontal = 0
	if session == null:
		session = SessionScript.new()
	selected_hand_index = -1
	_snapshot = session.start_vs_cpu("forest", VISUAL_PILOT_DECK)
	_render()
	status_label.text = "Mantén pulsada una carta para ampliarla."
	visible = true

func _reset_result_navigation() -> void:
	_result_presented = false
	result_screen.hide()
	event_label.text = ""
	status_label.text = "Elige una carta de tu mano."

func _is_finished() -> bool:
	return ["victory", "defeat"].has(str(_snapshot.get("result", "ongoing")))

func _render() -> void:
	if _is_finished():
		selected_hand_index = -1
	super._render()
	_render_readable_hud()
	if _is_finished():
		impulse_button.hide()
		end_turn_button.disabled = false
		end_turn_button.text = "VER\nRESULTADO"
		if not _result_presented:
			_result_presented = true
			_show_result()
	else:
		end_turn_button.text = "FINALIZAR\nTURNO"

func _render_readable_hud() -> void:
	if _snapshot.is_empty():
		return
	var current := int(_snapshot.get("energy_current", 0))
	var capacity := int(_snapshot.get("energy_capacity", 0))
	energy_label.text = "%d/%d" % [current, capacity]
	_energy_pips.text = _energy_runes(current, capacity)
	_essence_caption.text = str(_snapshot.get("essence_name", "ESENCIA")).to_upper()
	essence_label.text = "%d/%d" % [int(_snapshot.get("essence_current", 0)), int(_snapshot.get("essence_max", 0))]
	seals_label.text = "%d/3" % Array(_snapshot.get("active_seals", [])).size()
	_relics_count.text = "RELIQUIAS %d/2" % Array(_snapshot.get("active_relics", [])).size()
	deck_label.text = str(int(_snapshot.get("draw_count", 0)))
	_discard_count.text = "DESCARTE %d" % Array(_snapshot.get("discard", [])).size()

func _show_result() -> void:
	_cancel_hand_gestures()
	card_detail.hide_detail()
	battle_menu.hide()
	result_screen.show_result(_snapshot)

func _on_rematch_requested() -> void:
	if session == null or not _is_finished():
		return
	_snapshot = session.restart_vs_cpu()
	selected_hand_index = -1
	card_detail.hide_detail()
	battle_menu.hide()
	_hand_scroll.scroll_horizontal = 0
	_reset_result_navigation()
	_render()

func _on_end_turn_pressed() -> void:
	if _is_finished():
		_show_result()
		return
	super._on_end_turn_pressed()

func _on_hand_card_pressed(index: int) -> void:
	if _is_finished():
		_inspect_hand_card(index)
		return
	super._on_hand_card_pressed(index)

func _on_impulse_pressed() -> void:
	if not _is_finished():
		super._on_impulse_pressed()

func _build_battle_menu() -> void:
	battle_menu = Control.new()
	battle_menu.name = "BattleMenu"
	battle_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(battle_menu)
	var shade := Button.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.focus_mode = Control.FOCUS_NONE
	var shade_style := StyleBoxFlat.new()
	shade_style.bg_color = Color(0.005, 0.008, 0.004, 0.88)
	for state in ["normal", "hover", "pressed", "focus"]:
		shade.add_theme_stylebox_override(state, shade_style)
	shade.pressed.connect(battle_menu.hide)
	battle_menu.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battle_menu.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(550, 0)
	var frame := _ornate_style(Color("171109"), GOLD, 3, 8)
	frame.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", frame)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	panel.add_child(column)
	column.add_child(_label("MENÚ DE BATALLA", 30, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER))
	for choice in [["ResumeBattle", "CONTINUAR"], ["ReturnToMainMenu", "VOLVER AL MENÚ"]]:
		var button := Button.new()
		button.name = choice[0]
		button.text = choice[1]
		button.custom_minimum_size.y = 88
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 26)
		button.add_theme_color_override("font_color", PARCHMENT_F)
		button.add_theme_stylebox_override("normal", _ornate_style(Color("173b1f"), GOLD, 2, 6))
		button.add_theme_stylebox_override("pressed", _ornate_style(Color("104518"), PARCHMENT_F, 3, 6))
		if choice[0] == "ResumeBattle":
			button.pressed.connect(battle_menu.hide)
		else:
			button.pressed.connect(func():
				battle_menu.hide()
				exit_requested.emit()
			)
		column.add_child(button)
	battle_menu.hide()

func _open_battle_menu() -> void:
	if _is_finished():
		_show_result()
		return
	_cancel_hand_gestures()
	card_detail.hide_detail()
	battle_menu.show()
	battle_menu.move_to_front()

func handle_back() -> void:
	if card_detail.visible:
		card_detail.hide_detail()
	elif result_screen.visible:
		result_screen.hide()
	elif _is_finished():
		_show_result()
	elif battle_menu.visible:
		battle_menu.hide()
	else:
		_open_battle_menu()

func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
		handle_back()
		get_viewport().set_input_as_handled()

func _cancel_hand_gestures() -> void:
	for visual in hand_strip.get_children():
		visual.cancel_pointer_gesture()

func _inspect_hand_card(index: int) -> void:
	if session != null:
		card_detail.show_card(session.hand_card_definition(index))

func _on_lane_pressed(side: String, lane: int) -> void:
	if _is_finished():
		selected_hand_index = -1
	if selected_hand_index < 0 and session != null:
		var info: Dictionary = session.inspect_unit(side, lane)
		if not info.is_empty():
			var unit: Dictionary = info.get("unit", {})
			card_detail.show_card(info.get("card", {}), int(unit.get("attack", 0)), int(unit.get("hp", 0)), bool(unit.get("ready", true)))
			return
	super._on_lane_pressed(side, lane)

func _build_top_bar() -> Control:
	var scene := Control.new()
	scene.name = "ScenicHeader"
	scene.custom_minimum_size = Vector2(0, 128)

	var logo := Control.new()
	logo.name = "MockupLogo"
	logo.anchor_left = 0.015
	logo.anchor_top = 0.035
	logo.anchor_right = 0.365
	logo.anchor_bottom = 0.66
	scene.add_child(logo)
	var logo_art = OrnamentScript.new()
	logo_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	logo_art.configure(OrnamentScript.Mode.LOGO, ORANGE_F)
	logo.add_child(logo_art)
	var logo_text := _label("NEXO DE RUNAS", 28, Color("f4bd62"), HORIZONTAL_ALIGNMENT_CENTER)
	logo_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	logo_text.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	logo_text.add_theme_constant_override("shadow_offset_x", 2)
	logo_text.add_theme_constant_override("shadow_offset_y", 2)
	logo.add_child(logo_text)

	var gear_frame := PanelContainer.new()
	gear_frame.anchor_left = 0.845
	gear_frame.anchor_top = 0.04
	gear_frame.anchor_right = 0.995
	gear_frame.anchor_bottom = 0.98
	gear_frame.add_theme_stylebox_override("panel", _ornate_style(Color("120b07"), Color("d26c2e"), 4, 48))
	scene.add_child(gear_frame)
	var gear := Button.new()
	gear.name = "SettingsGear"
	gear.text = "⚙"
	gear.focus_mode = Control.FOCUS_NONE
	gear.add_theme_font_size_override("font_size", 38)
	gear.add_theme_color_override("font_color", Color("ff7b32"))
	for state_name in ["normal", "hover", "pressed", "focus"]:
		gear.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	gear_frame.add_child(gear)
	gear.pressed.connect(_open_battle_menu)

	var encounter := PanelContainer.new()
	encounter.anchor_left = 0.405
	encounter.anchor_top = 0.72
	encounter.anchor_right = 0.595
	encounter.anchor_bottom = 0.98
	encounter.add_theme_stylebox_override("panel", _ornate_style(Color(0.02, 0.04, 0.02, 0.66), Color(0.43, 0.50, 0.25, 0.55), 1, 8))
	scene.add_child(encounter)
	encounter.add_child(_label("BATALLA DEL BOSQUE", 11, Color("cad79b"), HORIZONTAL_ALIGNMENT_CENTER))
	return scene

func _build_rival_header() -> Control:
	var wrapper := HBoxContainer.new()
	wrapper.name = "RivalHeaderWrapper"
	wrapper.custom_minimum_size = Vector2(0, 120)
	wrapper.add_theme_constant_override("separation", 4)

	var left := Control.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.65
	wrapper.add_child(left)

	var frame := PanelContainer.new()
	frame.name = "RivalPanel"
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_stretch_ratio = 4.0
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.025, 0.035, 0.022, 0.96), Color("b97b31"), 4, 8))
	wrapper.add_child(frame)

	var right := Control.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 0.65
	wrapper.add_child(right)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	frame.add_child(row)

	var crest_holder := Control.new()
	crest_holder.custom_minimum_size = Vector2(92, 104)
	var crest = OrnamentScript.new()
	crest.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crest.configure(OrnamentScript.Mode.RIVAL_CREST, GREEN_F)
	crest_holder.add_child(crest)
	row.add_child(crest_holder)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)
	rival_name_label = _label("GUARDABOSQUES DEL UMBRAL", 22, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	info.add_child(rival_name_label)
	info.add_child(_label("RIVAL CPU", 12, Color("d9ae70"), HORIZONTAL_ALIGNMENT_CENTER))

	rival_integrity_bar = ProgressBar.new()
	rival_integrity_bar.min_value = 0
	rival_integrity_bar.max_value = 20
	rival_integrity_bar.value = 20
	rival_integrity_bar.show_percentage = false
	rival_integrity_bar.custom_minimum_size = Vector2(0, 28)
	rival_integrity_bar.add_theme_stylebox_override("background", _style(Color("160807"), Color("5d2d22"), 2, 5))
	rival_integrity_bar.add_theme_stylebox_override("fill", _style(Color("b43628"), Color("f17649"), 2, 5))
	info.add_child(rival_integrity_bar)

	var life_frame := PanelContainer.new()
	life_frame.custom_minimum_size = Vector2(96, 98)
	life_frame.add_theme_stylebox_override("panel", _ornate_style(Color("5d1718"), Color("e6a13b"), 4, 14))
	rival_integrity_label = _label("20", 38, Color("fff0bd"), HORIZONTAL_ALIGNMENT_CENTER)
	life_frame.add_child(rival_integrity_label)
	row.add_child(life_frame)
	return wrapper

## Hand cards grow for readability; the compact five-lane board remains unchanged.
## Taller phones allocate some of their extra vertical area to the hand.
func _build_hand() -> Control:
	var frame := super._build_hand()
	frame.custom_minimum_size = Vector2(0, 300)
	return frame

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		call_deferred("_apply_legibility_layout")

func _apply_legibility_layout() -> void:
	if hand_strip == null or _hand_scroll == null:
		return
	var tall := get_viewport_rect().size.y >= 1740.0
	var frame := find_child("HandFrame", true, false) as Control
	var content := find_child("MockupComposition", true, false) as Control
	if frame != null:
		frame.custom_minimum_size = Vector2(0, 422 if tall else 300)
	if content != null:
		content.custom_minimum_size = Vector2(0, 1680 if tall else 1512)
	for item in hand_strip.get_children():
		var visual := item as Control
		if visual != null:
			visual.custom_minimum_size = Vector2(250, 370) if tall else FaithfulCardScript.HAND_CARD_SIZE

func _build_hud() -> Control:
	var strip := HBoxContainer.new()
	strip.name = "HudStrip"
	strip.custom_minimum_size = Vector2(0, 116)
	strip.add_theme_constant_override("separation", 4)

	energy_label = _label("1/1", 32, Color("b6ffa7"), HORIZONTAL_ALIGNMENT_CENTER)
	_energy_pips = _label("◆", 16, Color("92f58a"), HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_ENERGY, "ENERGÍA", energy_label, _energy_pips, Color("5be95d")))
	essence_label = _label("0/5", 32, Color("ffe19b"), HORIZONTAL_ALIGNMENT_CENTER)
	var essence_hint := _label("ESENCIA", 17, Color("f4bf55"), HORIZONTAL_ALIGNMENT_CENTER)
	var essence_panel := _hud_graphic(OrnamentScript.Mode.HUD_ESSENCE, "INSTINTO", essence_label, essence_hint, Color("ed9b32"))
	_essence_caption = essence_panel.find_child("HudCaption", true, false) as Label
	strip.add_child(essence_panel)
	seals_label = _label("0/3", 32, Color("e0f8ac"), HORIZONTAL_ALIGNMENT_CENTER)
	_relics_count = _label("RELIQUIAS 0/2", 18, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_SEALS, "SELLOS", seals_label, _relics_count, Color("9cba58")))
	deck_label = _label("16", 32, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	_discard_count = _label("DESCARTE 0", 18, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_DECK, "MAZO", deck_label, _discard_count, Color("b98748")))
	return strip

func _hud_graphic(mode_value, caption: String, value_label: Label, hint_label: Label, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _ornate_style(PANEL_DARK_F, Color(accent.r, accent.g, accent.b, 0.75), 2, 4))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 0)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var icon_holder := Control.new()
	icon_holder.custom_minimum_size = Vector2(28, 26)
	var icon = OrnamentScript.new()
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.configure(mode_value, accent)
	icon_holder.add_child(icon)
	row.add_child(icon_holder)
	var title := _label(caption, 19, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "HudCaption"
	row.add_child(title)
	column.add_child(value_label)
	column.add_child(hint_label)
	return panel

func _build_footer() -> Control:
	var footer := HBoxContainer.new()
	footer.name = "BattleFooter"
	footer.custom_minimum_size = Vector2(0, 160)
	footer.add_theme_constant_override("separation", 8)

	var nexus_holder := Control.new()
	nexus_holder.name = "PlayerNexus"
	nexus_holder.custom_minimum_size = Vector2(186, 150)
	var nexus_art = OrnamentScript.new()
	nexus_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nexus_art.configure(OrnamentScript.Mode.PLAYER_NEXUS, GREEN_F)
	nexus_holder.add_child(nexus_art)
	player_integrity_label = _label("20", 44, Color("fff2bb"), HORIZONTAL_ALIGNMENT_CENTER)
	player_integrity_label.anchor_left = 0.25
	player_integrity_label.anchor_top = 0.43
	player_integrity_label.anchor_right = 0.78
	player_integrity_label.anchor_bottom = 0.88
	nexus_holder.add_child(player_integrity_label)
	var player_tag := _label("TU NEXO", 18, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	player_tag.anchor_left = 0.15
	player_tag.anchor_top = 0.82
	player_tag.anchor_right = 0.85
	player_tag.anchor_bottom = 0.99
	nexus_holder.add_child(player_tag)
	footer.add_child(nexus_holder)

	var messages := VBoxContainer.new()
	messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	messages.add_theme_constant_override("separation", 2)
	status_label = _label("El Nexo aguarda tu jugada.", 22, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.max_lines_visible = 2
	status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	messages.add_child(status_label)
	event_label = _label("", 16, Color("c3d4a6"), HORIZONTAL_ALIGNMENT_CENTER)
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.max_lines_visible = 2
	event_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	messages.add_child(event_label)
	impulse_button = Button.new()
	impulse_button.name = "ImpulseButton"
	impulse_button.text = "+1 IMPULSO"
	impulse_button.custom_minimum_size = Vector2(110, 56)
	impulse_button.focus_mode = Control.FOCUS_NONE
	impulse_button.add_theme_font_size_override("font_size", 20)
	impulse_button.add_theme_stylebox_override("normal", _ornate_style(Color("173822"), Color("67a457"), 2, 8))
	impulse_button.add_theme_stylebox_override("pressed", _ornate_style(Color("102919"), Color("9eea7a"), 3, 8))
	impulse_button.pressed.connect(_on_impulse_pressed)
	messages.add_child(impulse_button)
	footer.add_child(messages)

	var turn_holder := Control.new()
	turn_holder.custom_minimum_size = Vector2(294, 148)
	var turn_frame = OrnamentScript.new()
	turn_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	turn_frame.configure(OrnamentScript.Mode.TURN_FRAME, GOLD)
	turn_holder.add_child(turn_frame)
	end_turn_button = Button.new()
	end_turn_button.name = "EndTurnButton"
	end_turn_button.text = "FINALIZAR\nTURNO"
	end_turn_button.anchor_left = 0.08
	end_turn_button.anchor_top = 0.12
	end_turn_button.anchor_right = 0.92
	end_turn_button.anchor_bottom = 0.88
	end_turn_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.add_theme_font_size_override("font_size", 27)
	end_turn_button.add_theme_color_override("font_color", Color("fff4b7"))
	end_turn_button.add_theme_stylebox_override("normal", _ornate_style(Color("176620"), Color("d6b047"), 3, 10))
	end_turn_button.add_theme_stylebox_override("pressed", _ornate_style(Color("104518"), Color("fff18b"), 4, 10))
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	turn_holder.add_child(end_turn_button)
	footer.add_child(turn_holder)
	return footer

func _rebuild_hand() -> void:
	var scroll_position := _hand_scroll.scroll_horizontal if _hand_scroll != null else 0
	for child in hand_strip.get_children():
		hand_strip.remove_child(child)
		child.queue_free()
	var hand: Array = _snapshot.get("hand", [])
	for index in range(hand.size()):
		var card: Dictionary = session.hand_card_definition(index)
		var visual = FaithfulCardScript.new()
		visual.name = "HandCard%d" % index
		visual.configure(card, -1, -1, index == selected_hand_index, false, true)
		var hand_index := index
		visual.inspection_requested.connect(func(): _inspect_hand_card(hand_index))
		visual.pressed.connect(func():
			if not visual.consume_inspection_press() and not card_detail.visible:
				_on_hand_card_pressed(hand_index)
		)
		hand_strip.add_child(visual)
	if _hand_scroll != null:
		_hand_scroll.set_deferred("scroll_horizontal", scroll_position)
	_apply_legibility_layout()

func _set_lane_state(button: Button, lane: int, side: String, unit, valid_target: bool) -> void:
	for child in button.get_children():
		button.remove_child(child)
		child.queue_free()
	button.text = ""
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	var occupied := unit != null
	var decor = FaithfulLaneScript.new()
	decor.name = "LaneDecor%d" % lane
	decor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	decor.configure(side, occupied, valid_target)
	button.add_child(decor)
	if occupied:
		var u: Dictionary = unit
		var card: Dictionary = session.card_definition(str(u.get("id", "")))
		if card.is_empty():
			card = u.duplicate(true)
		var visual = FaithfulCardScript.new()
		visual.name = "UnitCard%d" % lane
		visual.configure(card, int(u.get("attack", 0)), int(u.get("hp", 0)), false, true, bool(u.get("ready", true)))
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(visual)

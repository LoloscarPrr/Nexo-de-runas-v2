class_name VerticalBattleViewFaithful
extends "res://scripts/presentation/battle/vertical_battle_view_polished.gd"

## Segunda pasada visual: conserva el wiring de batalla y reemplaza únicamente
## Presentation para acercarla literalmente al mockup aprobado.

const FaithfulCardScript = preload("res://scripts/presentation/battle/vertical_battle_card_faithful.gd")
const OrnamentScript = preload("res://scripts/presentation/battle/vertical_battle_ornament.gd")
const FaithfulLaneScript = preload("res://scripts/presentation/battle/vertical_lane_slot.gd")

const PARCHMENT_F := Color("ead7a3")
const GREEN_F := Color("62df58")
const ORANGE_F := Color("ec762d")
const PANEL_DARK_F := Color(0.025, 0.022, 0.016, 0.92)

func _build_top_bar() -> Control:
	var scene := Control.new()
	scene.name = "ScenicHeader"
	scene.custom_minimum_size = Vector2(0, 178)

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
	gear_frame.anchor_left = 0.885
	gear_frame.anchor_top = 0.04
	gear_frame.anchor_right = 0.987
	gear_frame.anchor_bottom = 0.59
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
	wrapper.custom_minimum_size = Vector2(0, 138)
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

func _build_hud() -> Control:
	var strip := HBoxContainer.new()
	strip.name = "HudStrip"
	strip.custom_minimum_size = Vector2(0, 116)
	strip.add_theme_constant_override("separation", 4)

	energy_label = _label("ENERGÍA RÚNICA\n1/1", 14, Color("92f58a"), HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_ENERGY, energy_label, Color("5be95d"), 1.20))
	essence_label = _label("ESENCIA DEL DOMINIO\nINSTINTO", 14, Color("f4bf55"), HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_ESSENCE, essence_label, Color("ed9b32"), 1.10))
	seals_label = _label("SELLOS ACTIVOS\n○  ○  ○", 14, Color("cee78b"), HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_SEALS, seals_label, Color("9cba58"), 1.08))
	deck_label = _label("MAZO 16\nDESCARTE 0", 13, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	strip.add_child(_hud_graphic(OrnamentScript.Mode.HUD_DECK, deck_label, Color("b98748"), 0.84))
	return strip

func _hud_graphic(mode_value, value_label: Label, accent: Color, ratio: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = ratio
	panel.add_theme_stylebox_override("panel", _ornate_style(PANEL_DARK_F, Color(accent.r, accent.g, accent.b, 0.75), 2, 4))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)
	var icon_holder := Control.new()
	icon_holder.custom_minimum_size = Vector2(70, 0)
	var icon = OrnamentScript.new()
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.configure(mode_value, accent)
	icon_holder.add_child(icon)
	row.add_child(icon_holder)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)
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
	var player_tag := _label("JUGADOR 1", 11, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	player_tag.anchor_left = 0.15
	player_tag.anchor_top = 0.82
	player_tag.anchor_right = 0.85
	player_tag.anchor_bottom = 0.99
	nexus_holder.add_child(player_tag)
	footer.add_child(nexus_holder)

	var messages := VBoxContainer.new()
	messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label = _label("El Nexo aguarda tu jugada.", 13, PARCHMENT_F, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	messages.add_child(status_label)
	event_label = _label("", 10, Color("a6b887"), HORIZONTAL_ALIGNMENT_CENTER)
	messages.add_child(event_label)
	impulse_button = Button.new()
	impulse_button.name = "ImpulseButton"
	impulse_button.text = "+1 IMPULSO"
	impulse_button.custom_minimum_size = Vector2(110, 40)
	impulse_button.focus_mode = Control.FOCUS_NONE
	impulse_button.add_theme_font_size_override("font_size", 11)
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
		visual.pressed.connect(func(): _on_hand_card_pressed(hand_index))
		hand_strip.add_child(visual)

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

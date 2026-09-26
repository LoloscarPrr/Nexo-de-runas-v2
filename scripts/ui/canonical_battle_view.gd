class_name CanonicalBattleView
extends Control

signal exit_requested

const BattleScript = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const BackdropScript = preload("res://scripts/ui/canonical_forest_battle_backdrop.gd")

const BG_PANEL := Color(0.055, 0.065, 0.035, 0.94)
const WOOD := Color(0.13, 0.105, 0.055, 0.96)
const EDGE := Color(0.39, 0.49, 0.18, 0.92)
const GOLD := Color(0.80, 0.68, 0.32, 1.0)
const INK := Color(0.90, 0.89, 0.69, 1.0)
const MUTED := Color(0.62, 0.66, 0.45, 1.0)
const DANGER := Color(0.72, 0.22, 0.16, 1.0)
const SELECT := Color(0.62, 0.76, 0.28, 1.0)

var battle: CanonicalCpuBattle
var selected_hand_index := -1

var player_lane_buttons: Array[Button] = []
var enemy_lane_buttons: Array[Button] = []
var hand_box: HBoxContainer
var hand_scroll: ScrollContainer
var energy_label: Label
var essence_label: Label
var seals_label: Label
var relics_label: Label
var deck_button: Button
var discard_button: Button
var player_nexus: Label
var enemy_nexus: Label
var status_label: Label
var end_turn_button: Button
var result_overlay: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	start_battle()

func start_battle() -> void:
	battle = BattleScript.new()
	battle.setup_cpu_starter(Catalog.DOMAIN_FOREST)
	selected_hand_index = -1
	if result_overlay != null:
		result_overlay.visible = false
	_refresh()

func _build_ui() -> void:
	var backdrop := BackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var vignette := ColorRect.new()
	vignette.color = Color(0.0, 0.0, 0.0, 0.18)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	var exit := _button("VOLVER", 15)
	exit.pressed.connect(func(): emit_signal("exit_requested"))
	_place(exit, Rect2(24, 20, 112, 44))

	var title := _label("BOSQUE SALVAJE", 26, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_place(title, Rect2(430, 18, 420, 42))
	var subtitle := _label("BATALLA DEL NEXO · 4 CARRILES", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(subtitle, Rect2(430, 55, 420, 24))

	var enemy_panel := _panel(BG_PANEL, EDGE, 2, 12)
	_place(enemy_panel, Rect2(28, 82, 218, 98))
	var enemy_name := _label("GUARDIÁN DEL BOSQUE", 14, INK, HORIZONTAL_ALIGNMENT_CENTER)
	enemy_panel.add_child(enemy_name)
	enemy_name.position = Vector2(8, 8)
	enemy_name.size = Vector2(202, 28)
	enemy_nexus = _label("NEXO 20", 24, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	enemy_panel.add_child(enemy_nexus)
	enemy_nexus.position = Vector2(8, 40)
	enemy_nexus.size = Vector2(202, 44)

	var board_panel := _panel(Color(0.07, 0.075, 0.037, 0.76), Color(0.31, 0.39, 0.15, 0.78), 2, 18)
	_place(board_panel, Rect2(264, 88, 746, 366))

	for lane in range(4):
		var x := 282.0 + float(lane) * 178.0
		var enemy_button := _lane_button()
		enemy_button.disabled = true
		enemy_lane_buttons.append(enemy_button)
		_place(enemy_button, Rect2(x, 112, 158, 132))

		var player_button := _lane_button()
		var lane_index := lane
		player_button.pressed.connect(func(): _on_player_lane_pressed(lane_index))
		player_lane_buttons.append(player_button)
		_place(player_button, Rect2(x, 292, 158, 142))

	var center_hint := _label("✦   ✦   ✦   ✦", 18, Color(0.61, 0.72, 0.29, 0.48), HORIZONTAL_ALIGNMENT_CENTER)
	_place(center_hint, Rect2(360, 252, 550, 32))

	var nexus_panel := _panel(BG_PANEL, EDGE, 2, 14)
	_place(nexus_panel, Rect2(38, 272, 194, 162))
	var nexus_title := _label("TU NEXO", 12, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	nexus_panel.add_child(nexus_title)
	nexus_title.position = Vector2(10, 12)
	nexus_title.size = Vector2(174, 24)
	player_nexus = _label("20", 54, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	nexus_panel.add_child(player_nexus)
	player_nexus.position = Vector2(10, 39)
	player_nexus.size = Vector2(174, 74)
	var nexus_caption := _label("INTEGRIDAD", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	nexus_panel.add_child(nexus_caption)
	nexus_caption.position = Vector2(10, 116)
	nexus_caption.size = Vector2(174, 26)

	var hud := _panel(BG_PANEL, EDGE, 2, 14)
	_place(hud, Rect2(30, 474, 218, 210))
	energy_label = _label("", 15, INK, HORIZONTAL_ALIGNMENT_LEFT)
	essence_label = _label("", 15, INK, HORIZONTAL_ALIGNMENT_LEFT)
	seals_label = _label("", 13, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	relics_label = _label("", 13, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	for data in [[energy_label, 14.0], [essence_label, 53.0], [seals_label, 96.0], [relics_label, 130.0]]:
		hud.add_child(data[0])
		data[0].position = Vector2(14, data[1])
		data[0].size = Vector2(190, 31)
	status_label = _label("", 10, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud.add_child(status_label)
	status_label.position = Vector2(14, 164)
	status_label.size = Vector2(190, 38)

	hand_scroll = ScrollContainer.new()
	hand_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hand_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hand_scroll.clip_contents = true
	_place(hand_scroll, Rect2(266, 478, 720, 206))
	hand_box = HBoxContainer.new()
	hand_box.add_theme_constant_override("separation", 10)
	hand_scroll.add_child(hand_box)

	var support := _panel(BG_PANEL, EDGE, 2, 14)
	_place(support, Rect2(1018, 300, 232, 384))
	var support_title := _label("RECURSOS", 12, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	support.add_child(support_title)
	support_title.position = Vector2(10, 10)
	support_title.size = Vector2(212, 24)

	deck_button = _button("MAZO\n0", 15)
	deck_button.pressed.connect(_show_deck_info)
	support.add_child(deck_button)
	deck_button.position = Vector2(12, 44)
	deck_button.size = Vector2(98, 70)
	discard_button = _button("DESCARTE\n0", 15)
	discard_button.pressed.connect(_show_discard_info)
	support.add_child(discard_button)
	discard_button.position = Vector2(122, 44)
	discard_button.size = Vector2(98, 70)

	var seals_caption := _label("SELLOS ACTIVOS", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	support.add_child(seals_caption)
	seals_caption.position = Vector2(10, 130)
	seals_caption.size = Vector2(212, 24)
	var relic_caption := _label("RELIQUIAS ACTIVAS", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	support.add_child(relic_caption)
	relic_caption.position = Vector2(10, 184)
	relic_caption.size = Vector2(212, 24)

	end_turn_button = _button("FINALIZAR TURNO", 17)
	end_turn_button.add_theme_color_override("font_color", Color(0.98, 0.91, 0.63, 1.0))
	end_turn_button.add_theme_stylebox_override("normal", _style(Color(0.23, 0.14, 0.055, 0.98), Color(0.71, 0.50, 0.17, 1.0), 3, 10))
	end_turn_button.add_theme_stylebox_override("pressed", _style(Color(0.36, 0.11, 0.055, 1.0), DANGER, 3, 10))
	end_turn_button.pressed.connect(_on_end_turn)
	support.add_child(end_turn_button)
	end_turn_button.position = Vector2(12, 286)
	end_turn_button.size = Vector2(208, 78)

	result_overlay = _build_result_overlay()
	result_overlay.visible = false
	add_child(result_overlay)

func _refresh() -> void:
	if battle == null:
		return
	player_nexus.text = str(battle.player_integrity)
	enemy_nexus.text = "NEXO %d" % battle.enemy_integrity
	var energy_denominator := 12 if battle.energy_current > 6 else 6
	energy_label.text = "ENERGÍA RÚNICA   %d/%d" % [battle.energy_current, energy_denominator]
	essence_label.text = "%s   %d/%d" % [battle.essence_name().to_upper(), battle.essence_current, battle.essence_max()]
	seals_label.text = "SELLOS   %d/3" % battle.active_seals.size()
	relics_label.text = "RELIQUIAS   %d/2" % battle.active_relics.size()
	deck_button.text = "MAZO\n%d" % battle.draw_pile.size()
	discard_button.text = "DESCARTE\n%d" % battle.discard_pile.size()
	status_label.text = battle.last_message if not battle.last_message.is_empty() else "Selecciona una carta y luego un carril."

	for lane in range(4):
		_refresh_lane(player_lane_buttons[lane], battle.player_lanes[lane], lane, true)
		_refresh_lane(enemy_lane_buttons[lane], battle.enemy_lanes[lane], lane, false)
	_rebuild_hand()
	if battle.result != "ongoing":
		_show_result()

func _refresh_lane(button: Button, unit, lane: int, player_side: bool) -> void:
	if unit == null:
		button.text = "CARRIL %d\nVACÍO" % (lane + 1)
		button.add_theme_color_override("font_color", MUTED)
		button.add_theme_stylebox_override("normal", _style(Color(0.06, 0.08, 0.035, 0.74), Color(0.27, 0.34, 0.13, 0.76), 2, 10))
		button.add_theme_stylebox_override("disabled", _style(Color(0.06, 0.08, 0.035, 0.74), Color(0.27, 0.34, 0.13, 0.76), 2, 10))
		return
	var ready_text := "" if bool(unit.get("ready", false)) else " · EN ESPERA"
	button.text = "%s\nATQ %d   SAL %d%s" % [str(unit.get("name", "UNIDAD")), int(unit.get("attack", 0)), int(unit.get("hp", 0)), ready_text]
	button.add_theme_color_override("font_color", INK)
	var border := SELECT if player_side else Color(0.52, 0.28, 0.16, 0.95)
	var st := _style(Color(0.12, 0.12, 0.055, 0.93), border, 2, 10)
	button.add_theme_stylebox_override("normal", st)
	button.add_theme_stylebox_override("disabled", st)

func _rebuild_hand() -> void:
	for child in hand_box.get_children():
		child.queue_free()
	for i in range(battle.hand.size()):
		var card := Catalog.find_by_id(battle.hand[i])
		var card_button := _card_button(card, i == selected_hand_index)
		var index := i
		card_button.pressed.connect(func(): _on_hand_card_pressed(index))
		hand_box.add_child(card_button)

func _card_button(card: Dictionary, selected: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(138, 188)
	button.focus_mode = Control.FOCUS_NONE
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 12)
	var type_name := str(card.get("type", "")).to_upper()
	var stats := ""
	if str(card.get("type", "")) == Catalog.TYPE_CREATURE:
		stats = "\nATQ %d   SAL %d" % [int(card.get("attack", 0)), int(card.get("health", 0))]
	var keyword_text := ""
	var keywords: Array = card.get("keywords", [])
	if not keywords.is_empty():
		keyword_text = "\n" + str(keywords[0]).replace("_", " ")
	button.text = "%s\nCOSTE %d · %s%s%s" % [str(card.get("name", "CARTA")), int(card.get("cost", 0)), type_name, stats, keyword_text]
	var border := GOLD if selected else Color(0.34, 0.41, 0.17, 0.95)
	var bg := Color(0.15, 0.13, 0.065, 0.98) if selected else Color(0.105, 0.10, 0.052, 0.98)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _style(bg, border, 3 if selected else 2, 9))
	button.add_theme_stylebox_override("hover", _style(Color(0.18, 0.16, 0.07, 1.0), GOLD, 3, 9))
	button.add_theme_stylebox_override("pressed", _style(Color(0.20, 0.12, 0.055, 1.0), SELECT, 3, 9))
	return button

func _on_hand_card_pressed(index: int) -> void:
	if index < 0 or index >= battle.hand.size():
		return
	var card := Catalog.find_by_id(battle.hand[index])
	var card_type := str(card.get("type", ""))
	if card_type == Catalog.TYPE_RELIC or card_type == Catalog.TYPE_SEAL:
		if battle.play_card(index):
			selected_hand_index = -1
		else:
			selected_hand_index = index
		_refresh()
		return
	if card_type == Catalog.TYPE_RITE and ["llamado_de_la_manada", "vision_prohibida"].has(str(card.get("id", ""))):
		battle.play_card(index)
		selected_hand_index = -1
		_refresh()
		return
	selected_hand_index = -1 if selected_hand_index == index else index
	battle.last_message = "Carta seleccionada: %s" % str(card.get("name", ""))
	_refresh()

func _on_player_lane_pressed(lane: int) -> void:
	if selected_hand_index < 0 or selected_hand_index >= battle.hand.size():
		battle.last_message = "Primero selecciona una carta de tu mano."
		_refresh()
		return
	var card := Catalog.find_by_id(battle.hand[selected_hand_index])
	var card_type := str(card.get("type", ""))
	var success := false
	if card_type == Catalog.TYPE_CREATURE:
		success = battle.play_card(selected_hand_index, lane)
	elif card_type == Catalog.TYPE_RITE:
		success = battle.play_card(selected_hand_index, -1, lane)
	if success:
		selected_hand_index = -1
		battle.last_message = "La runa acepta tu jugada."
	_refresh()

func _on_end_turn() -> void:
	if battle.result != "ongoing":
		return
	selected_hand_index = -1
	var before_player := battle.player_integrity
	var before_enemy := battle.enemy_integrity
	battle.advance_round()
	if battle.result == "ongoing":
		var delta_player := before_player - battle.player_integrity
		var delta_enemy := before_enemy - battle.enemy_integrity
		if delta_player > 0:
			battle.last_message = "El Nexo recibió %d de daño. Turno %d." % [delta_player, battle.turn]
		elif delta_enemy > 0:
			battle.last_message = "El rival perdió %d de Integridad. Turno %d." % [delta_enemy, battle.turn]
		else:
			battle.last_message = "Turno %d · Energía restaurada." % battle.turn
	_refresh()

func _show_deck_info() -> void:
	battle.last_message = "Mazo: %d cartas restantes. El orden permanece oculto." % battle.draw_pile.size()
	_refresh()

func _show_discard_info() -> void:
	if battle.discard_pile.is_empty():
		battle.last_message = "El Descarte está vacío."
	else:
		var names: Array[String] = []
		for card_id in battle.discard_pile:
			var card := Catalog.find_by_id(card_id)
			names.append(str(card.get("name", card_id)))
		battle.last_message = "Descarte: " + ", ".join(names)
	_refresh()

func _show_result() -> void:
	result_overlay.visible = true
	var title: Label = result_overlay.get_node("Card/Title")
	var detail: Label = result_overlay.get_node("Card/Detail")
	if battle.result == "victory":
		title.text = "VICTORIA"
		detail.text = "El Nexo rival ha cedido ante el Bosque Salvaje."
	else:
		title.text = "DERROTA"
		detail.text = "Tu Nexo se ha quebrado. La senda vuelve a comenzar."

func _build_result_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var card := _panel(Color(0.08, 0.075, 0.035, 0.98), GOLD, 3, 16)
	card.name = "Card"
	overlay.add_child(card)
	card.position = Vector2(360, 210)
	card.size = Vector2(560, 300)
	var title := _label("VICTORIA", 38, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	card.add_child(title)
	title.position = Vector2(20, 34)
	title.size = Vector2(520, 60)
	var detail := _label("", 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	detail.name = "Detail"
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(detail)
	detail.position = Vector2(50, 104)
	detail.size = Vector2(460, 70)
	var retry := _button("REINICIAR", 16)
	retry.pressed.connect(start_battle)
	card.add_child(retry)
	retry.position = Vector2(70, 208)
	retry.size = Vector2(190, 58)
	var leave := _button("VOLVER AL MENÚ", 16)
	leave.pressed.connect(func(): emit_signal("exit_requested"))
	card.add_child(leave)
	leave.position = Vector2(300, 208)
	leave.size = Vector2(190, 58)
	return overlay

func _lane_button() -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", INK)
	button.add_theme_stylebox_override("normal", _style(Color(0.06, 0.08, 0.035, 0.74), Color(0.27, 0.34, 0.13, 0.76), 2, 10))
	button.add_theme_stylebox_override("hover", _style(Color(0.11, 0.13, 0.05, 0.90), SELECT, 3, 10))
	button.add_theme_stylebox_override("pressed", _style(Color(0.15, 0.12, 0.05, 0.98), GOLD, 3, 10))
	button.add_theme_stylebox_override("disabled", _style(Color(0.06, 0.08, 0.035, 0.74), Color(0.27, 0.34, 0.13, 0.76), 2, 10))
	return button

func _button(text_value: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _style(BG_PANEL, EDGE, 2, 8))
	button.add_theme_stylebox_override("hover", _style(Color(0.11, 0.13, 0.05, 0.98), GOLD, 2, 8))
	button.add_theme_stylebox_override("pressed", _style(Color(0.19, 0.11, 0.05, 1.0), SELECT, 3, 8))
	return button

func _panel(color: Color, border: Color, width: int, radius: int) -> Panel:
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", _style(color, border, width, radius))
	return panel

func _label(text_value: String, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _place(control: Control, rect: Rect2) -> void:
	add_child(control)
	control.position = rect.position
	control.size = rect.size
	control.set_deferred("size", rect.size)

func _style(color: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

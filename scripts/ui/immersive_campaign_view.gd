extends "res://scripts/ui/campaign_view.gd"

const ImmersiveTableScript = preload("res://scripts/ui/battle_table.gd")
const ImmersiveCardScript = preload("res://scripts/ui/battle_card.gd")
const ImmersiveCatalogScript = preload("res://scripts/domain/card_catalog.gd")
const CampaignBackdropScript = preload("res://scripts/ui/campaign_backdrop.gd")

const I_INK := Color8(199, 213, 103)
const I_MUTED := Color8(113, 125, 67)
const I_AMBER := Color8(198, 218, 88)
const I_BONE := Color8(184, 187, 111)
const I_EDGE := Color8(76, 89, 40)
const I_WOOD := Color8(18, 25, 13)
const I_PAPER := Color8(118, 119, 65)
const I_SUCCESS := Color8(168, 187, 83)
const MOCK_GLOW := Color8(198, 218, 88)
const MOCK_INK := Color8(199, 205, 116)
const MOCK_MUTED := Color8(119, 128, 68)
const MOCK_PANEL := Color8(18, 24, 13)
const MOCK_EDGE := Color8(78, 91, 39)
const MOCK_PAPER := Color8(171, 166, 92)

func _render_battle() -> void:
	_clear_screen()
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1.0)
	var vh := maxf(viewport_size.y, 1.0)
	var s := minf(vw / 1536.0, vh / 864.0)
	var ox := (vw - 1536.0 * s) * 0.5
	var oy := (vh - 864.0 * s) * 0.5

	var table := ImmersiveTableScript.new()
	table.balance = battle_state.scale
	table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(table)

	# Encabezado idéntico al lenguaje del mockup: título pequeño sobre el tablero.
	_place(_label("NEXO DE RUNAS", maxi(14, int(23 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(24, 12, 205, 36, s, ox, oy))
	var leave := _small_button("MAPA", int(82 * s))
	leave.pressed.connect(_show_map)
	_mock_button_style(leave, false)
	_place(leave, _mock_rect(214, 12, 82, 32, s, ox, oy))

	# Valores de la balanza bajo los platos.
	var left_weight := 2 + maxi(battle_state.scale, 0)
	var right_weight := 2 + maxi(-battle_state.scale, 0)
	_place(_label(str(left_weight), maxi(15, int(28 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(29, 183, 48, 42, s, ox, oy))
	_place(_label(str(right_weight), maxi(15, int(28 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(142, 183, 48, 42, s, ox, oy))

	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_ready: int = battle_state.blood_value_for_sacrifices(selected_sacrifices)
	var blood_text := "SANGRE  %d/%d" % [blood_ready, blood_cost] if blood_cost > 0 else "HUESOS  %d" % battle_state.bones
	_place(_label(blood_text, maxi(12, int(20 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(28, 536, 170, 36, s, ox, oy))
	_place(_label("◆  ◆  ◆", maxi(13, int(22 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(38, 576, 150, 34, s, ox, oy))

	# Libro de reglas contextual: en móvil el sello debe entenderse sin hover.
	var inspect_data: Dictionary = {}
	if selected_hand_index >= 0 and selected_hand_index < battle_state.hand.size():
		inspect_data = battle_state.card_for_id(battle_state.hand[selected_hand_index])
	elif not inspected_card_id.is_empty():
		inspect_data = battle_state.card_for_id(inspected_card_id)
	if not inspect_data.is_empty():
		_place(_label("SELLOS · %s" % str(inspect_data.get("name", "CARTA")), maxi(10, int(13 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(1312, 184, 210, 28, s, ox, oy))
		_place(_label(SigilCatalogScript.summary_for_card(inspect_data), maxi(8, int(10 * s)), MOCK_INK, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(1312, 216, 210, 190, s, ox, oy))
	else:
		_place(_label("TOCA UNA CARTA\nPARA LEER\nSU SELLO.", maxi(11, int(17 * s)), MOCK_INK, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(1330, 220, 170, 100, s, ox, oy))
	var turn_text := "ROBA CARTA" if battle_state.needs_draw() else "TU TURNO"
	_place(_label(turn_text, maxi(13, int(22 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(1338, 416, 154, 34, s, ox, oy))

	# Cuatro cartas del rival y cuatro del jugador, alineadas como la captura.
	var lane_x0 := 350.0
	var lane_pitch := 220.0
	var card_w := 198.0
	var card_h := 246.0
	for lane in range(4):
		var x := lane_x0 + float(lane) * lane_pitch
		var enemy = battle_state.enemy_lanes[lane]
		var enemy_slot := _immersive_slot(enemy, false, lane)
		if enemy != null:
			enemy_slot.pressed.connect(_inspect_enemy_lane.bind(lane))
		_place(enemy_slot, _mock_rect(x, 58, card_w, card_h, s, ox, oy))
		var player = battle_state.player_lanes[lane]
		var player_slot := _immersive_slot(player, true, lane)
		player_slot.pressed.connect(_on_player_lane_pressed.bind(lane))
		_place(player_slot, _mock_rect(x, 334, card_w, card_h, s, ox, oy))

	# Estado discreto sobre la mano, sin convertirlo en un HUD separado.
	_place(_label(battle_state.last_message, maxi(10, int(13 * s)), MOCK_MUTED, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(300, 603, 900, 27, s, ox, oy))

	# Mano física/abanicada. Sin ScrollContainer ni fila plana.
	var hand_count: int = battle_state.hand.size()
	if hand_count > 0:
		var hand_w := 170.0
		var hand_h := 210.0
		var step := 150.0
		if hand_count > 7:
			step = 900.0 / float(hand_count - 1)
		var total_w := hand_w + step * float(maxi(hand_count - 1, 0))
		var start_x := 768.0 - total_w * 0.5
		for index in range(hand_count):
			var card := ImmersiveCardScript.new()
			card.card = battle_state.card_for_id(battle_state.hand[index])
			card.chosen = index == selected_hand_index
			card.disabled = battle_state.needs_draw()
			card.pressed.connect(_select_hand.bind(index))
			var y := 645.0
			if index == selected_hand_index:
				y -= 16.0
			_place(card, _mock_rect(start_x + float(index) * step, y, hand_w, hand_h, s, ox, oy))
			card.rotation = 0.0
	else:
		_place(_label("TU MANO ESTÁ VACÍA", maxi(12, int(18 * s)), MOCK_MUTED, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(570, 735, 400, 32, s, ox, oy))

	# Pilas de mazo en las esquinas inferiores. Son los propios objetivos táctiles.
	var draw_deck := _small_button("MAZO\n%d" % battle_state.draw_pile.size(), int(104 * s))
	draw_deck.disabled = not battle_state.needs_draw() or battle_state.draw_pile.is_empty()
	draw_deck.pressed.connect(_draw_regular)
	_mock_button_style(draw_deck, true)
	_place(draw_deck, _mock_rect(28, 696, 112, 128, s, ox, oy))

	var squirrels := _small_button("ARDILLAS\n%d" % battle_state.squirrel_pile_count, int(104 * s))
	squirrels.disabled = not battle_state.needs_draw() or battle_state.squirrel_pile_count <= 0
	squirrels.pressed.connect(_draw_squirrel)
	_mock_button_style(squirrels, true)
	_place(squirrels, _mock_rect(1396, 696, 112, 128, s, ox, oy))

	# Columna derecha: finalizar como botón grande de papel.
	var bell := _small_button("FINALIZAR", int(170 * s))
	bell.disabled = battle_state.needs_draw()
	bell.pressed.connect(_end_battle_turn)
	_mock_button_style(bell, false, true)
	_place(bell, _mock_rect(1330, 492, 170, 96, s, ox, oy))

	if not selected_sacrifices.is_empty():
		var cancel := _small_button("CANCELAR", int(160 * s))
		cancel.pressed.connect(_cancel_sacrifices)
		_mock_button_style(cancel, false)
		_place(cancel, _mock_rect(31, 618, 160, 46, s, ox, oy))

func _mock_rect(x: float, y: float, w: float, h: float, s: float, ox: float, oy: float) -> Rect2:
	return Rect2(ox + x * s, oy + y * s, w * s, h * s)

func _mock_button_style(button: Button, deck_style := false, paper_style := false) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16 if not deck_style else 13)
	button.add_theme_color_override("font_color", Color("c7d669") if not paper_style else Color("0a0d07"))
	button.add_theme_color_override("font_disabled_color", Color("59612f"))
	if paper_style:
		button.add_theme_stylebox_override("normal", _panel_style(Color("aaa65c"), Color("11170d"), 3, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("c4bd70"), Color("c8d95b"), 4, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color("575832"), Color("30391d"), 2, 1))
	elif deck_style:
		button.add_theme_stylebox_override("normal", _panel_style(Color("11170d"), Color("697337"), 3, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("242e18"), Color("c8d95b"), 4, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.04, 0.055, 0.03, 0.65), Color("30391d"), 2, 1))
	else:
		button.add_theme_stylebox_override("normal", _panel_style(Color("0b1008"), Color("667035"), 2, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("1a2412"), Color("c8d95b"), 3, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color("090d07"), Color("30391d"), 2, 1))

func _show_map() -> void:
	if state == null:
		open_launcher()
		return
	_clear_screen()
	_add_campaign_backdrop("map")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	var back := _small_button("‹ MENÚ", 116)
	back.pressed.connect(_exit_to_menu)
	_place(back, Rect2(28, 18, 116, 40))
	_place(_label("EL MAPA SOBRE LA MESA", 24, I_INK, HORIZONTAL_ALIGNMENT_LEFT), Rect2(170, 18, 470, 36))
	_place(_label("MAZO %d  ·  VICTORIAS %d  ·  BENDICIÓN %d HUESOS" % [state.deck_ids.size(), state.victories, state.bone_boon], 12, I_AMBER, HORIZONTAL_ALIGNMENT_RIGHT), Rect2(vw - 470, 21, 440, 32))

	var second_segment: bool = bool(state.resolved_nodes.has("region_complete")) or state.current_node in [
		"region_complete", "sigil_stones", "mycologists", "trial_event", "battle_3", "boss_2", "region_2_complete"
	]
	var cx := vw * 0.5
	var branch_offset := minf(220.0, vw * 0.18)
	var y0 := 120.0
	var pitch := 74.0
	var node_h := 44.0
	var branch_w := 220.0
	var center_w := 250.0

	if second_segment:
		_place(_label("SEGUNDO TRAMO · EL BOSQUE CAMBIA", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.28, 63, vw * 0.44, 26))
		_place(_physical_map_node("region_complete", "ENTRADA AL SEGUNDO TRAMO"), Rect2(cx - center_w * 0.5, y0, center_w, node_h))
		_place(_physical_map_node("sigil_stones", "PIEDRAS MISTERIOSAS"), Rect2(cx - branch_offset - branch_w * 0.5, y0 + pitch, branch_w, node_h))
		_place(_physical_map_node("mycologists", "MICÓLOGOS"), Rect2(cx + branch_offset - branch_w * 0.5, y0 + pitch, branch_w, node_h))
		_place(_physical_map_node("trial_event", "PRUEBA DEL MAZO"), Rect2(cx - center_w * 0.5, y0 + pitch * 2.0, center_w, node_h))
		_place(_physical_map_node("battle_3", "COMBATE DE LA ARBOLEDA"), Rect2(cx - center_w * 0.5, y0 + pitch * 3.0, center_w, node_h))
		_place(_physical_map_node("boss_2", "EL TRAMPERO"), Rect2(cx - center_w * 0.5, y0 + pitch * 4.0, center_w, node_h))
		_place(_physical_map_node("region_2_complete", "TERCER TRAMO"), Rect2(cx - center_w * 0.5, y0 + pitch * 5.0, center_w, node_h))
	else:
		_place(_label("PRIMER TRAMO · BOSQUE", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.28, 63, vw * 0.44, 26))
		var p := 48.0
		_place(_physical_map_node("start", "LA SENDA"), Rect2(cx - center_w * 0.5, 98, center_w, 34))
		_place(_physical_map_node("choice_left", "ELEGIR BESTIA"), Rect2(cx - branch_offset - branch_w * 0.5, 98 + p, branch_w, 34))
		_place(_physical_map_node("choice_right", "ELEGIR COSTE"), Rect2(cx + branch_offset - branch_w * 0.5, 98 + p, branch_w, 34))
		_place(_physical_map_node("battle_1", "COMBATE DEL BOSQUE"), Rect2(cx - center_w * 0.5, 98 + p * 2.0, center_w, 34))
		_place(_physical_map_node("campfire_1", "FOGATA I"), Rect2(cx - center_w * 0.5, 98 + p * 3.0, center_w, 34))
		_place(_physical_map_node("gate_1", "UMBRAL DEL BOSQUE"), Rect2(cx - center_w * 0.5, 98 + p * 4.0, center_w, 34))
		_place(_physical_map_node("choice_2_left", "RASTRO DE BESTIA"), Rect2(cx - branch_offset - branch_w * 0.5, 98 + p * 5.0, branch_w, 34))
		_place(_physical_map_node("choice_2_right", "RASTRO DE SANGRE"), Rect2(cx + branch_offset - branch_w * 0.5, 98 + p * 5.0, branch_w, 34))
		_place(_physical_map_node("prospector_event", "TRES ROCAS"), Rect2(cx - branch_offset - branch_w * 0.5, 98 + p * 6.0, branch_w, 34))
		_place(_physical_map_node("bone_altar", "ALTAR DE HUESOS"), Rect2(cx + branch_offset - branch_w * 0.5, 98 + p * 6.0, branch_w, 34))
		_place(_physical_map_node("battle_2", "COMBATE PROFUNDO"), Rect2(cx - center_w * 0.5, 98 + p * 7.0, center_w, 34))
		_place(_physical_map_node("campfire_2", "FOGATA II"), Rect2(cx - center_w * 0.5, 98 + p * 8.0, center_w, 34))
		_place(_physical_map_node("boss_1", "GUARDIÁN DEL BOSQUE"), Rect2(cx - center_w * 0.5, 98 + p * 9.0, center_w, 34))
		_place(_physical_map_node("region_complete", "SEGUNDO TRAMO"), Rect2(cx - center_w * 0.5, 98 + p * 10.0, center_w, 34))

	var current: Dictionary = state.get_node(state.current_node)
	_place(_label("TU FIGURA ESTÁ EN: %s" % str(current.get("title", state.current_node)), 11, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, vh - 28, vw * 0.46, 22))

func _show_choice(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("choice")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("TRES CARTAS ESPERAN", 30, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 38, vw * 0.5, 42))
	_place(_label("Toma una. Las otras vuelven a la oscuridad.", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 78, vw * 0.5, 30))
	var ids: Array[String] = _reward_choices("choice:%s" % node_id, 3)
	var card_w := 190.0
	var card_h := 260.0
	var gap := minf(90.0, vw * 0.05)
	var total := card_w * 3.0 + gap * 2.0
	var left := (vw - total) * 0.5
	for index in range(ids.size()):
		var card_id := ids[index]
		var view := _choice_card_button(card_id, _claim_choice.bind(node_id, card_id))
		var card_x := left + float(index) * (card_w + gap)
		_place(view, Rect2(card_x, vh * 0.25, card_w, card_h))
		var info: Dictionary = ImmersiveCatalogScript.find_by_id(card_id)
		_place(_label(SigilCatalogScript.summary_for_card(info), 10, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(card_x - 12, vh * 0.25 + card_h + 10, card_w + 24, 105))
	var back := _small_button("VOLVER AL MAPA", 230)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw * 0.5 - 115, vh - 82, 230, 52))

func _show_prospector_event(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("choice")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("EL PROSPECTOR APOYA EL PICO EN LA MESA", 28, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.16, 38, vw * 0.68, 42))
	_place(_label("Elige una roca. Lo que haya dentro será tuyo.", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.23, 82, vw * 0.54, 30))

	var rock_w := 220.0
	var gap := 80.0
	var total := rock_w * 3.0 + gap * 2.0
	var left := (vw - total) * 0.5
	for index in range(3):
		var rock := _small_button("ROCA %d\nGOLPEAR" % (index + 1), int(rock_w))
		rock.add_theme_font_size_override("font_size", 19)
		rock.pressed.connect(_pick_prospector_boulder.bind(node_id, index))
		rock.add_theme_stylebox_override("normal", _panel_style(Color("14170d"), I_EDGE, 3, 4))
		rock.add_theme_stylebox_override("pressed", _panel_style(Color("2a2b18"), I_AMBER, 4, 4))
		_place(rock, Rect2(left + float(index) * (rock_w + gap), vh * 0.30, rock_w, 210))

	var back := _small_button("VOLVER AL MAPA", 230)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw * 0.5 - 115, vh - 72, 230, 44))

func _show_event_reward(title_text: String, card_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("reward")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label(title_text, 31, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 35, vw * 0.50, 44))
	var data: Dictionary = _campaign_card(card_id)
	var card := ImmersiveCardScript.new()
	card.card = data
	card.disabled = true
	_place(card, Rect2(vw * 0.5 - 95, 125, 190, 260))
	_place(_label(SigilCatalogScript.summary_for_card(data), 13, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, 405, vw * 0.46, 90))
	var continue_button := _small_button("GUARDAR Y CONTINUAR", 300)
	continue_button.pressed.connect(_show_map)
	_place(continue_button, Rect2(vw * 0.5 - 150, vh - 82, 300, 50))

func _show_bone_altar(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("gate")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("EL ALTAR DEL SEÑOR DE LOS HUESOS", 29, I_BONE, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.18, 28, vw * 0.64, 42))
	_place(_label("Una ofrenda común concede 1 Hueso inicial. La Cabra Negra concede 8.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.20, 70, vw * 0.60, 30))

	if not selected_event_card_id.is_empty():
		var selected_data: Dictionary = _campaign_card(selected_event_card_id)
		var selected_card := ImmersiveCardScript.new()
		selected_card.card = selected_data
		selected_card.chosen = true
		selected_card.disabled = true
		_place(selected_card, Rect2(vw * 0.5 - 82, 110, 164, 224))
		_place(_label(SigilCatalogScript.summary_for_card(selected_data), 11, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.31, 342, vw * 0.38, 62))
		var offer := _small_button("OFRECER %s" % str(selected_data.get("name", "CARTA")), 330)
		offer.pressed.connect(_confirm_bone_altar.bind(node_id))
		offer.add_theme_stylebox_override("normal", _panel_style(Color("160d09"), Color("8a5d3b"), 3, 3))
		_place(offer, Rect2(vw * 0.5 - 165, 412, 330, 46))
	else:
		_place(_label("ELIGE QUÉ CARTA DESAPARECERÁ DEL MAZO", 13, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.30, 355, vw * 0.40, 28))

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(scroll, Rect2(90, 475, vw - 180, 170))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	scroll.add_child(row)
	for card_id in state.deck_ids:
		var card := ImmersiveCardScript.new()
		card.card = _campaign_card(card_id)
		card.chosen = card_id == selected_event_card_id
		card.custom_minimum_size = Vector2(116, 158)
		card.pressed.connect(_select_bone_altar_card.bind(node_id, card_id))
		row.add_child(card)

	var back := _small_button("VOLVER AL MAPA", 190)
	back.pressed.connect(_leave_special_event)
	_place(back, Rect2(vw - 215, vh - 48, 190, 36))

func _show_sigil_stones(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("gate")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("PIEDRAS MISTERIOSAS", 30, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.22, 26, vw * 0.56, 42))
	_place(_label("Una carta será destruida. Sus sellos pasarán a otra.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.24, 67, vw * 0.52, 28))

	if selected_event_card_id.is_empty():
		_place(_label("1 · ELIGE LA CARTA DONANTE", 14, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.30, 112, vw * 0.40, 28))
	else:
		var donor: Dictionary = _campaign_card(selected_event_card_id)
		var donor_card := ImmersiveCardScript.new()
		donor_card.card = donor
		donor_card.chosen = true
		donor_card.disabled = true
		_place(donor_card, Rect2(vw * 0.5 - 78, 105, 156, 214))
		_place(_label("2 · TOCA LA CARTA QUE RECIBIRÁ ESTOS SELLOS", 13, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 326, vw * 0.50, 28))
		_place(_label(SigilCatalogScript.summary_for_card(donor), 11, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, 355, vw * 0.46, 64))

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(scroll, Rect2(90, 430, vw - 180, 190))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	scroll.add_child(row)
	for card_id in state.deck_ids:
		var data: Dictionary = _campaign_card(card_id)
		var card := ImmersiveCardScript.new()
		card.card = data
		card.custom_minimum_size = Vector2(126, 172)
		if selected_event_card_id.is_empty():
			card.disabled = Array(data.get("sigils", [])).is_empty()
			card.pressed.connect(_select_sigil_donor.bind(node_id, card_id))
		else:
			card.disabled = card_id == selected_event_card_id
			card.pressed.connect(_finish_sigil_transfer.bind(node_id, card_id))
		row.add_child(card)

	var back := _small_button("VOLVER AL MAPA", 200)
	back.pressed.connect(_leave_special_event)
	_place(back, Rect2(vw - 225, vh - 50, 200, 38))

func _show_mycologists(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("choice")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("LOS MICÓLOGOS", 31, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 30, vw * 0.50, 42))
	_place(_label("Dos ejemplares iguales. Un solo cuerpo. Estadísticas sumadas.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.22, 72, vw * 0.56, 28))

	var candidates: Array[String] = state.mycologist_candidates()
	if candidates.is_empty():
		_place(_label("NO TIENES DOS COPIAS IGUALES EN EL MAZO.", 15, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 280, vw * 0.50, 34))
		var skip := _small_button("CONTINUAR SIN FUSIÓN", 280)
		skip.pressed.connect(_resolve_simple_node.bind(node_id))
		_place(skip, Rect2(vw * 0.5 - 140, 340, 280, 48))
	else:
		var card_w := 176.0
		var gap := 50.0
		var total := card_w * float(candidates.size()) + gap * float(maxi(candidates.size() - 1, 0))
		var left := maxf(40.0, (vw - total) * 0.5)
		for i in range(candidates.size()):
			var card_id := candidates[i]
			var data: Dictionary = _campaign_card(card_id)
			var card := ImmersiveCardScript.new()
			card.card = data
			card.pressed.connect(_fuse_duplicate.bind(node_id, card_id))
			_place(card, Rect2(left + float(i) * (card_w + gap), 155, card_w, 242))
			_place(_label("2 COPIAS → 1 FUSIÓN", 11, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(left + float(i) * (card_w + gap) - 5, 408, card_w + 10, 24))

	var back := _small_button("VOLVER AL MAPA", 200)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw - 225, vh - 50, 200, 38))

func _show_trial(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("choice")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("PRUEBA DEL MAZO", 31, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 30, vw * 0.50, 42))
	_place(_label("Elige qué aspecto de tus próximas tres cartas quieres poner a prueba.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.20, 72, vw * 0.60, 28))

	var defs := [
		{"type":"power", "title":"PODER", "desc":"ATQ TOTAL ≥ 4"},
		{"type":"health", "title":"SALUD", "desc":"VIDA TOTAL ≥ 6"},
		{"type":"blood", "title":"SANGRE", "desc":"COSTE DE SANGRE ≥ 4"},
		{"type":"wisdom", "title":"SABIDURÍA", "desc":"3 SELLOS EN TOTAL"}
	]
	var w := 210.0
	var gap := 26.0
	var total := w * 4.0 + gap * 3.0
	var left := (vw - total) * 0.5
	for i in range(defs.size()):
		var trial: Dictionary = defs[i]
		var button := _small_button("%s\n%s" % [trial["title"], trial["desc"]], int(w))
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_run_trial.bind(node_id, str(trial["type"])))
		button.add_theme_stylebox_override("normal", _panel_style(Color("11170d"), I_EDGE, 3, 3))
		_place(button, Rect2(left + float(i) * (w + gap), 220, w, 130))

	var back := _small_button("VOLVER AL MAPA", 200)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw - 225, vh - 50, 200, 38))

func _run_trial(node_id: String, trial_type: String) -> void:
	var result: Dictionary = state.begin_trial(node_id, trial_type)
	if result.is_empty():
		return
	_clear_screen()
	_add_campaign_backdrop("reward")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	var passed := bool(result.get("passed", false))
	_place(_label("PRUEBA SUPERADA" if passed else "PRUEBA FALLIDA", 30, I_SUCCESS if passed else Color("9d4b36"), HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 25, vw * 0.50, 42))
	_place(_label("TOTAL %d / %d" % [int(result.get("total", 0)), int(result.get("threshold", 0))], 16, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.38, 68, vw * 0.24, 28))

	var cards: Array = Array(result.get("cards", []))
	var card_w := 155.0
	var gap := 40.0
	var total := card_w * float(cards.size()) + gap * float(maxi(cards.size() - 1, 0))
	var left := (vw - total) * 0.5
	for i in range(cards.size()):
		var card := ImmersiveCardScript.new()
		card.card = _campaign_card(str(cards[i]))
		card.disabled = true
		_place(card, Rect2(left + float(i) * (card_w + gap), 115, card_w, 212))

	if passed:
		_place(_label("ELIGE UNA RECOMPENSA RARA", 13, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.33, 345, vw * 0.34, 26))
		var rewards: Array = Array(result.get("rewards", []))
		var rw := 130.0
		var rgap := 28.0
		var rtotal := rw * float(rewards.size()) + rgap * float(maxi(rewards.size() - 1, 0))
		var rleft := (vw - rtotal) * 0.5
		for i in range(rewards.size()):
			var reward_id := str(rewards[i])
			var reward := ImmersiveCardScript.new()
			reward.card = _campaign_card(reward_id)
			reward.pressed.connect(_claim_trial_reward.bind(node_id, reward_id))
			_place(reward, Rect2(rleft + float(i) * (rw + rgap), 382, rw, 178))
	else:
		CampaignSaveScript.save_state(state)
		var continue_button := _small_button("CONTINUAR", 240)
		continue_button.pressed.connect(_show_map)
		_place(continue_button, Rect2(vw * 0.5 - 120, vh - 72, 240, 44))

func _show_campfire(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("campfire")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	_place(_label("UNA FOGATA ENTRE LOS ÁRBOLES", 29, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.20, 25, vw * 0.60, 42))
	_place(_label("Elige una carta de tu mazo. El fuego puede fortalecerla.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.22, 65, vw * 0.56, 30))

	if selected_campfire_card_id.is_empty():
		_place(_label("TOCA UNA CARTA Y COLÓCALA JUNTO AL FUEGO", 14, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.30, 315, vw * 0.40, 30))
	else:
		var selected_card := ImmersiveCardScript.new()
		selected_card.card = _campaign_card(selected_campfire_card_id)
		selected_card.chosen = true
		selected_card.disabled = true
		_place(selected_card, Rect2(vw * 0.5 - 88, 135, 176, 242))

		var buff: Dictionary = state.get_card_buff(selected_campfire_card_id)
		var selected_data: Dictionary = _campaign_card(selected_campfire_card_id)
		_place(_label("%s  ·  ATQ %d  ·  VIDA %d" % [
			str(selected_data.get("name", selected_campfire_card_id)),
			int(selected_data.get("atk", 0)),
			int(selected_data.get("hp", 0))
		], 13, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.31, 382, vw * 0.38, 26))
		_place(_label("MEJORAS: +%d ATQ  ·  +%d VIDA" % [int(buff.get("atk", 0)), int(buff.get("hp", 0))], 11, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.34, 408, vw * 0.32, 24))

		var atk_button := _small_button("+1 ATQ", 170)
		atk_button.pressed.connect(_apply_campfire_upgrade.bind(node_id, "atk"))
		atk_button.add_theme_stylebox_override("normal", _panel_style(Color(0.11, 0.055, 0.025, 0.94), I_AMBER, 2, 2))
		_place(atk_button, Rect2(vw * 0.5 - 190, 438, 170, 42))

		var hp_button := _small_button("+2 VIDA", 170)
		hp_button.pressed.connect(_apply_campfire_upgrade.bind(node_id, "hp"))
		hp_button.add_theme_stylebox_override("normal", _panel_style(Color(0.075, 0.095, 0.035, 0.94), I_AMBER, 2, 2))
		_place(hp_button, Rect2(vw * 0.5 + 20, 438, 170, 42))

	# El mazo físico queda disponible abajo para colocar otra carta en el fuego.
	var deck_scroll := ScrollContainer.new()
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	deck_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(deck_scroll, Rect2(105, 492, vw - 210, 170))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	deck_scroll.add_child(row)
	for card_id in state.deck_ids:
		var card := ImmersiveCardScript.new()
		card.card = _campaign_card(card_id)
		card.chosen = card_id == selected_campfire_card_id
		card.custom_minimum_size = Vector2(118, 160)
		card.pressed.connect(_select_campfire_card.bind(node_id, card_id))
		row.add_child(card)

	var leave := _small_button("ALEJARTE", 190)
	leave.pressed.connect(_leave_campfire)
	_place(leave, Rect2(vw - 215, vh - 48, 190, 36))

func _show_region_gate(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("gate")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	var second_entry := node_id == "region_complete"
	var final_second := node_id == "region_2_complete"
	var title := "EL SEGUNDO TRAMO SE ABRE" if second_entry else ("LA SEGUNDA SENDA TERMINA" if final_second else "ALGO TE ESPERA MÁS ADELANTE")
	var subtitle := "Las Piedras Misteriosas y los Micólogos esperan más allá." if second_entry else ("El siguiente tramo añadirá más objetos, tótems y jefes." if final_second else "Cruza el umbral y continúa.")
	_place(_label(title, 31, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.18, 42, vw * 0.64, 44))
	_place(_label(subtitle, 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.20, 88, vw * 0.60, 42))
	if second_entry:
		var enter_second := _small_button("ABRIR SEGUNDO TRAMO", 320)
		enter_second.pressed.connect(_resolve_simple_node.bind(node_id))
		enter_second.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.050, 0.025, 0.94), I_AMBER, 2, 3))
		_place(enter_second, Rect2(vw * 0.5 - 160, vh - 127, 320, 54))
	elif not final_second:
		var enter := _small_button("CRUZAR EL UMBRAL", 320)
		enter.pressed.connect(_resolve_simple_node.bind(node_id))
		enter.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.050, 0.025, 0.94), I_AMBER, 2, 3))
		_place(enter, Rect2(vw * 0.5 - 160, vh - 127, 320, 54))
	var back := _small_button("VOLVER AL MAPA", 230)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw * 0.5 - 115, vh - 66, 230, 44))

func _physical_map_node(node_id: String, text_value: String) -> Button:
	var button := _small_button(text_value, 0)
	button.add_theme_font_size_override("font_size", 13)
	var is_current: bool = state != null and state.current_node == node_id
	var is_resolved: bool = state != null and state.resolved_nodes.has(node_id)
	var accessible: bool = state != null and state.can_enter(node_id)
	if is_current:
		button.text = "●  %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(I_PAPER, I_AMBER, 3, 3))
		button.add_theme_color_override("font_disabled_color", I_INK)
	elif is_resolved:
		button.text = "×  %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.045, 0.065, 0.030, 0.88), I_SUCCESS, 2, 3))
	elif accessible:
		button.pressed.connect(_enter_node.bind(node_id))
		button.add_theme_stylebox_override("normal", _panel_style(Color(0.075, 0.095, 0.040, 0.94), I_AMBER, 2, 3))
		button.add_theme_stylebox_override("pressed", _panel_style(I_PAPER, I_AMBER, 3, 3))
	else:
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.028, 0.040, 0.022, 0.78), I_EDGE, 1, 3))
	return button

func _add_campaign_backdrop(mode_name: String) -> void:
	var backdrop := CampaignBackdropScript.new()
	backdrop.mode = mode_name
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	move_child(backdrop, 0)

func _immersive_slot(unit, player_side: bool, lane: int) -> Button:
	if unit != null:
		var card := ImmersiveCardScript.new()
		card.card = battle_state.card_for_id(str(unit.get("id", "")))
		card.current_hp = int(unit.get("hp", 1))
		card.current_atk = battle_state.attack_for_lane(player_side, lane)
		card.marked = player_side and selected_sacrifices.has(lane)
		card.disabled = false
		return card

	# Casilla vacía casi invisible: la madera/pata ya está dibujada por battle_table.gd.
	var slot := Button.new()
	slot.text = ""
	slot.focus_mode = Control.FOCUS_NONE
	slot.disabled = not player_side or battle_state.needs_draw()
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		slot.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	if player_side and selected_hand_index >= 0 and battle_state.can_play(selected_hand_index, lane, selected_sacrifices).is_empty():
		slot.text = "COLOCAR"
		slot.add_theme_font_size_override("font_size", 14)
		slot.add_theme_color_override("font_color", MOCK_GLOW)
		slot.add_theme_stylebox_override("normal", _panel_style(Color(0.05, 0.07, 0.035, 0.38), MOCK_EDGE, 2, 1))
	return slot

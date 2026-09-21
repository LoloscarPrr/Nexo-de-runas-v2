extends Control

signal exit_requested

const CampaignStateScript = preload("res://scripts/domain/campaign_state.gd")
const CampaignSaveScript = preload("res://scripts/domain/campaign_save.gd")
const BattleStateScript = preload("res://scripts/domain/battle_state.gd")
const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")
const BattleTableScript = preload("res://scripts/ui/battle_table.gd")
const BattleCardScript = preload("res://scripts/ui/battle_card.gd")
const SigilCatalogScript = preload("res://scripts/domain/sigil_catalog.gd")

const CardViewScript = preload("res://scripts/ui/card_view.gd")

const CABIN := Color8(19, 14, 10)
const WOOD := Color8(37, 27, 18)
const WOOD_DEEP := Color8(24, 17, 12)
const PAPER := Color8(93, 73, 45)
const INK := Color8(232, 218, 180)
const MUTED := Color8(157, 139, 105)
const AMBER := Color8(188, 126, 57)
const BLOOD := Color8(135, 42, 34)
const BONE := Color8(207, 195, 158)
const EDGE := Color8(78, 55, 31)
const DANGER := Color8(151, 55, 45)
const SUCCESS := Color8(118, 133, 80)

var state
var battle_state
var active_battle_node := ""
var selected_hand_index := -1
var selected_sacrifices: Array[int] = []
var selected_campfire_card_id := ""
var selected_event_card_id := ""

func has_save() -> bool:
	return CampaignSaveScript.exists()

func start_new_game() -> void:
	_start_new()

func continue_game() -> void:
	_continue_run()

func open_launcher() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("LA CABAÑA", 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("La madera cruje. Algo espera al otro lado de la mesa.", 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_spacer(14))
	var new_game := _wide_button("NUEVA PARTIDA")
	new_game.pressed.connect(_start_new)
	box.add_child(new_game)
	var continue_button := _wide_button("CONTINUAR")
	continue_button.disabled = not CampaignSaveScript.exists()
	continue_button.pressed.connect(_continue_run)
	box.add_child(continue_button)
	var back := _wide_button("ABANDONAR LA CABAÑA")
	back.pressed.connect(_exit_to_menu)
	box.add_child(back)

func _start_new() -> void:
	state = CampaignStateScript.new()
	CampaignSaveScript.save_state(state)
	_show_map()

func _continue_run() -> void:
	state = CampaignSaveScript.load_state()
	if state == null:
		_start_new()
		return
	_show_map()

func _exit_to_menu() -> void:
	exit_requested.emit()

func _show_map() -> void:
	if state == null:
		open_launcher()
		return
	_clear_screen()
	var box := _screen_box()
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	box.add_child(header)
	var leave := _small_button("‹ MENÚ", 130)
	leave.pressed.connect(_exit_to_menu)
	header.add_child(leave)
	var title := _label("EL MAPA SOBRE LA MESA", 27, INK, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var stats := _label("MAZO %d · VICTORIAS %d" % [state.deck_ids.size(), state.victories], 14, AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
	stats.custom_minimum_size = Vector2(245, 40)
	header.add_child(stats)

	box.add_child(_label("La tinta marca dos senderos. Solo puedes avanzar por una ruta conectada.", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_spacer(4))
	box.add_child(_map_node_button("start", "INICIO DEL SENDERO"))
	box.add_child(_connector("╲                         ╱"))
	var branch := HBoxContainer.new()
	branch.alignment = BoxContainer.ALIGNMENT_CENTER
	branch.add_theme_constant_override("separation", 90)
	branch.add_child(_map_node_button("choice_left", "ELECCIÓN DE BESTIA"))
	branch.add_child(_map_node_button("choice_right", "ELECCIÓN DE COSTE"))
	box.add_child(branch)
	box.add_child(_connector("╲                         ╱"))
	box.add_child(_map_node_button("battle_1", "COMBATE DEL BOSQUE"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("campfire_1", "FOGATA"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("gate_1", "UMBRAL DEL BOSQUE"))
	box.add_child(_connector("│"))
	var branch2 := HBoxContainer.new()
	branch2.alignment = BoxContainer.ALIGNMENT_CENTER
	branch2.add_theme_constant_override("separation", 90)
	branch2.add_child(_map_node_button("choice_2_left", "RASTRO DE BESTIA"))
	branch2.add_child(_map_node_button("choice_2_right", "RASTRO DE SANGRE"))
	box.add_child(branch2)
	box.add_child(_connector("╲                         ╱"))
	box.add_child(_map_node_button("battle_2", "COMBATE PROFUNDO"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("campfire_2", "FOGATA II"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("boss_1", "GUARDIÁN DEL BOSQUE"))
	var current: Dictionary = state.get_node(state.current_node)
	box.add_child(_label("ESTÁS EN: %s" % str(current.get("title", state.current_node)), 15, AMBER, HORIZONTAL_ALIGNMENT_CENTER))

func _map_node_button(node_id: String, text_value: String) -> Button:
	var button := _small_button(text_value, 390)
	var is_current: bool = state != null and state.current_node == node_id
	var is_resolved: bool = state != null and state.resolved_nodes.has(node_id)
	var accessible: bool = state != null and state.can_enter(node_id)
	if is_current:
		button.text = "› %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(PAPER, AMBER, 3, 2))
	elif is_resolved:
		button.text = "✓ %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(WOOD_DEEP, SUCCESS, 2, 2))
	elif accessible:
		button.pressed.connect(_enter_node.bind(node_id))
		button.add_theme_stylebox_override("normal", _panel_style(WOOD, AMBER, 2, 2))
	else:
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(WOOD_DEEP, EDGE, 1, 2))
	return button

func _enter_node(node_id: String) -> void:
	if state == null or not state.can_enter(node_id):
		return
	var node: Dictionary = state.get_node(node_id)
	match str(node.get("type", "")):
		"choice":
			_show_choice(node_id)
		"battle":
			_start_battle(node_id)
		"boss":
			_start_battle(node_id)
		"campfire":
			_show_campfire(node_id)
		"prospector":
			_show_prospector_event(node_id)
		"bone_altar":
			_show_bone_altar(node_id)
		"sigil_stones":
			_show_sigil_stones(node_id)
		"mycologists":
			_show_mycologists(node_id)
		"trial":
			_show_trial(node_id)
		"gate":
			_show_region_gate(node_id)
		"end":
			_show_region_gate(node_id)
		_:
			_show_map()

func _show_choice(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("TRES CARTAS ESPERAN", 32, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Solo una puede acompañarte. Las otras volverán a la oscuridad.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var ids: Array[String] = _reward_choices("choice:%s" % node_id, 3)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	for card_id in ids:
		row.add_child(_choice_card_button(card_id, _claim_choice.bind(node_id, card_id)))
	var back := _small_button("VOLVER AL MAPA", 260)
	back.pressed.connect(_show_map)
	box.add_child(back)

func _reward_choices(key: String, count: int = 3) -> Array[String]:
	var pool: Array[String] = CardCatalogScript.campaign_reward_pool()
	var choices: Array[String] = []
	if pool.is_empty():
		return choices
	var rng := RandomNumberGenerator.new()
	var seed_base := int(state.run_seed) if state != null else 1
	rng.seed = seed_base ^ int(key.hash())
	var available: Array[String] = []
	for card_id in pool:
		available.append(card_id)
	while choices.size() < count and not available.is_empty():
		var pick: int = rng.randi_range(0, available.size() - 1)
		choices.append(available[pick])
		available.remove_at(pick)
	return choices

func _claim_choice(node_id: String, card_id: String) -> void:
	if state == null or not state.can_enter(node_id):
		return
	if state.claim_reward("choice:%s" % node_id, card_id):
		state.resolve_node(node_id)
		CampaignSaveScript.save_state(state)
	_show_map()

func _start_battle(node_id: String) -> void:
	active_battle_node = node_id
	selected_hand_index = -1
	selected_sacrifices.clear()
	battle_state = BattleStateScript.new()
	battle_state.setup(state.deck_ids, state.card_buffs, node_id, state.card_sigils)
	battle_state.bones = maxi(battle_state.bones, int(state.bone_boon))
	battle_state.ouroboros_bonus = int(state.ouroboros_bonus)
	_render_battle()

func _render_battle() -> void:
	_clear_screen()
	var table := BattleTableScript.new()
	table.balance = battle_state.scale
	table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(table)
	_place(_label("LA MESA  /  TURNO %02d" % battle_state.turn, 20, INK, HORIZONTAL_ALIGNMENT_LEFT), Rect2(286, 34, 440, 36))
	var leave := _small_button("‹ MAPA", 120)
	leave.pressed.connect(_show_map)
	_place(leave, Rect2(28, 28, 120, 44))
	_place(_label("BALANZA", 15, AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(45, 195, 190, 30))
	_place(_label("%+d / 5" % battle_state.scale, 23, INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(50, 401, 180, 36))
	_place(_label("HUESOS  %d" % battle_state.bones, 19, BONE, HORIZONTAL_ALIGNMENT_CENTER), Rect2(40, 454, 198, 35))
	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_ready: int = battle_state.blood_value_for_sacrifices(selected_sacrifices)
	_place(_label("SANGRE  %d / %d" % [blood_ready, blood_cost], 17, INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(36, 493, 210, 34))
	_place(_label("EL GUARDIÁN", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(990, 241, 230, 30))
	if battle_state.enemy_queue_index < battle_state.enemy_queue.size():
		var next_card := CardCatalogScript.find_by_id(battle_state.enemy_queue[battle_state.enemy_queue_index])
		_place(_label("SE ACERCA\n%s" % str(next_card.get("name", "")), 14, AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(992, 280, 230, 48))
	for lane in range(4):
		var x := 290.0 + lane * 157.0
		var enemy = battle_state.enemy_lanes[lane]
		var enemy_slot := _table_slot(enemy, false, lane)
		_place(enemy_slot, Rect2(x, 110, 147, 162))
		var player = battle_state.player_lanes[lane]
		var player_slot := _table_slot(player, true, lane)
		player_slot.pressed.connect(_on_player_lane_pressed.bind(lane))
		_place(player_slot, Rect2(x, 293, 147, 162))
	_place(_label("SU LADO     ·     CUATRO CARRILES     ·     TU LADO", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(290, 270, 618, 22))
	var status_text: String = battle_state.last_message
	_place(_label(status_text, 15, INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(280, 467, 635, 49))

	var draw_deck := _small_button("MAZO\n%d cartas" % battle_state.draw_pile.size(), 112)
	draw_deck.disabled = not battle_state.needs_draw() or battle_state.draw_pile.is_empty()
	draw_deck.pressed.connect(_draw_regular)
	_place(draw_deck, Rect2(982, 442, 112, 102))
	var squirrels := _small_button("ARDILLAS\n%d cartas" % battle_state.squirrel_pile_count, 112)
	squirrels.disabled = not battle_state.needs_draw() or battle_state.squirrel_pile_count <= 0
	squirrels.pressed.connect(_draw_squirrel)
	_place(squirrels, Rect2(1110, 442, 112, 102))
	if battle_state.needs_draw():
		_place(_label("ELIGE DE DÓNDE ROBAR", 13, AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(978, 550, 250, 28))

	var hand_scroll := ScrollContainer.new()
	hand_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hand_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(hand_scroll, Rect2(278, 526, 647, 188))
	var hand_row := HBoxContainer.new()
	hand_row.add_theme_constant_override("separation", 8)
	hand_scroll.add_child(hand_row)
	for index in range(battle_state.hand.size()):
		var card := BattleCardScript.new()
		card.card = battle_state.card_for_id(battle_state.hand[index])
		card.chosen = index == selected_hand_index
		card.custom_minimum_size = Vector2(126, 172)
		card.disabled = battle_state.needs_draw()
		card.pressed.connect(_select_hand.bind(index))
		hand_row.add_child(card)
	if battle_state.hand.is_empty():
		hand_row.add_child(_label("Tu mano está vacía.", 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if selected_hand_index >= 0:
		hand_scroll.set_deferred("scroll_horizontal", maxi(0, selected_hand_index * 134 - 268))
	var cancel := _small_button("CANCELAR\nSACRIFICIOS", 192)
	cancel.disabled = selected_sacrifices.is_empty()
	cancel.pressed.connect(_cancel_sacrifices)
	_place(cancel, Rect2(46, 565, 192, 60))
	var bell := _small_button("CAMPANA\nTerminar turno", 240)
	bell.disabled = battle_state.needs_draw()
	bell.pressed.connect(_end_battle_turn)
	_place(bell, Rect2(984, 615, 240, 70))

func _place(control: Control, rect: Rect2) -> void:
	add_child(control)
	control.position = rect.position
	control.size = rect.size
	control.set_deferred("size", rect.size)

func _table_slot(unit, player_side: bool, lane: int) -> Button:
	if unit != null:
		var card := BattleCardScript.new()
		card.card = battle_state.card_for_id(str(unit.get("id", "")))
		card.current_hp = int(unit.get("hp", 1))
		card.marked = player_side and selected_sacrifices.has(lane)
		card.disabled = not player_side or battle_state.needs_draw()
		return card
	var slot := _small_button("%d" % (lane + 1), 0)
	slot.disabled = not player_side or battle_state.needs_draw()
	slot.add_theme_stylebox_override("normal", _panel_style(Color(0.06, 0.04, 0.02, 0.35), EDGE, 2, 5))
	slot.add_theme_stylebox_override("disabled", _panel_style(Color(0.06, 0.04, 0.02, 0.35), EDGE, 2, 5))
	if player_side and selected_hand_index >= 0 and battle_state.can_play(selected_hand_index, lane, selected_sacrifices).is_empty():
		slot.text = "COLOCAR"
		slot.add_theme_stylebox_override("normal", _panel_style(WOOD, AMBER, 2, 5))
	return slot

func _select_hand(hand_index: int) -> void:
	if selected_hand_index == hand_index:
		selected_hand_index = -1
		selected_sacrifices.clear()
		battle_state.last_message = "Cancelaste la carta seleccionada."
	else:
		selected_hand_index = hand_index
		selected_sacrifices.clear()
		var card := CardCatalogScript.find_by_id(battle_state.hand[hand_index])
		var blood_cost: int = battle_state.blood_cost_for(hand_index)
		if blood_cost > 0:
			battle_state.last_message = "%s exige %d sacrificio(s). Toca tus criaturas." % [str(card.get("name", "La carta")), blood_cost]
		else:
			battle_state.last_message = "Toca la casilla donde quieres jugar %s." % str(card.get("name", "la carta"))
	_render_battle()

func _on_player_lane_pressed(lane_index: int) -> void:
	if selected_hand_index < 0:
		battle_state.last_message = "Primero elige una carta de tu mano."
		_render_battle()
		return
	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_ready: int = battle_state.blood_value_for_sacrifices(selected_sacrifices)
	if blood_cost > 0 and blood_ready < blood_cost:
		if battle_state.player_lanes[lane_index] == null:
			battle_state.last_message = "Necesitas marcar criaturas vivas para el sacrificio."
			_render_battle()
			return
		if selected_sacrifices.has(lane_index):
			selected_sacrifices.erase(lane_index)
		else:
			selected_sacrifices.append(lane_index)
		blood_ready = battle_state.blood_value_for_sacrifices(selected_sacrifices)
		if blood_ready >= blood_cost:
			battle_state.last_message = "La Sangre está lista. Toca la casilla donde colocarás la carta."
		else:
			battle_state.last_message = "Faltan %d punto(s) de Sangre." % (blood_cost - blood_ready)
		_render_battle()
		return
	if battle_state.play_card(selected_hand_index, lane_index, selected_sacrifices):
		selected_hand_index = -1
		selected_sacrifices.clear()
	_render_battle()

func _cancel_sacrifices() -> void:
	selected_sacrifices.clear()
	battle_state.last_message = "Los sacrificios fueron cancelados."
	_render_battle()

func _draw_regular() -> void:
	battle_state.draw_from_deck()
	_render_battle()

func _draw_squirrel() -> void:
	battle_state.draw_squirrel()
	_render_battle()

func _end_battle_turn() -> void:
	selected_hand_index = -1
	selected_sacrifices.clear()
	var result: String = battle_state.end_turn()
	if result == "victory":
		_show_battle_reward()
	elif result == "defeat":
		state.defeats += 1
		state.ouroboros_bonus = maxi(int(state.ouroboros_bonus), int(battle_state.ouroboros_bonus))
		CampaignSaveScript.save_state(state)
		_show_defeat()
	else:
		_render_battle()

func _show_battle_reward() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("LA BALANZA CEDE", 36, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Tu oponente empuja tres cartas hacia ti. Elige una.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	for card_id in _reward_choices("battle:%s:%d" % [active_battle_node, state.victories], 3):
		row.add_child(_choice_card_button(card_id, _claim_battle_reward.bind(card_id)))

func _claim_battle_reward(card_id: String) -> void:
	if state == null or active_battle_node.is_empty():
		return
	if state.claim_reward("battle:%s" % active_battle_node, card_id):
		state.victories += 1
		state.ouroboros_bonus = maxi(int(state.ouroboros_bonus), int(battle_state.ouroboros_bonus))
		state.resolve_node(active_battle_node)
		CampaignSaveScript.save_state(state)
	_show_map()

func _show_defeat() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("TU VELA SE APAGA", 36, DANGER, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("La balanza cayó del lado equivocado. Este prototipo aún permite volver al mapa; las vidas y la derrota de campaña llegarán con la siguiente capa del Acto 1.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var retry := _wide_button("VOLVER A LA MESA")
	retry.pressed.connect(_start_battle.bind(active_battle_node))
	box.add_child(retry)
	var map_button := _wide_button("REGRESAR AL MAPA")
	map_button.pressed.connect(_show_map)
	box.add_child(map_button)

func _show_prospector_event(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("EL PROSPECTOR SONRÍE", 34, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Tres rocas. Una puede ocultar oro; las otras, algo vivo.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	for index in range(3):
		var pick := _wide_button("ROCA %d" % (index + 1))
		pick.custom_minimum_size = Vector2(210, 150)
		pick.pressed.connect(_pick_prospector_boulder.bind(node_id, index))
		row.add_child(pick)
	var back := _small_button("VOLVER AL MAPA", 260)
	back.pressed.connect(_show_map)
	box.add_child(back)

func _pick_prospector_boulder(node_id: String, index: int) -> void:
	if state == null:
		return
	var reward: String = state.claim_prospector_boulder(node_id, index)
	if reward.is_empty():
		return
	CampaignSaveScript.save_state(state)
	_show_event_reward("LA ROCA SE PARTE", reward)

func _show_event_reward(title_text: String, card_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label(title_text, 34, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER))
	var card := BattleCardScript.new()
	card.card = _campaign_card(card_id)
	card.custom_minimum_size = Vector2(190, 260)
	card.disabled = true
	box.add_child(card)
	box.add_child(_label(SigilCatalogScript.summary_for_card(card.card), 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var continue_button := _wide_button("CONTINUAR")
	continue_button.pressed.connect(_show_map)
	box.add_child(continue_button)

func _show_bone_altar(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("EL ALTAR EXIGE UNA OFRENDA", 34, BONE, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Sacrifica una carta para comenzar los combates con Huesos. La Cabra Negra concede una bendición mayor.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 290)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	scroll.add_child(row)
	for card_id in state.deck_ids:
		var card := BattleCardScript.new()
		card.card = _campaign_card(card_id)
		card.chosen = card_id == selected_event_card_id
		card.custom_minimum_size = Vector2(155, 215)
		card.pressed.connect(_select_bone_altar_card.bind(node_id, card_id))
		row.add_child(card)
	if selected_event_card_id.is_empty():
		box.add_child(_label("ELIGE UNA CARTA", 14, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var selected := _campaign_card(selected_event_card_id)
		box.add_child(_label(SigilCatalogScript.summary_for_card(selected), 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		var offer := _wide_button("OFRECER %s" % str(selected.get("name", "CARTA")))
		offer.pressed.connect(_confirm_bone_altar.bind(node_id))
		box.add_child(offer)
	var back := _small_button("VOLVER AL MAPA", 260)
	back.pressed.connect(_leave_special_event)
	box.add_child(back)

func _select_bone_altar_card(node_id: String, card_id: String) -> void:
	selected_event_card_id = card_id
	_show_bone_altar(node_id)

func _confirm_bone_altar(node_id: String) -> void:
	if state == null or selected_event_card_id.is_empty():
		return
	if state.sacrifice_to_bone_lord(node_id, selected_event_card_id):
		CampaignSaveScript.save_state(state)
	selected_event_card_id = ""
	_show_map()

func _leave_special_event() -> void:
	selected_event_card_id = ""
	_show_map()

func _show_sigil_stones(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("PIEDRAS MISTERIOSAS", 34, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Elige una carta con sello para destruirla y transferir sus sellos a otra.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if selected_event_card_id.is_empty():
		box.add_child(_label("PRIMERO ELIGE LA CARTA DONANTE", 14, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var donor := _campaign_card(selected_event_card_id)
		box.add_child(_label("DONANTE: %s" % str(donor.get("name", selected_event_card_id)), 15, INK, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(_label(SigilCatalogScript.summary_for_card(donor), 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	for card_id in state.deck_ids:
		var data := _campaign_card(card_id)
		var button := BattleCardScript.new()
		button.card = data
		button.custom_minimum_size = Vector2(135, 185)
		if selected_event_card_id.is_empty():
			button.disabled = Array(data.get("sigils", [])).is_empty()
			button.pressed.connect(_select_sigil_donor.bind(node_id, card_id))
		else:
			button.disabled = card_id == selected_event_card_id
			button.pressed.connect(_finish_sigil_transfer.bind(node_id, card_id))
		row.add_child(button)
	var back := _small_button("VOLVER AL MAPA", 240)
	back.pressed.connect(_leave_special_event)
	box.add_child(back)

func _select_sigil_donor(node_id: String, card_id: String) -> void:
	selected_event_card_id = card_id
	_show_sigil_stones(node_id)

func _finish_sigil_transfer(node_id: String, receiver_id: String) -> void:
	if state != null and not selected_event_card_id.is_empty():
		if state.transfer_sigils(node_id, selected_event_card_id, receiver_id):
			CampaignSaveScript.save_state(state)
	selected_event_card_id = ""
	_show_map()

func _show_mycologists(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("LOS MICÓLOGOS", 34, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Solo pueden trabajar con dos copias iguales. Las unirán en una carta más fuerte.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var candidates: Array[String] = state.mycologist_candidates()
	if candidates.is_empty():
		box.add_child(_label("NO TIENES DOS COPIAS IGUALES.", 15, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
		var skip := _wide_button("DEJARLOS TRABAJAR OTRO DÍA")
		skip.pressed.connect(_resolve_simple_node.bind(node_id))
		box.add_child(skip)
	else:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 16)
		box.add_child(row)
		for card_id in candidates:
			var data := _campaign_card(card_id)
			var card := BattleCardScript.new()
			card.card = data
			card.custom_minimum_size = Vector2(165, 225)
			card.pressed.connect(_fuse_duplicate.bind(node_id, card_id))
			row.add_child(card)
	var back := _small_button("VOLVER AL MAPA", 240)
	back.pressed.connect(_show_map)
	box.add_child(back)

func _fuse_duplicate(node_id: String, card_id: String) -> void:
	if state != null and state.fuse_duplicate(node_id, card_id):
		CampaignSaveScript.save_state(state)
	_show_map()

func _show_trial(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("PRUEBA DEL MAZO", 34, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Elige una prueba. Se revelarán tres cartas de tu mazo.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	for trial_type in ["power", "health", "blood", "wisdom"]:
		var labels := {
			"power":"PRUEBA DE PODER · ATQ TOTAL 4",
			"health":"PRUEBA DE SALUD · VIDA TOTAL 6",
			"blood":"PRUEBA DE SANGRE · COSTE TOTAL 4",
			"wisdom":"PRUEBA DE SABIDURÍA · 3 SELLOS"
		}
		var b := _wide_button(str(labels[trial_type]))
		b.pressed.connect(_run_trial.bind(node_id, trial_type))
		box.add_child(b)
	var back := _small_button("VOLVER AL MAPA", 240)
	back.pressed.connect(_show_map)
	box.add_child(back)

func _run_trial(node_id: String, trial_type: String) -> void:
	var result: Dictionary = state.begin_trial(node_id, trial_type)
	if result.is_empty():
		return
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("LAS CARTAS SE REVELAN", 32, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	for card_id in Array(result.get("cards", [])):
		var card := BattleCardScript.new()
		card.card = _campaign_card(str(card_id))
		card.custom_minimum_size = Vector2(155, 215)
		card.disabled = true
		row.add_child(card)
	var passed := bool(result.get("passed", false))
	box.add_child(_label("TOTAL %d / %d  ·  %s" % [
		int(result.get("total", 0)),
		int(result.get("threshold", 0)),
		"SUPERADA" if passed else "FALLIDA"
	], 18, SUCCESS if passed else DANGER, HORIZONTAL_ALIGNMENT_CENTER))
	if passed:
		box.add_child(_label("ELIGE TU RECOMPENSA RARA", 14, INK, HORIZONTAL_ALIGNMENT_CENTER))
		var rewards := HBoxContainer.new()
		rewards.alignment = BoxContainer.ALIGNMENT_CENTER
		rewards.add_theme_constant_override("separation", 14)
		box.add_child(rewards)
		for card_id in Array(result.get("rewards", [])):
			var card := BattleCardScript.new()
			card.card = _campaign_card(str(card_id))
			card.custom_minimum_size = Vector2(145, 200)
			card.pressed.connect(_claim_trial_reward.bind(node_id, str(card_id)))
			rewards.add_child(card)
	else:
		CampaignSaveScript.save_state(state)
		var continue_button := _wide_button("CONTINUAR")
		continue_button.pressed.connect(_show_map)
		box.add_child(continue_button)

func _claim_trial_reward(node_id: String, card_id: String) -> void:
	if state != null and state.claim_trial_reward(node_id, card_id):
		CampaignSaveScript.save_state(state)
	_show_map()

func _show_campfire(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("UNA FOGATA ENTRE LOS ÁRBOLES", 34, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Elige una carta de tu mazo y colócala junto al fuego.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))

	var deck_scroll := ScrollContainer.new()
	deck_scroll.custom_minimum_size = Vector2(0, 260)
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	deck_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(deck_scroll)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	deck_scroll.add_child(row)
	for card_id in state.deck_ids:
		var card := BattleCardScript.new()
		card.card = _campaign_card(card_id)
		card.chosen = card_id == selected_campfire_card_id
		card.custom_minimum_size = Vector2(160, 220)
		card.pressed.connect(_select_campfire_card.bind(node_id, card_id))
		row.add_child(card)

	if selected_campfire_card_id.is_empty():
		box.add_child(_label("TOCA UNA CARTA PARA PONERLA EN LA FOGATA", 14, AMBER, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var selected := _campaign_card(selected_campfire_card_id)
		var buff: Dictionary = state.get_card_buff(selected_campfire_card_id)
		box.add_child(_label("%s  ·  ATQ %d  ·  VIDA %d" % [
			str(selected.get("name", selected_campfire_card_id)),
			int(selected.get("atk", 0)),
			int(selected.get("hp", 0))
		], 15, INK, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(_label("Mejoras acumuladas: +%d ATQ  ·  +%d VIDA" % [
			int(buff.get("atk", 0)), int(buff.get("hp", 0))
		], 12, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		var improve_row := HBoxContainer.new()
		improve_row.alignment = BoxContainer.ALIGNMENT_CENTER
		improve_row.add_theme_constant_override("separation", 18)
		box.add_child(improve_row)
		var atk_button := _small_button("AVIVAR EL FUEGO  ·  +1 ATQ", 300)
		atk_button.pressed.connect(_apply_campfire_upgrade.bind(node_id, "atk"))
		improve_row.add_child(atk_button)
		var hp_button := _small_button("FORTALECER  ·  +2 VIDA", 300)
		hp_button.pressed.connect(_apply_campfire_upgrade.bind(node_id, "hp"))
		improve_row.add_child(hp_button)

	var back := _wide_button("ALEJARTE")
	back.pressed.connect(_leave_campfire)
	box.add_child(back)

func _campaign_card(card_id: String) -> Dictionary:
	var card := CardCatalogScript.find_by_id(card_id)
	if state == null or card.is_empty():
		return card
	var buff: Dictionary = state.get_card_buff(card_id)
	card["atk"] = int(card.get("atk", 0)) + int(buff.get("atk", 0))
	card["hp"] = int(card.get("hp", 1)) + int(buff.get("hp", 0))
	card["sigils"] = state.get_card_sigils(card_id)
	return card

func _select_campfire_card(node_id: String, card_id: String) -> void:
	selected_campfire_card_id = card_id
	_show_campfire(node_id)

func _apply_campfire_upgrade(node_id: String, stat: String) -> void:
	if state == null or selected_campfire_card_id.is_empty():
		return
	if not state.can_enter(node_id):
		return
	if not state.upgrade_card(selected_campfire_card_id, stat):
		return
	state.resolve_node(node_id)
	CampaignSaveScript.save_state(state)
	selected_campfire_card_id = ""
	_show_map()

func _leave_campfire() -> void:
	selected_campfire_card_id = ""
	_show_map()

func _show_region_gate(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("ALGO TE ESPERA MÁS ADELANTE", 34, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("El sendero continúa. Cruza el umbral para revelar el siguiente tramo.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var finish := _wide_button("MARCAR EL SENDERO")
	finish.pressed.connect(_resolve_simple_node.bind(node_id))
	box.add_child(finish)
	var back := _wide_button("VOLVER AL MAPA")
	back.pressed.connect(_show_map)
	box.add_child(back)

func _resolve_simple_node(node_id: String) -> void:
	if state != null and state.can_enter(node_id):
		state.resolve_node(node_id)
		CampaignSaveScript.save_state(state)
	_show_map()

func _choice_card_button(card_id: String, callback: Callable) -> Button:
	var card := CardCatalogScript.find_by_id(card_id)
	var view = CardViewScript.new()
	view.configure(card, false, false)
	view.pressed.connect(callback)
	return view

func _hand_card_button(card_id: String, selected: bool) -> Button:
	var card := CardCatalogScript.find_by_id(card_id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(155, 78)
	button.focus_mode = Control.FOCUS_NONE
	button.text = "%s%s\n%s · %d / %d" % ["› " if selected else "", str(card.get("name", card_id)), str(card.get("cost", "")), int(card.get("atk", 0)), int(card.get("hp", 0))]
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", INK)
	var border_color := BLOOD if selected else _resource_color(str(card.get("resource", "none")))
	button.add_theme_stylebox_override("normal", _panel_style(WOOD_DEEP, border_color, 3 if selected else 2, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(PAPER, AMBER, 3, 2))
	return button

func _battle_slot(unit, player_side: bool, lane_index: int, sacrifice_marked: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(245, 82)
	button.focus_mode = Control.FOCUS_NONE
	if unit == null:
		button.text = "CARRIL %d\nVACÍO" % (lane_index + 1)
		button.add_theme_color_override("font_color", MUTED)
		button.add_theme_stylebox_override("normal", _panel_style(WOOD_DEEP, EDGE, 1, 2))
	else:
		var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
		button.text = "%s\n%d / %d" % [str(card.get("name", "CARTA")), int(card.get("atk", 0)), int(unit.get("hp", 0))]
		button.add_theme_color_override("font_color", INK)
		var border_color := SUCCESS if player_side else DANGER
		if sacrifice_marked:
			border_color = BLOOD
			button.text = "SACRIFICAR\n%s · %d / %d" % [str(card.get("name", "CARTA")), int(card.get("atk", 0)), int(unit.get("hp", 0))]
		button.add_theme_stylebox_override("normal", _panel_style(WOOD, border_color, 3 if sacrifice_marked else 2, 2))
	button.add_theme_font_size_override("font_size", 13)
	return button

func _screen_box() -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(CABIN, EDGE, 2, 2))
	margin.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	return box

func _clear_screen() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _connector(text_value: String) -> Label:
	return _label(text_value, 16, EDGE, HORIZONTAL_ALIGNMENT_CENTER)

func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, height)
	return spacer

func _label(text_value: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _wide_button(text_value: String) -> Button:
	var button := _small_button(text_value, 620)
	button.custom_minimum_size.y = 58
	button.add_theme_font_size_override("font_size", 19)
	return button

func _small_button(text_value: String, width: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", _panel_style(WOOD_DEEP, EDGE, 2, 2))
	button.add_theme_stylebox_override("hover", _panel_style(WOOD, AMBER, 2, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(PAPER, AMBER, 2, 2))
	return button

func _resource_color(resource: String) -> Color:
	match resource:
		"blood": return BLOOD
		"bones": return BONE
		_: return AMBER

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
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

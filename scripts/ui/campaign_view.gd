extends Control

signal exit_requested

const CampaignStateScript = preload("res://scripts/domain/campaign_state.gd")
const CampaignSaveScript = preload("res://scripts/domain/campaign_save.gd")
const BattleStateScript = preload("res://scripts/domain/battle_state.gd")
const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")

const PANEL := Color8(27, 23, 17)
const PANEL_ALT := Color8(18, 16, 13)
const INK := Color8(230, 220, 190)
const MUTED := Color8(157, 146, 121)
const ACCENT := Color8(190, 139, 57)
const ACCENT_DARK := Color8(83, 55, 25)
const BORDER := Color8(112, 82, 42)
const DANGER := Color8(140, 54, 45)
const SUCCESS := Color8(88, 125, 72)

var state
var battle_state
var active_battle_node := ""
var selected_hand_index := -1

func open_launcher() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("CAMPAÑA · ACTO 1", 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var subtitle := _label("EXPEDICIÓN OFFLINE · MAPA, EVENTOS Y COMBATE", 17, ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(subtitle)
	box.add_child(_spacer(12))
	var new_game := _wide_button("NUEVA PARTIDA")
	new_game.pressed.connect(_start_new)
	box.add_child(new_game)
	var continue_button := _wide_button("CONTINUAR")
	continue_button.disabled = not CampaignSaveScript.exists()
	continue_button.pressed.connect(_continue_run)
	box.add_child(continue_button)
	var back := _wide_button("VOLVER AL MENÚ")
	back.pressed.connect(_exit_to_menu)
	box.add_child(back)
	var status := "Guardado detectado." if CampaignSaveScript.exists() else "Aún no existe una expedición guardada."
	box.add_child(_label(status, 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))

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
	var back := _small_button("‹ CAMPAÑA", 160)
	back.pressed.connect(open_launcher)
	header.add_child(back)
	var title := _label("MAPA DE LA EXPEDICIÓN", 28, INK, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var stats := _label("MAZO %d · VICTORIAS %d" % [state.deck_ids.size(), state.victories], 15, ACCENT, HORIZONTAL_ALIGNMENT_RIGHT)
	stats.custom_minimum_size = Vector2(260, 40)
	header.add_child(stats)
	box.add_child(_label("Toca únicamente los nodos conectados con tu posición actual.", 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_spacer(4))
	box.add_child(_map_node_button("start", "◆ INICIO"))
	box.add_child(_connector("╲                         ╱"))
	var branch := HBoxContainer.new()
	branch.alignment = BoxContainer.ALIGNMENT_CENTER
	branch.add_theme_constant_override("separation", 90)
	branch.add_child(_map_node_button("choice_left", "◈ ELECCIÓN · HUESOS"))
	branch.add_child(_map_node_button("choice_right", "◈ ELECCIÓN · ENERGÍA"))
	box.add_child(branch)
	box.add_child(_connector("╲                         ╱"))
	box.add_child(_map_node_button("battle_1", "⚔ COMBATE DEL BOSQUE"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("campfire_1", "♨ FOGATA"))
	box.add_child(_connector("│"))
	box.add_child(_map_node_button("gate_1", "⬡ UMBRAL DE LA REGIÓN"))
	var current := state.get_node(state.current_node)
	box.add_child(_label("POSICIÓN: %s" % str(current.get("title", state.current_node)), 16, ACCENT, HORIZONTAL_ALIGNMENT_CENTER))

func _map_node_button(node_id: String, text_value: String) -> Button:
	var button := _small_button(text_value, 390)
	var is_current: bool = state != null and state.current_node == node_id
	var is_resolved: bool = state != null and state.resolved_nodes.has(node_id)
	var accessible: bool = state != null and state.can_enter(node_id)
	if is_current:
		button.text = "▶ %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(ACCENT_DARK, ACCENT, 3, 4))
	elif is_resolved:
		button.text = "✓ %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(PANEL_ALT, SUCCESS, 2, 4))
	elif accessible:
		button.pressed.connect(_enter_node.bind(node_id))
		button.add_theme_stylebox_override("normal", _panel_style(PANEL, ACCENT, 3, 4))
	else:
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(PANEL_ALT, BORDER, 1, 4))
	return button

func _enter_node(node_id: String) -> void:
	if state == null or not state.can_enter(node_id):
		return
	var node := state.get_node(node_id)
	match str(node.get("type", "")):
		"choice":
			_show_choice(node_id)
		"battle":
			_start_battle(node_id)
		"campfire":
			_show_campfire(node_id)
		"end":
			_show_region_gate(node_id)
		_:
			_show_map()

func _show_choice(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("ELECCIÓN DE CARTA", 34, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Escoge una. La carta se incorpora al mazo de esta expedición.", 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var ids: Array[String]
	if node_id == "choice_left":
		ids = ["esqueleto", "sepulturero", "mox_rubi"]
	else:
		ids = ["automata", "conducto", "francotirador"]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	for card_id in ids:
		row.add_child(_choice_card_button(card_id, _claim_choice.bind(node_id, card_id)))
	var back := _small_button("VOLVER AL MAPA", 260)
	back.pressed.connect(_show_map)
	box.add_child(back)

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
	battle_state = BattleStateScript.new()
	battle_state.setup(state.deck_ids)
	_render_battle()

func _render_battle() -> void:
	_clear_screen()
	var box := _screen_box()
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	box.add_child(header)
	var abandon := _small_button("‹ MAPA", 130)
	abandon.pressed.connect(_show_map)
	header.add_child(abandon)
	var title := _label("COMBATE DEL BOSQUE · TURNO %d" % battle_state.turn, 24, INK, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var resources := _label("⚙ %d/%d   ☠ %d   BALANZA %+d" % [battle_state.energy, battle_state.max_energy, battle_state.bones, battle_state.scale], 16, ACCENT, HORIZONTAL_ALIGNMENT_RIGHT)
	resources.custom_minimum_size = Vector2(330, 40)
	header.add_child(resources)
	box.add_child(_label("ENEMIGO", 14, DANGER, HORIZONTAL_ALIGNMENT_CENTER))
	var enemy_grid := GridContainer.new()
	enemy_grid.columns = 4
	enemy_grid.add_theme_constant_override("h_separation", 10)
	box.add_child(enemy_grid)
	for lane_index in range(4):
		enemy_grid.add_child(_battle_slot(battle_state.enemy_lanes[lane_index], false, lane_index))
	box.add_child(_connector("────────────────────────────────────────────────────────────"))
	var player_grid := GridContainer.new()
	player_grid.columns = 4
	player_grid.add_theme_constant_override("h_separation", 10)
	box.add_child(player_grid)
	for lane_index in range(4):
		var slot := _battle_slot(battle_state.player_lanes[lane_index], true, lane_index)
		slot.pressed.connect(_play_selected_to_lane.bind(lane_index))
		player_grid.add_child(slot)
	box.add_child(_label("TU LADO", 14, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER))
	var status := _label(battle_state.last_message, 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status)
	var hand_row := HBoxContainer.new()
	hand_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_row.add_theme_constant_override("separation", 8)
	box.add_child(hand_row)
	for hand_index in range(battle_state.hand.size()):
		var card_id: String = battle_state.hand[hand_index]
		var card_button := _hand_card_button(card_id, hand_index == selected_hand_index)
		card_button.pressed.connect(_select_hand.bind(hand_index))
		hand_row.add_child(card_button)
	if battle_state.hand.is_empty():
		hand_row.add_child(_label("MANO VACÍA", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var end_turn := _wide_button("TERMINAR TURNO")
	end_turn.custom_minimum_size.y = 50
	end_turn.pressed.connect(_end_battle_turn)
	box.add_child(end_turn)

func _select_hand(hand_index: int) -> void:
	selected_hand_index = hand_index
	_render_battle()

func _play_selected_to_lane(lane_index: int) -> void:
	if selected_hand_index < 0:
		battle_state.last_message = "Primero toca una carta de tu mano."
		_render_battle()
		return
	if battle_state.play_card(selected_hand_index, lane_index):
		selected_hand_index = -1
	_render_battle()

func _end_battle_turn() -> void:
	selected_hand_index = -1
	var result: String = battle_state.end_turn()
	if result == "victory":
		_show_battle_reward()
	elif result == "defeat":
		state.defeats += 1
		CampaignSaveScript.save_state(state)
		_show_defeat()
	else:
		_render_battle()

func _show_battle_reward() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("VICTORIA", 38, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("La balanza cedió. Elige una recompensa antes de volver al mapa.", 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	for card_id in ["esqueleto", "automata", "francotirador"]:
		row.add_child(_choice_card_button(card_id, _claim_battle_reward.bind(card_id)))

func _claim_battle_reward(card_id: String) -> void:
	if state == null or active_battle_node.is_empty():
		return
	if state.claim_reward("battle:%s" % active_battle_node, card_id):
		state.victories += 1
		state.resolve_node(active_battle_node)
		CampaignSaveScript.save_state(state)
	_show_map()

func _show_defeat() -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("LA BALANZA CAYÓ", 38, DANGER, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("El nodo no se resuelve y no se entrega recompensa. Puedes volver al mapa e intentarlo otra vez.", 17, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var retry := _wide_button("REINTENTAR COMBATE")
	retry.pressed.connect(_start_battle.bind(active_battle_node))
	box.add_child(retry)
	var map_button := _wide_button("VOLVER AL MAPA")
	map_button.pressed.connect(_show_map)
	box.add_child(map_button)

func _show_campfire(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("FOGATA", 36, ACCENT, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Primera versión del evento: la fogata estabiliza la expedición y abre el siguiente tramo. Las mejoras de estadísticas llegarán en la fase de encuentros.", 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var continue_button := _wide_button("AVIVAR LA FOGATA")
	continue_button.pressed.connect(_resolve_simple_node.bind(node_id))
	box.add_child(continue_button)
	var back := _wide_button("VOLVER AL MAPA")
	back.pressed.connect(_show_map)
	box.add_child(back)

func _show_region_gate(node_id: String) -> void:
	_clear_screen()
	var box := _screen_box()
	box.add_child(_label("UMBRAL DE LA REGIÓN", 36, INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("Llegaste al final de la primera vertical slice: mapa → elección → combate real → recompensa → mapa → guardado. Los jefes, puzzles y regiones completas siguen pendientes.", 17, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var finish := _wide_button("MARCAR TRAMO COMPLETADO")
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
	var button := Button.new()
	button.custom_minimum_size = Vector2(250, 230)
	button.focus_mode = Control.FOCUS_NONE
	button.text = "%s\n\n%s\n%s\n\n%s\n⚔ %d     ♥ %d" % [str(card.get("name", card_id)), str(card.get("glyph", "?")), str(card.get("cost", "")), str(card.get("seal", "")), int(card.get("atk", 0)), int(card.get("hp", 0))]
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL, _resource_color(str(card.get("resource", "none"))), 3, 4))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 4, 4))
	button.pressed.connect(callback)
	return button

func _hand_card_button(card_id: String, selected: bool) -> Button:
	var card := CardCatalogScript.find_by_id(card_id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(165, 92)
	button.focus_mode = Control.FOCUS_NONE
	button.text = "%s%s\n%s · ⚔%d ♥%d" % ["▶ " if selected else "", str(card.get("name", card_id)), str(card.get("cost", "")), int(card.get("atk", 0)), int(card.get("hp", 0))]
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", INK)
	var border_color := ACCENT if selected else _resource_color(str(card.get("resource", "none")))
	button.add_theme_stylebox_override("normal", _panel_style(PANEL, border_color, 3 if selected else 2, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 3, 3))
	return button

func _battle_slot(unit, player_side: bool, lane_index: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(255, 92)
	button.focus_mode = Control.FOCUS_NONE
	if unit == null:
		button.text = "CASILLA %d\n— VACÍA —" % (lane_index + 1)
		button.add_theme_color_override("font_color", MUTED)
		button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 1, 3))
	else:
		var card := CardCatalogScript.find_by_id(str(unit.get("id", "")))
		button.text = "%s  %s\n⚔ %d     ♥ %d" % [str(card.get("glyph", "?")), str(card.get("name", "CARTA")), int(card.get("atk", 0)), int(unit.get("hp", 0))]
		button.add_theme_color_override("font_color", INK)
		var border_color := SUCCESS if player_side else DANGER
		button.add_theme_stylebox_override("normal", _panel_style(PANEL, border_color, 2, 3))
	button.add_theme_font_size_override("font_size", 14)
	return button

func _screen_box() -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER, 3, 8))
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
	return _label(text_value, 17, BORDER, HORIZONTAL_ALIGNMENT_CENTER)

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
	button.custom_minimum_size.y = 60
	button.add_theme_font_size_override("font_size", 20)
	return button

func _small_button(text_value: String, width: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 44)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 2, 3))
	return button

func _resource_color(resource: String) -> Color:
	match resource:
		"blood": return Color8(126, 38, 34)
		"bones": return Color8(180, 170, 137)
		"energy": return Color8(58, 124, 137)
		"runes": return Color8(112, 67, 143)
		_: return BORDER

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

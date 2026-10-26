class_name VerticalBattleCardFaithful
extends "res://scripts/presentation/battle/vertical_battle_card.gd"

## Variante visual para la mano: conserva la carta física existente pero
## recupera la composición del mockup (arte arriba, texto de habilidad al centro,
## estadísticas abajo). En tablero compacto usa el renderer base.

const TEXT_PANEL := Color("e5d5a6")
const TEXT_PANEL_DARK := Color("9f8654")
const TEXT_INK := Color("21160d")
const FRAME_GOLD := Color("d7a044")
const FRAME_DARK := Color("2c1709")
const TextScript = preload("res://scripts/presentation/cards/card_text.gd")
const EFFECT_FONT_SIZE := 14

func _draw() -> void:
	if compact:
		super._draw()
		return
	if card.is_empty() or size.x < 80.0 or size.y < 120.0:
		return

	var w := size.x
	var h := size.y
	var outer := Rect2(3, 3, w - 6, h - 6)
	var inner := outer.grow(-4)

	# Sombra y cuerpo de madera/bronce.
	draw_rect(Rect2(8, 10, w - 5, h - 2), Color(0, 0, 0, 0.58))
	draw_rect(outer, FRAME_DARK)
	draw_rect(inner, Color("2c1b0d"))
	draw_rect(inner, FRAME_GOLD, false, 2.2)
	draw_rect(inner.grow(-4), Color("70502a"), false, 1.2)

	var header_h := 40.0
	var stats_h := 42.0
	var text_h := 82.0
	var art_top := header_h + 4.0
	var art_h := h - header_h - text_h - stats_h - 17.0
	var art_rect := Rect2(11, art_top, w - 22, art_h)
	var text_rect := Rect2(11, art_rect.end.y + 3, w - 22, text_h - 4)
	var stat_rect := Rect2(10, h - stats_h - 5, w - 20, stats_h)

	_draw_art(art_rect)
	_draw_effect_panel(text_rect)
	_draw_canonical_frame(Rect2(0, 0, w, h))
	_draw_cost_badge(Vector2(26, 25), 15.0)
	_draw_title_plaque(Rect2(46, 7, w - 58, 31))

	var card_type := str(card.get("type", ""))
	if card_type == "creature":
		_draw_creature_stats(stat_rect)
	else:
		_draw_non_creature_footer(stat_rect, card_type)

	if selected:
		draw_rect(Rect2(1, 1, w - 2, h - 2), Color("7df05a"), false, 4.0)
		draw_rect(Rect2(5, 5, w - 10, h - 10), Color(0.45, 1.0, 0.30, 0.32), false, 2.0)

func _draw_title_plaque(rect: Rect2) -> void:
	draw_rect(rect, Color("160f08"))
	draw_rect(rect, Color("80592a"), false, 1.5)
	var title := str(card.get("name", "CARTA"))
	var font_size := 13
	while font_size > 8 and ThemeDB.fallback_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > rect.size.x - 4:
		font_size -= 1
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 2, rect.position.y + rect.size.y * 0.70), title, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 4, font_size, Color("f5dfad"))

func _draw_effect_panel(rect: Rect2) -> void:
	draw_rect(rect, TEXT_PANEL)
	draw_rect(rect, TEXT_PANEL_DARK, false, 1.5)
	# Ribetes del pergamino.
	draw_line(Vector2(rect.position.x + 5, rect.position.y + 5), Vector2(rect.end.x - 5, rect.position.y + 5), Color(0.35, 0.20, 0.08, 0.30), 1.0)
	draw_line(Vector2(rect.position.x + 5, rect.end.y - 5), Vector2(rect.end.x - 5, rect.end.y - 5), Color(0.35, 0.20, 0.08, 0.30), 1.0)

	var lines := _visible_effect_lines(rect.size)
	var font := ThemeDB.fallback_font
	var line_h := font.get_height(EFFECT_FONT_SIZE)
	var block_h := float(lines.size()) * line_h
	var y := rect.position.y + (rect.size.y - block_h) * 0.5 + font.get_ascent(EFFECT_FONT_SIZE)
	for line in lines:
		draw_string(font, Vector2(rect.position.x + 6, y), line, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, EFFECT_FONT_SIZE, TEXT_INK)
		y += line_h

func _visible_effect_lines(panel_size: Vector2) -> Array[String]:
	var width := maxf(panel_size.x - 12.0, 1.0)
	var lines := _effect_lines(width)
	var max_lines := maxi(1, floori((panel_size.y - 10.0) / ThemeDB.fallback_font.get_height(EFFECT_FONT_SIZE)))
	if lines.size() <= max_lines:
		return lines
	lines.resize(max_lines)
	var last := lines[max_lines - 1].strip_edges()
	while not last.is_empty() and _effect_width(last + "…") > width:
		last = last.left(last.length() - 1).strip_edges()
	lines[max_lines - 1] = last + "…"
	return lines

func _effect_lines(width: float = 164.0) -> Array[String]:
	# Same rules as the full inspection. Only the small physical panel truncates.
	var rules := TextScript.rules_text(card)
	if rules.is_empty():
		rules = TextScript.type_label(card)
	var words := rules.replace("\n", " ").split(" ", false)
	var result: Array[String] = []
	var current := ""
	for word in words:
		var candidate := str(word) if current.is_empty() else "%s %s" % [current, str(word)]
		if _effect_width(candidate) > width and not current.is_empty():
			result.append(current)
			current = str(word)
		else:
			current = candidate
	if not current.is_empty():
		result.append(current)
	return result

func _effect_width(value: String) -> float:
	return ThemeDB.fallback_font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, EFFECT_FONT_SIZE).x

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

const EFFECT_TEXT := {
	"forest_watchful_squirrel": "Si controlas otra Bestia,\nganas 1 Instinto.",
	"forest_call_pack": "Invoca una Cría del Bosque 1/1\ny ganas 1 Instinto.",
	"forest_growth": "Una criatura aliada obtiene\n+2/+2 este turno.",
	"crypt_gravedigger": "Al entrar, ganas 1 Resto.",
	"crypt_broken_skeleton": "Último Aliento: ganas 1 Resto.",
	"crypt_funeral_hound": "Último Aliento: inflige 1 daño\na la criatura enfrentada.",
	"crypt_mourner": "Último Aliento: roba 1 carta.",
	"crypt_ash_offering": "Destruye una criatura aliada.\nRoba 2 cartas.",
	"crypt_exhumation": "Devuelve una criatura de coste 3\no menos desde tu descarte.",
	"tower_familiar": "Al entrar, revela la carta\nsuperior de tu mazo.",
	"tower_rune_bolt": "Inflige 1 daño a una\ncriatura enemiga.",
	"tower_forbidden_vision": "Revela las 3 cartas superiores\ny roba la primera.",
	"forge_worker": "Al entrar, ganas 1 Calor.",
	"forge_spark": "Inflige 1 daño y ganas\n1 Calor.",
	"forge_overload": "Un Constructo aliado obtiene\n+3 ATQ y ganas 2 Calor."
}

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
	var text_h := 70.0
	var art_top := header_h + 4.0
	var art_h := h - header_h - text_h - stats_h - 17.0
	var art_rect := Rect2(11, art_top, w - 22, art_h)
	var text_rect := Rect2(11, art_rect.end.y + 3, w - 22, text_h - 4)
	var stat_rect := Rect2(10, h - stats_h - 5, w - 20, stats_h)

	_draw_cost_badge(Vector2(26, 25), 15.0)
	_draw_title_plaque(Rect2(46, 7, w - 58, 31))
	_draw_art(art_rect)
	_draw_effect_panel(text_rect)

	var card_type := str(card.get("type", ""))
	if card_type == "creature":
		_draw_creature_stats(stat_rect)
	else:
		_draw_non_creature_footer(stat_rect, card_type)

	_draw_canonical_frame(Rect2(0, 0, w, h))
	if selected:
		draw_rect(Rect2(1, 1, w - 2, h - 2), Color("7df05a"), false, 4.0)
		draw_rect(Rect2(5, 5, w - 10, h - 10), Color(0.45, 1.0, 0.30, 0.32), false, 2.0)

func _draw_title_plaque(rect: Rect2) -> void:
	draw_rect(rect, Color("160f08"))
	draw_rect(rect, Color("80592a"), false, 1.5)
	var title := str(card.get("name", "CARTA"))
	var font_size := 11
	if title.length() > 20:
		font_size = 9
	if title.length() > 27:
		font_size = 8
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 2, rect.position.y + rect.size.y * 0.70), title, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 4, font_size, Color("f5dfad"))

func _draw_effect_panel(rect: Rect2) -> void:
	draw_rect(rect, TEXT_PANEL)
	draw_rect(rect, TEXT_PANEL_DARK, false, 1.5)
	# Ribetes del pergamino.
	draw_line(Vector2(rect.position.x + 5, rect.position.y + 5), Vector2(rect.end.x - 5, rect.position.y + 5), Color(0.35, 0.20, 0.08, 0.30), 1.0)
	draw_line(Vector2(rect.position.x + 5, rect.end.y - 5), Vector2(rect.end.x - 5, rect.end.y - 5), Color(0.35, 0.20, 0.08, 0.30), 1.0)

	var lines := _effect_lines()
	var line_h := 14.0
	var block_h := float(lines.size()) * line_h
	var y := rect.position.y + (rect.size.y - block_h) * 0.5 + 10.0
	for line in lines:
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 4, y), line, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 10, TEXT_INK)
		y += line_h

func _effect_lines() -> Array[String]:
	var effect_id := str(card.get("effect_id", ""))
	if EFFECT_TEXT.has(effect_id):
		return _split_known_text(str(EFFECT_TEXT[effect_id]))
	var keywords: Array = card.get("keywords", [])
	if not keywords.is_empty():
		var label := ""
		for keyword in keywords:
			if not label.is_empty():
				label += " · "
			label += str(keyword).replace("_", " ").capitalize()
		return _wrap_text(label, 28)
	var card_type := str(card.get("type", "")).to_upper()
	match card_type:
		"RELIC": card_type = "RELIQUIA"
		"RITE": card_type = "RITO"
		"SEAL": card_type = "SELLO"
	return [card_type]

func _split_known_text(value: String) -> Array[String]:
	var result: Array[String] = []
	for line in value.split("\n"):
		result.append(str(line))
	return result

func _wrap_text(value: String, max_chars: int) -> Array[String]:
	var words := value.split(" ")
	var result: Array[String] = []
	var current := ""
	for word in words:
		var candidate := str(word) if current.is_empty() else "%s %s" % [current, str(word)]
		if candidate.length() > max_chars and not current.is_empty():
			result.append(current)
			current = str(word)
		else:
			current = candidate
	if not current.is_empty():
		result.append(current)
	return result

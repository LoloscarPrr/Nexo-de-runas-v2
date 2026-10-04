class_name VerticalBattleOrnament
extends Control

## Ornamentos vectoriales livianos para acercar la batalla al mockup aprobado
## sin introducir reglas ni depender de nodos del Domain.

enum Mode {
	LOGO,
	RIVAL_CREST,
	HUD_ENERGY,
	HUD_ESSENCE,
	HUD_SEALS,
	HUD_DECK,
	PLAYER_NEXUS,
	TURN_FRAME
}

const GOLD := Color("e0a33f")
const GOLD_DARK := Color("6e4018")
const COPPER := Color("b95c29")
const WOOD := Color("211108")
const WOOD_DARK := Color("0c0906")
const GREEN := Color("1f6f2e")
const GREEN_GLOW := Color("74ef59")
const PARCHMENT := Color("e4d09a")
const RED := Color("9c2b24")
const BONE := Color("d1c59b")

var mode: Mode = Mode.LOGO
var accent := GREEN_GLOW

func configure(next_mode: Mode, next_accent: Color = GREEN_GLOW) -> void:
	mode = next_mode
	accent = next_accent
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if size.x < 4.0 or size.y < 4.0:
		return
	match mode:
		Mode.LOGO:
			_draw_logo_plaque()
		Mode.RIVAL_CREST:
			_draw_rival_crest()
		Mode.HUD_ENERGY:
			_draw_energy_icon()
		Mode.HUD_ESSENCE:
			_draw_paw_icon()
		Mode.HUD_SEALS:
			_draw_seals_icon()
		Mode.HUD_DECK:
			_draw_deck_icon()
		Mode.PLAYER_NEXUS:
			_draw_player_nexus()
		Mode.TURN_FRAME:
			_draw_turn_frame()

func _draw_logo_plaque() -> void:
	var r := Rect2(2, 2, size.x - 4, size.y - 4)
	draw_rect(r, Color(0.02, 0.015, 0.01, 0.90))
	draw_rect(r.grow(-4), WOOD)
	draw_rect(r.grow(-2), GOLD_DARK, false, 3.0)
	draw_rect(r.grow(-7), Color("4b2b11"), false, 1.5)
	var cy := size.y * 0.5
	draw_line(Vector2(16, cy), Vector2(size.x - 16, cy), Color(0.75, 0.34, 0.10, 0.45), 2.0)
	_draw_diamond(Vector2(14, cy), 9.0, COPPER)
	_draw_diamond(Vector2(size.x - 14, cy), 9.0, COPPER)
	_draw_diamond(Vector2(size.x * 0.5, 11), 7.0, Color("d14e20"))
	_draw_diamond(Vector2(size.x * 0.5, size.y - 11), 7.0, Color("d14e20"))
	for x in [size.x * 0.20, size.x * 0.80]:
		draw_arc(Vector2(x, cy), 18.0, -1.0, 1.0, 18, GOLD, 2.0)

func _draw_rival_crest() -> void:
	var c := size * 0.5
	var w := minf(size.x, size.y) * 0.43
	var shield := PackedVector2Array([
		c + Vector2(-w * 0.72, -w),
		c + Vector2(w * 0.72, -w),
		c + Vector2(w, -w * 0.20),
		c + Vector2(w * 0.55, w * 0.80),
		c + Vector2(0, w * 1.18),
		c + Vector2(-w * 0.55, w * 0.80),
		c + Vector2(-w, -w * 0.20)
	])
	draw_colored_polygon(shield, Color("0f4b25"))
	var outline := PackedVector2Array(shield)
	outline.append(shield[0])
	draw_polyline(outline, GOLD, 4.0, true)
	# Árbol rúnico.
	draw_line(c + Vector2(0, -w * 0.55), c + Vector2(0, w * 0.55), Color("b8f5b0"), 5.0)
	for y in [-0.32, -0.05, 0.18]:
		var yy := w * float(y)
		draw_line(c + Vector2(0, yy), c + Vector2(-w * 0.42, yy - w * 0.24), Color("b8f5b0"), 4.0)
		draw_line(c + Vector2(0, yy), c + Vector2(w * 0.42, yy - w * 0.24), Color("b8f5b0"), 4.0)
	draw_line(c + Vector2(0, w * 0.50), c + Vector2(-w * 0.35, w * 0.82), Color("b8f5b0"), 4.0)
	draw_line(c + Vector2(0, w * 0.50), c + Vector2(w * 0.35, w * 0.82), Color("b8f5b0"), 4.0)

func _draw_energy_icon() -> void:
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.30
	_draw_medallion(c, radius, Color("0c3f1d"), GREEN_GLOW)
	var hex := PackedVector2Array()
	for i in range(6):
		var a := -PI / 2.0 + TAU * float(i) / 6.0
		hex.append(c + Vector2(cos(a), sin(a)) * radius * 0.58)
	hex.append(hex[0])
	draw_polyline(hex, Color("c8ffb9"), 3.0, true)
	draw_circle(c, radius * 0.16, Color("baff9b"))

func _draw_paw_icon() -> void:
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.30
	_draw_medallion(c, radius, Color("4d220e"), Color("f2aa34"))
	draw_circle(c + Vector2(0, radius * 0.18), radius * 0.29, Color("f3ba45"))
	for off in [Vector2(-0.38, -0.22), Vector2(-0.13, -0.42), Vector2(0.15, -0.42), Vector2(0.39, -0.20)]:
		draw_circle(c + off * radius, radius * 0.14, Color("f3ba45"))

func _draw_seals_icon() -> void:
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.25
	for i in range(3):
		var cc := c + Vector2((float(i) - 1.0) * radius * 1.15, 0)
		draw_circle(cc, radius * 0.58, Color("2b2413"))
		draw_arc(cc, radius * 0.58, 0, TAU, 28, GOLD, 2.0)
		if i == 0:
			draw_line(cc + Vector2(-radius * 0.28, radius * 0.22), cc + Vector2(radius * 0.30, -radius * 0.24), Color("f1cc53"), 3.0)
		elif i == 1:
			draw_line(cc + Vector2(0, -radius * 0.30), cc + Vector2(0, radius * 0.28), GREEN_GLOW, 3.0)
			draw_line(cc, cc + Vector2(-radius * 0.24, -radius * 0.10), GREEN_GLOW, 3.0)
			draw_line(cc, cc + Vector2(radius * 0.24, -radius * 0.10), GREEN_GLOW, 3.0)
		else:
			draw_arc(cc, radius * 0.24, -PI * 0.2, PI * 1.25, 18, Color("d99245"), 3.0)

func _draw_deck_icon() -> void:
	var c := size * 0.5
	var card_size := Vector2(size.x * 0.31, size.y * 0.52)
	for off in [Vector2(-9, 4), Vector2(7, -4)]:
		var r := Rect2(c + off - card_size * 0.5, card_size)
		draw_rect(r, Color("302016"))
		draw_rect(r, GOLD, false, 2.0)
		_draw_diamond(r.get_center(), minf(r.size.x, r.size.y) * 0.18, Color("8b5c38"))

func _draw_player_nexus() -> void:
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.43
	for mul in [1.0, 0.82, 0.66]:
		var m := float(mul)
		draw_circle(c, radius * m, Color(0.05, 0.28 + 0.10 * (1.0 - m), 0.10, 0.72))
		draw_arc(c, radius * m, 0, TAU, 64, Color(GOLD.r, GOLD.g, GOLD.b, 0.85), 2.0)
	for i in range(10):
		var a := TAU * float(i) / 10.0
		var p1 := c + Vector2(cos(a), sin(a)) * radius * 0.75
		var p2 := c + Vector2(cos(a), sin(a)) * radius * 0.94
		draw_line(p1, p2, Color(0.35, 1.0, 0.28, 0.55), 2.0)
	# Cráneo estilizado.
	var s := radius * 0.50
	var skull := PackedVector2Array([
		c + Vector2(-s * 0.55, -s * 0.46), c + Vector2(-s * 0.25, -s * 0.72),
		c + Vector2(s * 0.25, -s * 0.72), c + Vector2(s * 0.55, -s * 0.46),
		c + Vector2(s * 0.45, s * 0.28), c + Vector2(0, s * 0.72),
		c + Vector2(-s * 0.45, s * 0.28)
	])
	draw_colored_polygon(skull, BONE)
	var ol := PackedVector2Array(skull)
	ol.append(skull[0])
	draw_polyline(ol, Color("5a4c31"), 3.0, true)
	draw_circle(c + Vector2(-s * 0.22, -s * 0.18), s * 0.13, Color("11210f"))
	draw_circle(c + Vector2(s * 0.22, -s * 0.18), s * 0.13, Color("11210f"))

func _draw_turn_frame() -> void:
	var r := Rect2(2, 2, size.x - 4, size.y - 4)
	draw_rect(r, WOOD_DARK)
	draw_rect(r.grow(-3), GOLD_DARK, false, 5.0)
	draw_rect(r.grow(-10), Color("54280f"), false, 3.0)
	for c in [Vector2(15, 15), Vector2(size.x - 15, 15), Vector2(15, size.y - 15), Vector2(size.x - 15, size.y - 15)]:
		_draw_diamond(c, 8.0, GOLD)
	var left := PackedVector2Array([Vector2(8, size.y * 0.5), Vector2(28, size.y * 0.36), Vector2(28, size.y * 0.64)])
	var right := PackedVector2Array([Vector2(size.x - 8, size.y * 0.5), Vector2(size.x - 28, size.y * 0.36), Vector2(size.x - 28, size.y * 0.64)])
	draw_colored_polygon(left, Color("a85d23"))
	draw_colored_polygon(right, Color("a85d23"))

func _draw_medallion(c: Vector2, radius: float, fill: Color, border: Color) -> void:
	draw_circle(c + Vector2(2, 3), radius + 4.0, Color(0, 0, 0, 0.45))
	draw_circle(c, radius + 3.0, GOLD_DARK)
	draw_circle(c, radius, fill)
	draw_arc(c, radius, 0, TAU, 40, border, 2.5)

func _draw_diamond(c: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		c + Vector2(0, -radius), c + Vector2(radius, 0),
		c + Vector2(0, radius), c + Vector2(-radius, 0)
	])
	draw_colored_polygon(points, color)
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	draw_polyline(outline, Color("ffd273"), 1.5, true)

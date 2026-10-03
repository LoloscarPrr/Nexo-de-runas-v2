class_name VerticalBattleBackdrop
extends Control

## Escenario procedural del Bosque para la Presentation vertical.
## Es puramente decorativo: no contiene estado ni reglas de batalla.

const NIGHT := Color("07100b")
const NIGHT_2 := Color("0b1710")
const BARK := Color("1b120a")
const BARK_LIGHT := Color("3a2512")
const MOSS := Color("264225")
const VINE := Color("4f6e37")
const GOLD := Color("8f6127")
const FIRE := Color("ff9a3c")
const FIRE_SOFT := Color(1.0, 0.45, 0.10, 0.10)
const RUNE := Color(0.45, 0.88, 0.34, 0.18)
const BONE := Color("b5aa83")
const BONE_DARK := Color("5d533c")
const EYE_GLOW := Color("72f14d")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 1.0 or h <= 1.0:
		return

	draw_rect(Rect2(0, 0, w, h), NIGHT)
	for band in range(10):
		var y: float = h * float(band) / 10.0
		var alpha: float = 0.02 + float(band) * 0.006
		draw_rect(Rect2(0, y, w, h / 10.0 + 1.0), Color(NIGHT_2.r, NIGHT_2.g, NIGHT_2.b, alpha + 0.12))

	_draw_tree_column(Rect2(0, 0, w * 0.075, h), false)
	_draw_tree_column(Rect2(w * 0.925, 0, w * 0.075, h), true)

	# El Guardabosques ocupa el centro superior del mockup. Se dibuja como
	# silueta ritual para que el fondo siga siendo liviano y no dependa de arte.
	_draw_guardian(Vector2(w * 0.50, minf(h * 0.095, 195.0)), minf(w * 0.18, 150.0))
	_draw_candle_cluster(Vector2(w * 0.18, minf(h * 0.12, 235.0)), 1.0)
	_draw_candle_cluster(Vector2(w * 0.82, minf(h * 0.12, 235.0)), 0.95)

	var center := Vector2(w * 0.5, h * 0.43)
	var rune_radius: float = minf(w, h) * 0.105
	draw_circle(center, rune_radius * 1.6, Color(RUNE.r, RUNE.g, RUNE.b, 0.035))
	draw_arc(center, rune_radius, 0, TAU, 64, RUNE, 2.0)
	draw_arc(center, rune_radius * 0.64, 0, TAU, 48, Color(RUNE.r, RUNE.g, RUNE.b, 0.12), 1.4)
	for angle in [0.0, PI / 2.0, PI, PI * 1.5]:
		var a: Vector2 = center + Vector2(cos(angle), sin(angle)) * rune_radius * 0.68
		var b: Vector2 = center + Vector2(cos(angle), sin(angle)) * rune_radius * 0.94
		draw_line(a, b, RUNE, 2.0)

	_draw_lantern(Vector2(w * 0.07, h * 0.18), minf(w, h) * 0.017)
	_draw_lantern(Vector2(w * 0.93, h * 0.20), minf(w, h) * 0.018)
	_draw_lantern(Vector2(w * 0.055, h * 0.72), minf(w, h) * 0.014)
	_draw_lantern(Vector2(w * 0.945, h * 0.76), minf(w, h) * 0.014)

	_draw_vine(PackedVector2Array([
		Vector2(w * 0.03, h * 0.08), Vector2(w * 0.15, h * 0.13), Vector2(w * 0.22, h * 0.08), Vector2(w * 0.35, h * 0.12)
	]))
	_draw_vine(PackedVector2Array([
		Vector2(w * 0.97, h * 0.11), Vector2(w * 0.85, h * 0.16), Vector2(w * 0.78, h * 0.10), Vector2(w * 0.67, h * 0.14)
	]))

	# Viñeta para mantener legibilidad sobre la escena.
	draw_rect(Rect2(0, h * 0.26, w, h * 0.56), Color(0, 0, 0, 0.10))
	draw_rect(Rect2(0, h * 0.82, w, h * 0.18), Color(0, 0, 0, 0.22))

func _draw_guardian(center: Vector2, scale: float) -> void:
	var s: float = scale / 150.0
	for offset in [Vector2(-62, -4), Vector2(62, -4), Vector2(-48, 34), Vector2(48, 34), Vector2(0, 48)]:
		var leaf_offset: Vector2 = offset
		draw_circle(center + leaf_offset * s, 38.0 * s, Color(0.08, 0.20, 0.08, 0.78))
		draw_circle(center + leaf_offset * s, 26.0 * s, Color(0.13, 0.29, 0.12, 0.72))

	var horn := Color("5c3a1a")
	var horn_hi := Color("9a6d38")
	for direction in [-1.0, 1.0]:
		var dir: float = float(direction)
		var root: Vector2 = center + Vector2(28.0 * dir, -35.0) * s
		var p1: Vector2 = center + Vector2(70.0 * dir, -78.0) * s
		var p2: Vector2 = center + Vector2(102.0 * dir, -118.0) * s
		var p3: Vector2 = center + Vector2(126.0 * dir, -150.0) * s
		draw_polyline(PackedVector2Array([root, p1, p2, p3]), horn, 9.0 * s, true)
		draw_polyline(PackedVector2Array([root, p1, p2]), horn_hi, 2.2 * s, true)
		draw_line(p1, p1 + Vector2(12.0 * dir, -46.0) * s, horn, 7.0 * s)
		draw_line(p2, p2 + Vector2(26.0 * dir, -34.0) * s, horn, 6.0 * s)
		draw_line(p2, p2 + Vector2(-4.0 * dir, -52.0) * s, horn, 5.0 * s)

	var skull := PackedVector2Array([
		center + Vector2(-42, -56) * s,
		center + Vector2(-24, -76) * s,
		center + Vector2(0, -84) * s,
		center + Vector2(24, -76) * s,
		center + Vector2(42, -56) * s,
		center + Vector2(34, -8) * s,
		center + Vector2(18, 48) * s,
		center + Vector2(0, 84) * s,
		center + Vector2(-18, 48) * s,
		center + Vector2(-34, -8) * s
	])
	draw_colored_polygon(skull, BONE)
	var skull_outline := PackedVector2Array()
	for point in skull:
		skull_outline.append(point)
	skull_outline.append(skull[0])
	draw_polyline(skull_outline, BONE_DARK, 4.0 * s, true)
	draw_circle(center + Vector2(-19, -35) * s, 12.0 * s, Color("17160e"))
	draw_circle(center + Vector2(19, -35) * s, 12.0 * s, Color("17160e"))
	draw_circle(center + Vector2(-19, -35) * s, 5.0 * s, EYE_GLOW)
	draw_circle(center + Vector2(19, -35) * s, 5.0 * s, EYE_GLOW)
	draw_line(center + Vector2(0, -10) * s, center + Vector2(0, 55) * s, BONE_DARK, 3.0 * s)
	draw_line(center + Vector2(-12, 18) * s, center + Vector2(12, 18) * s, BONE_DARK, 2.0 * s)

func _draw_candle_cluster(center: Vector2, scale: float) -> void:
	var offsets := PackedVector2Array([Vector2(-34, 10), Vector2(-15, -10), Vector2(5, 5), Vector2(25, -18), Vector2(42, 12)])
	for item in offsets:
		var p: Vector2 = center + item * scale
		var candle_h: float = (32.0 + absf(item.y) * 0.55) * scale
		draw_rect(Rect2(p.x - 5 * scale, p.y - candle_h, 10 * scale, candle_h), Color("c99b66"))
		draw_circle(Vector2(p.x, p.y - candle_h - 5 * scale), 5.0 * scale, FIRE)
		draw_circle(Vector2(p.x, p.y - candle_h - 5 * scale), 2.0 * scale, Color("fff0aa"))

func _draw_tree_column(rect: Rect2, mirror: bool) -> void:
	draw_rect(rect, BARK)
	draw_rect(rect.grow(-5), BARK_LIGHT)
	var x: float = rect.end.x - 4.0 if mirror else rect.position.x + 4.0
	for i in range(6):
		var yy: float = rect.position.y + rect.size.y * (0.08 + float(i) * 0.16)
		var branch_end: Vector2 = Vector2(rect.position.x - rect.size.x * 0.45, yy - 32) if mirror else Vector2(rect.end.x + rect.size.x * 0.45, yy - 32)
		draw_line(Vector2(x, yy), branch_end, BARK_LIGHT, 5.0)
	for i in range(12):
		var yy2: float = rect.position.y + rect.size.y * float(i) / 12.0
		draw_line(Vector2(rect.position.x + rect.size.x * 0.22, yy2), Vector2(rect.position.x + rect.size.x * 0.64, yy2 + 54), Color(0.05, 0.02, 0.01, 0.28), 2.0)

func _draw_lantern(center: Vector2, radius: float) -> void:
	for mul in [4.6, 3.4, 2.5]:
		draw_circle(center, radius * float(mul), FIRE_SOFT)
	var body := Rect2(center.x - radius * 0.72, center.y - radius * 1.45, radius * 1.44, radius * 2.55)
	draw_rect(body, Color("2b1b0d"))
	draw_rect(body.grow(-2), Color("713a16"), false, 2.0)
	draw_circle(center, radius * 0.60, Color(FIRE.r, FIRE.g, FIRE.b, 0.90))
	draw_circle(center, radius * 0.28, Color("fff0a8"))
	draw_line(Vector2(body.position.x, body.position.y), Vector2(body.end.x, body.position.y), GOLD, 2.0)
	draw_line(Vector2(body.position.x, body.end.y), Vector2(body.end.x, body.end.y), GOLD, 2.0)

func _draw_vine(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, VINE, 4.0, true)
	for i in range(points.size()):
		var p: Vector2 = points[i]
		draw_circle(p + Vector2(8 if i % 2 == 0 else -8, -4), 5.0, MOSS)

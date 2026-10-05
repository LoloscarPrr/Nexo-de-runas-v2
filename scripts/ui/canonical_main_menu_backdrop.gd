class_name CanonicalMainMenuBackdrop
extends Control

## Escena vertical del menú principal. Es puramente decorativa: Guardián/Nexo,
## raíces, velas, brillo rúnico y altar inferior para que la UI parezca habitar
## el mundo en vez de flotar sobre paneles.

var phase := 0.0

const NIGHT := Color("050a06")
const NIGHT_GREEN := Color("09150d")
const BARK := Color("1d1209")
const BARK_LIGHT := Color("382310")
const MOSS := Color("2d4e2b")
const VINE := Color("4b6737")
const GOLD := Color("a56e2e")
const FIRE := Color("ff9a3f")
const BONE := Color("b9ad82")
const BONE_DARK := Color("554b34")
const EYE := Color("70ef54")
const RUNE := Color("70f05b")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 1.0 or s.y <= 1.0:
		return

	# Profundidad vertical: negro verdoso arriba, santuario cálido abajo.
	draw_rect(Rect2(Vector2.ZERO, s), NIGHT)
	for band in range(16):
		var y := s.y * float(band) / 16.0
		var t := float(band) / 15.0
		var shade := Color(
			lerpf(NIGHT_GREEN.r, 0.10, t),
			lerpf(NIGHT_GREEN.g, 0.075, t),
			lerpf(NIGHT_GREEN.b, 0.035, t),
			0.14
		)
		draw_rect(Rect2(0, y, s.x, s.y / 16.0 + 1), shade)

	_draw_tree_column(Rect2(0, 0, s.x * 0.07, s.y), false)
	_draw_tree_column(Rect2(s.x * 0.93, 0, s.x * 0.07, s.y), true)

	# Halo ritual detrás del Guardián; ahora es más ancho y luminoso.
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.265), s.x * 0.46, Color(0.20, 0.58, 0.14, 0.13))
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.265), s.x * 0.29, Color(0.42, 0.95, 0.28, 0.08))
	_draw_nexus_ring(Vector2(s.x * 0.50, s.y * 0.275), minf(s.x * 0.31, 245.0))
	_draw_guardian(Vector2(s.x * 0.50, s.y * 0.265), minf(s.x * 0.34, 255.0))

	# Luz lateral y velas a distintas profundidades.
	_draw_candle_cluster(Vector2(s.x * 0.13, s.y * 0.33), 1.0)
	_draw_candle_cluster(Vector2(s.x * 0.87, s.y * 0.34), 0.92)
	_draw_candle_cluster(Vector2(s.x * 0.09, s.y * 0.79), 1.28)
	_draw_candle_cluster(Vector2(s.x * 0.91, s.y * 0.82), 1.18)
	_draw_lantern(Vector2(s.x * 0.065, s.y * 0.49), s.x * 0.018)
	_draw_lantern(Vector2(s.x * 0.935, s.y * 0.50), s.x * 0.018)

	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.02, s.y * 0.09), Vector2(s.x * 0.15, s.y * 0.14), Vector2(s.x * 0.26, s.y * 0.11), Vector2(s.x * 0.39, s.y * 0.17)
	]))
	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.98, s.y * 0.10), Vector2(s.x * 0.84, s.y * 0.15), Vector2(s.x * 0.73, s.y * 0.11), Vector2(s.x * 0.61, s.y * 0.17)
	]))

	# Escenario inferior: altar, raíces en primer plano y runas que aprovechan el
	# tercio bajo sin robar contraste a los botones secundarios.
	var altar_y := s.y * 0.73
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.89), s.x * 0.42, Color(0.95, 0.43, 0.11, 0.065))
	draw_colored_polygon(PackedVector2Array([
		Vector2(s.x * 0.05, altar_y), Vector2(s.x * 0.95, altar_y), Vector2(s.x, s.y), Vector2(0, s.y)
	]), Color("171008"))
	draw_line(Vector2(s.x * 0.04, altar_y), Vector2(s.x * 0.96, altar_y), Color(0.60, 0.40, 0.17, 0.52), 3.0)

	for i in range(5):
		var yy := altar_y + (s.y - altar_y) * float(i + 1) / 6.0
		draw_line(Vector2(s.x * 0.03, yy), Vector2(s.x * 0.97, yy), Color(0.48, 0.28, 0.10, 0.11), 2.0)

	_draw_root(Vector2(s.x * 0.02, s.y * 0.96), Vector2(s.x * 0.43, s.y * 0.77), false)
	_draw_root(Vector2(s.x * 0.98, s.y * 0.97), Vector2(s.x * 0.57, s.y * 0.78), true)
	_draw_root(Vector2(s.x * 0.23, s.y), Vector2(s.x * 0.47, s.y * 0.84), false)
	_draw_root(Vector2(s.x * 0.78, s.y), Vector2(s.x * 0.53, s.y * 0.84), true)

	for rune in [
		Vector2(s.x * 0.18, s.y * 0.88),
		Vector2(s.x * 0.50, s.y * 0.92),
		Vector2(s.x * 0.82, s.y * 0.88)
	]:
		_draw_floor_rune(rune, minf(s.x * 0.045, 32.0))

	# Viñeta leve: sólo en bordes; el centro heroico queda abierto.
	draw_rect(Rect2(0, 0, s.x, s.y * 0.075), Color(0, 0, 0, 0.19))
	draw_rect(Rect2(0, s.y * 0.965, s.x, s.y * 0.035), Color(0, 0, 0, 0.16))

func _draw_nexus_ring(center: Vector2, radius: float) -> void:
	var pulse := 0.78 + sin(phase * 1.7) * 0.10
	for i in range(4):
		var r := radius * (0.72 + float(i) * 0.085)
		draw_arc(center, r, 0.0, TAU, 64, Color(RUNE.r, RUNE.g, RUNE.b, 0.06 + float(i) * 0.025), 2.0)
	for spoke in range(8):
		var angle := TAU * float(spoke) / 8.0 + phase * 0.018
		var a := center + Vector2(cos(angle), sin(angle)) * radius * 0.66
		var b := center + Vector2(cos(angle), sin(angle)) * radius * 0.88
		draw_line(a, b, Color(RUNE.r, RUNE.g, RUNE.b, 0.15 * pulse), 2.0)
	var diamond := PackedVector2Array([
		center + Vector2(0, -radius * 0.38),
		center + Vector2(radius * 0.24, 0),
		center + Vector2(0, radius * 0.38),
		center + Vector2(-radius * 0.24, 0),
		center + Vector2(0, -radius * 0.38)
	])
	draw_polyline(diamond, Color(RUNE.r, RUNE.g, RUNE.b, 0.34 * pulse), 3.0, true)

func _draw_guardian(center: Vector2, scale: float) -> void:
	var s := scale / 170.0
	for offset in [Vector2(-58, 8), Vector2(58, 8), Vector2(-42, 42), Vector2(42, 42), Vector2(0, 55)]:
		var p: Vector2 = center + offset * s
		draw_circle(p, 41.0 * s, Color(0.07, 0.19, 0.08, 0.48))
		draw_circle(p, 28.0 * s, Color(0.14, 0.34, 0.13, 0.34))

	for direction in [-1.0, 1.0]:
		var dir := float(direction)
		var root := center + Vector2(26.0 * dir, -40.0) * s
		var p1 := center + Vector2(72.0 * dir, -87.0) * s
		var p2 := center + Vector2(111.0 * dir, -137.0) * s
		var p3 := center + Vector2(139.0 * dir, -183.0) * s
		draw_polyline(PackedVector2Array([root, p1, p2, p3]), Color("5c3819"), 10.0 * s, true)
		draw_polyline(PackedVector2Array([root, p1, p2]), Color("a8773c"), 2.5 * s, true)
		draw_line(p1, p1 + Vector2(13.0 * dir, -49.0) * s, Color("5c3819"), 7.0 * s)
		draw_line(p2, p2 + Vector2(28.0 * dir, -36.0) * s, Color("5c3819"), 6.0 * s)

	var skull := PackedVector2Array([
		center + Vector2(-43, -59) * s,
		center + Vector2(-24, -78) * s,
		center + Vector2(0, -86) * s,
		center + Vector2(24, -78) * s,
		center + Vector2(43, -59) * s,
		center + Vector2(34, -5) * s,
		center + Vector2(17, 52) * s,
		center + Vector2(0, 88) * s,
		center + Vector2(-17, 52) * s,
		center + Vector2(-34, -5) * s
	])
	var translucent_bone := Color(BONE.r, BONE.g, BONE.b, 0.82)
	draw_colored_polygon(skull, translucent_bone)
	var outline := skull.duplicate()
	outline.append(skull[0])
	draw_polyline(outline, Color(BONE_DARK.r, BONE_DARK.g, BONE_DARK.b, 0.88), 4.5 * s, true)
	draw_circle(center + Vector2(-19, -36) * s, 12.0 * s, Color(0.03, 0.04, 0.02, 0.90))
	draw_circle(center + Vector2(19, -36) * s, 12.0 * s, Color(0.03, 0.04, 0.02, 0.90))
	_draw_glow(center + Vector2(-19, -36) * s, 18.0 * s, Color(EYE.r, EYE.g, EYE.b, 0.13))
	_draw_glow(center + Vector2(19, -36) * s, 18.0 * s, Color(EYE.r, EYE.g, EYE.b, 0.13))
	draw_circle(center + Vector2(-19, -36) * s, 5.2 * s, EYE)
	draw_circle(center + Vector2(19, -36) * s, 5.2 * s, EYE)

func _draw_tree_column(rect: Rect2, mirror: bool) -> void:
	draw_rect(rect, BARK)
	draw_rect(rect.grow(-5), BARK_LIGHT)
	var x := rect.end.x - 5.0 if mirror else rect.position.x + 5.0
	for i in range(8):
		var yy := rect.position.y + rect.size.y * (0.05 + float(i) * 0.125)
		var branch_end := Vector2(rect.position.x - rect.size.x * 0.58, yy - 34) if mirror else Vector2(rect.end.x + rect.size.x * 0.58, yy - 34)
		draw_line(Vector2(x, yy), branch_end, BARK_LIGHT, 5.0)

func _draw_candle_cluster(center: Vector2, scale: float) -> void:
	var offsets := PackedVector2Array([Vector2(-32, 9), Vector2(-14, -12), Vector2(5, 5), Vector2(23, -18), Vector2(40, 10)])
	for item in offsets:
		var p := center + item * scale
		var candle_h := (30.0 + absf(item.y) * 0.52) * scale
		draw_rect(Rect2(p.x - 5 * scale, p.y - candle_h, 10 * scale, candle_h), Color("c89a64"))
		var flicker := sin(phase * 4.0 + p.x * 0.01) * 2.5 * scale
		_draw_glow(Vector2(p.x + flicker * 0.2, p.y - candle_h - 6 * scale), 31.0 * scale, Color(1.0, 0.50, 0.12, 0.11))
		draw_circle(Vector2(p.x + flicker, p.y - candle_h - 6 * scale), 5.0 * scale, FIRE)
		draw_circle(Vector2(p.x + flicker * 0.6, p.y - candle_h - 7 * scale), 2.0 * scale, Color("fff2b0"))

func _draw_lantern(center: Vector2, radius: float) -> void:
	_draw_glow(center, radius * 5.2, Color(1.0, 0.45, 0.10, 0.10))
	var body := Rect2(center.x - radius * 0.72, center.y - radius * 1.45, radius * 1.44, radius * 2.55)
	draw_rect(body, Color("2b1b0d"))
	draw_rect(body.grow(-2), Color("713a16"), false, 2.0)
	draw_circle(center, radius * 0.60, Color(FIRE.r, FIRE.g, FIRE.b, 0.88))
	draw_circle(center, radius * 0.27, Color("fff0a8"))

func _draw_vine(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, VINE, 4.0, true)
	for i in range(points.size()):
		var p := points[i]
		draw_circle(p + Vector2(8 if i % 2 == 0 else -8, -4), 5.0, MOSS)

func _draw_root(start: Vector2, finish: Vector2, mirror: bool) -> void:
	var bend := Vector2(42.0 if not mirror else -42.0, -36.0)
	var mid := (start + finish) * 0.5 + bend
	var points := PackedVector2Array([start, mid, finish])
	draw_polyline(points, Color("2b180b"), 13.0, true)
	draw_polyline(points, Color("5b3416"), 4.0, true)

func _draw_floor_rune(center: Vector2, radius: float) -> void:
	var pulse := 0.70 + sin(phase * 2.0 + center.x * 0.01) * 0.18
	_draw_glow(center, radius * 2.0, Color(RUNE.r, RUNE.g, RUNE.b, 0.06 * pulse))
	draw_arc(center, radius, 0.0, TAU, 24, Color(RUNE.r, RUNE.g, RUNE.b, 0.25 * pulse), 2.0)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), Color(RUNE.r, RUNE.g, RUNE.b, 0.30 * pulse), 2.0)
	draw_line(center + Vector2(-radius * 0.55, 0), center + Vector2(radius * 0.55, 0), Color(RUNE.r, RUNE.g, RUNE.b, 0.30 * pulse), 2.0)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var f := float(i) / 7.0
		var c := color
		c.a *= 1.0 - f * 0.78
		draw_circle(center, radius * f, c)

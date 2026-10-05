class_name CanonicalMainMenuBackdrop
extends Control

## Fondo vertical del menú principal. Es puramente decorativo y comparte el
## lenguaje visual Bosque/Nexo con la batalla canónica.

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

	draw_rect(Rect2(Vector2.ZERO, s), NIGHT)
	for band in range(12):
		var y := s.y * float(band) / 12.0
		var shade := Color(NIGHT_GREEN.r, NIGHT_GREEN.g, NIGHT_GREEN.b, 0.10 + float(band) * 0.008)
		draw_rect(Rect2(0, y, s.x, s.y / 12.0 + 1), shade)

	# Troncos laterales: en retrato enmarcan la navegación en vez de ensancharla.
	_draw_tree_column(Rect2(0, 0, s.x * 0.075, s.y), false)
	_draw_tree_column(Rect2(s.x * 0.925, 0, s.x * 0.075, s.y), true)

	# Halo verde central para dar profundidad detrás del logo y del héroe.
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.23), s.x * 0.42, Color(0.22, 0.45, 0.14, 0.10))
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.58), s.x * 0.34, Color(0.16, 0.30, 0.10, 0.05))

	# Guardián ritual muy grande, pero tenue: sirve de identidad sin competir con botones.
	_draw_guardian(Vector2(s.x * 0.50, s.y * 0.25), minf(s.x * 0.25, 185.0))

	_draw_candle_cluster(Vector2(s.x * 0.16, s.y * 0.30), 1.05)
	_draw_candle_cluster(Vector2(s.x * 0.84, s.y * 0.30), 0.95)
	_draw_lantern(Vector2(s.x * 0.075, s.y * 0.44), s.x * 0.018)
	_draw_lantern(Vector2(s.x * 0.925, s.y * 0.46), s.x * 0.018)
	_draw_lantern(Vector2(s.x * 0.08, s.y * 0.82), s.x * 0.015)
	_draw_lantern(Vector2(s.x * 0.92, s.y * 0.84), s.x * 0.015)

	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.04, s.y * 0.10), Vector2(s.x * 0.18, s.y * 0.15), Vector2(s.x * 0.28, s.y * 0.11), Vector2(s.x * 0.38, s.y * 0.16)
	]))
	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.96, s.y * 0.11), Vector2(s.x * 0.82, s.y * 0.16), Vector2(s.x * 0.72, s.y * 0.11), Vector2(s.x * 0.62, s.y * 0.16)
	]))

	# Piso/altar bajo para evitar la sensación de fondo negro vacío.
	var altar_y := s.y * 0.88
	draw_colored_polygon(PackedVector2Array([
		Vector2(s.x * 0.07, altar_y), Vector2(s.x * 0.93, altar_y), Vector2(s.x, s.y), Vector2(0, s.y)
	]), Color("181008"))
	draw_line(Vector2(0, altar_y), Vector2(s.x, altar_y), Color(0.56, 0.34, 0.14, 0.45), 3.0)
	for i in range(4):
		var yy := altar_y + (s.y - altar_y) * float(i + 1) / 5.0
		draw_line(Vector2(s.x * 0.04, yy), Vector2(s.x * 0.96, yy), Color(0.45, 0.28, 0.10, 0.13), 2.0)

	# Viñeta sutil para legibilidad.
	draw_rect(Rect2(0, 0, s.x, s.y * 0.11), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(0, s.y * 0.86, s.x, s.y * 0.14), Color(0, 0, 0, 0.12))

func _draw_guardian(center: Vector2, scale: float) -> void:
	var s := scale / 170.0
	for offset in [Vector2(-58, 8), Vector2(58, 8), Vector2(-42, 42), Vector2(42, 42), Vector2(0, 55)]:
		var p: Vector2 = center + offset * s
		draw_circle(p, 41.0 * s, Color(0.07, 0.19, 0.08, 0.34))
		draw_circle(p, 28.0 * s, Color(0.14, 0.31, 0.13, 0.24))

	for direction in [-1.0, 1.0]:
		var dir := float(direction)
		var root := center + Vector2(26.0 * dir, -40.0) * s
		var p1 := center + Vector2(72.0 * dir, -87.0) * s
		var p2 := center + Vector2(111.0 * dir, -137.0) * s
		var p3 := center + Vector2(139.0 * dir, -183.0) * s
		draw_polyline(PackedVector2Array([root, p1, p2, p3]), Color("5c3819"), 10.0 * s, true)
		draw_polyline(PackedVector2Array([root, p1, p2]), Color("926436"), 2.0 * s, true)
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
	var translucent_bone := Color(BONE.r, BONE.g, BONE.b, 0.62)
	draw_colored_polygon(skull, translucent_bone)
	var outline := skull.duplicate()
	outline.append(skull[0])
	draw_polyline(outline, Color(BONE_DARK.r, BONE_DARK.g, BONE_DARK.b, 0.66), 4.0 * s, true)
	draw_circle(center + Vector2(-19, -36) * s, 12.0 * s, Color(0.03, 0.04, 0.02, 0.78))
	draw_circle(center + Vector2(19, -36) * s, 12.0 * s, Color(0.03, 0.04, 0.02, 0.78))
	draw_circle(center + Vector2(-19, -36) * s, 4.7 * s, Color(EYE.r, EYE.g, EYE.b, 0.72))
	draw_circle(center + Vector2(19, -36) * s, 4.7 * s, Color(EYE.r, EYE.g, EYE.b, 0.72))

func _draw_tree_column(rect: Rect2, mirror: bool) -> void:
	draw_rect(rect, BARK)
	draw_rect(rect.grow(-5), BARK_LIGHT)
	var x := rect.end.x - 5.0 if mirror else rect.position.x + 5.0
	for i in range(7):
		var yy := rect.position.y + rect.size.y * (0.06 + float(i) * 0.145)
		var branch_end := Vector2(rect.position.x - rect.size.x * 0.50, yy - 34) if mirror else Vector2(rect.end.x + rect.size.x * 0.50, yy - 34)
		draw_line(Vector2(x, yy), branch_end, BARK_LIGHT, 5.0)

func _draw_candle_cluster(center: Vector2, scale: float) -> void:
	var offsets := PackedVector2Array([Vector2(-32, 9), Vector2(-14, -12), Vector2(5, 5), Vector2(23, -18), Vector2(40, 10)])
	for item in offsets:
		var p := center + item * scale
		var candle_h := (30.0 + absf(item.y) * 0.52) * scale
		draw_rect(Rect2(p.x - 5 * scale, p.y - candle_h, 10 * scale, candle_h), Color("c89a64"))
		var flicker := sin(phase * 4.0 + p.x * 0.01) * 2.5 * scale
		_draw_glow(Vector2(p.x + flicker * 0.2, p.y - candle_h - 6 * scale), 31.0 * scale, Color(1.0, 0.50, 0.12, 0.09))
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

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var f := float(i) / 7.0
		var c := color
		c.a *= 1.0 - f * 0.78
		draw_circle(center, radius * f, c)

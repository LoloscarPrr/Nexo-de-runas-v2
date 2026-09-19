extends Control

var balance := 0
var ambience_time := 0.0

const REF_SIZE := Vector2(1536.0, 864.0)
const BG := Color("070a06")
const WOOD_DARK := Color("11170d")
const WOOD := Color("1b2414")
const WOOD_LIGHT := Color("26311a")
const EDGE := Color("53602a")
const EDGE_DIM := Color("30391d")
const GLOW := Color("c4d75a")
const PAPER := Color("a9a45b")
const INK := Color("080b06")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	ambience_time += delta
	queue_redraw()

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	draw_rect(Rect2(0, 0, w, h), BG)
	var s := minf(w / REF_SIZE.x, h / REF_SIZE.y)
	var origin := Vector2((w - REF_SIZE.x * s) * 0.5, (h - REF_SIZE.y * s) * 0.5)
	draw_set_transform(origin, 0.0, Vector2(s, s))
	_draw_reference()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_reference() -> void:
	# Marco general y tablones oscuros, frontal como la referencia.
	draw_rect(Rect2(0, 0, 1536, 864), BG)
	for row in range(12):
		var y := float(row) * 72.0
		draw_rect(Rect2(0, y, 1536, 69), WOOD_DARK if row % 2 == 0 else Color("0e140b"))
		draw_line(Vector2(0, y + 69), Vector2(1536, y + 69), Color("050705"), 3)
	for col in range(22):
		var x := float(col) * 73.0
		draw_line(Vector2(x, 0), Vector2(x, 864), Color(0.04, 0.06, 0.025, 0.34), 2)

	# Rieles metálicos/verde oliva del tablero.
	_draw_rail(Rect2(205, 44, 1090, 566))
	_draw_rail(Rect2(224, 318, 1052, 14))
	_draw_rail(Rect2(224, 594, 1052, 14))
	_draw_rail(Rect2(214, 42, 14, 566))
	_draw_rail(Rect2(1274, 42, 14, 566))

	# Seis paneles por fila: cuatro centrales se cubren con cartas y dos laterales quedan como madera estampada.
	for row_y in [58.0, 334.0]:
		for col in range(6):
			var x := 232.0 + float(col) * 174.0
			draw_rect(Rect2(x, row_y, 164, 246), WOOD)
			draw_rect(Rect2(x + 4, row_y + 4, 156, 238), EDGE_DIM, false, 2)
			_draw_paw(Vector2(x + 82, row_y + 124), 0.72)

	# Zona inferior de mano.
	draw_rect(Rect2(185, 620, 1166, 230), Color("0b1008"))
	draw_line(Vector2(190, 620), Vector2(1348, 620), EDGE, 4)
	draw_line(Vector2(190, 846), Vector2(1348, 846), EDGE_DIM, 3)

	# Balanza izquierda.
	var sx := 108.0
	var tilt := float(clampi(balance, -5, 5)) * 4.0
	draw_line(Vector2(sx, 92), Vector2(sx, 245), GLOW, 6)
	draw_line(Vector2(sx - 33, 246), Vector2(sx + 33, 246), GLOW, 6)
	draw_line(Vector2(sx - 78, 130 - tilt), Vector2(sx + 78, 130 + tilt), GLOW, 4)
	draw_circle(Vector2(sx, 130), 8, GLOW)
	for side in [-1.0, 1.0]:
		var pivot := Vector2(sx + 78.0 * side, 130.0 + tilt * side)
		draw_line(pivot, pivot + Vector2(-20, 44), GLOW, 2)
		draw_line(pivot, pivot + Vector2(20, 44), GLOW, 2)
		draw_arc(pivot + Vector2(0, 48), 25, 0, PI, 18, GLOW, 3)
	_draw_skull_rune(Vector2(110, 340), 1.0)

	# Retrato derecho: calavera encapuchada con ojos verdes.
	_draw_frame(Rect2(1334, 24, 164, 164), 4)
	draw_colored_polygon(PackedVector2Array([
		Vector2(1346, 176), Vector2(1364, 60), Vector2(1402, 30),
		Vector2(1458, 32), Vector2(1489, 69), Vector2(1494, 178)
	]), Color("050705"))
	draw_circle(Vector2(1420, 92), 49, Color("272a18"))
	draw_rect(Rect2(1387, 83, 66, 57), Color("878344"))
	draw_circle(Vector2(1404, 92), 12, Color("050705"))
	draw_circle(Vector2(1437, 92), 12, Color("050705"))
	var pulse := 0.82 + sin(ambience_time * 2.0) * 0.12
	draw_circle(Vector2(1404, 92), 4, Color(0.78, 0.93, 0.24, pulse))
	draw_circle(Vector2(1437, 92), 4, Color(0.78, 0.93, 0.24, pulse))
	draw_rect(Rect2(1411, 118, 19, 16), Color("050705"))
	for i in range(4):
		draw_line(Vector2(1396 + i * 14, 143), Vector2(1396 + i * 14, 154), Color("0a0d07"), 3)

	# Caja de diálogo y marcos de controles derechos.
	_draw_frame(Rect2(1320, 196, 190, 142), 3)
	_draw_frame(Rect2(1320, 404, 190, 58), 3)
	_draw_frame(Rect2(1320, 478, 190, 124), 3)

	# Pilas de mazo inferiores.
	_draw_card_stack(Vector2(36, 696), 11, false)
	_draw_card_stack(Vector2(1414, 696), 8, true)

	# Ruido/dithering determinista para acercar el acabado de la referencia.
	for i in range(180):
		var x := 8.0 + fmod(float(i * 137), 1518.0)
		var y := 8.0 + fmod(float(i * 83), 846.0)
		draw_rect(Rect2(x, y, 2, 2), Color(0.73, 0.78, 0.26, 0.08))

	# Viñeta fuerte.
	for i in range(10):
		var inset := float(i) * 4.0
		draw_rect(Rect2(inset, inset, 1536 - inset * 2, 864 - inset * 2), Color(0, 0, 0, 0.055 + i * 0.008), false, 8)

func _draw_rail(rect: Rect2) -> void:
	draw_rect(rect, Color("080c06"))
	draw_rect(rect.grow(-3), EDGE_DIM, false, 2)
	for x in range(int(rect.position.x) + 12, int(rect.end.x) - 8, 44):
		draw_circle(Vector2(float(x), rect.position.y + rect.size.y * 0.5), 2.2, EDGE)

func _draw_frame(rect: Rect2, width: int) -> void:
	draw_rect(rect, Color("080c06"))
	draw_rect(rect.grow(-4), EDGE, false, width)
	draw_rect(rect.grow(-9), Color("1a2212"), false, 2)

func _draw_paw(pos: Vector2, factor: float) -> void:
	var c := Color(0.30, 0.36, 0.15, 0.32)
	draw_circle(pos + Vector2(0, 12) * factor, 11 * factor, c)
	for off in [Vector2(-16, -6), Vector2(-6, -15), Vector2(7, -15), Vector2(17, -5)]:
		draw_circle(pos + off * factor, 6 * factor, c)

func _draw_skull_rune(pos: Vector2, factor: float) -> void:
	var c := GLOW
	draw_circle(pos, 35 * factor, c)
	draw_circle(pos + Vector2(-12, -2) * factor, 7 * factor, BG)
	draw_circle(pos + Vector2(12, -2) * factor, 7 * factor, BG)
	draw_rect(Rect2(pos.x - 11 * factor, pos.y + 15 * factor, 22 * factor, 13 * factor), BG)
	for angle in range(0, 360, 45):
		var a := deg_to_rad(float(angle))
		var p1 := pos + Vector2(cos(a), sin(a)) * 39.0 * factor
		var p2 := pos + Vector2(cos(a), sin(a)) * 55.0 * factor
		draw_line(p1, p2, c, 5 * factor)

func _draw_card_stack(pos: Vector2, count: int, mirrored: bool) -> void:
	for i in range(7):
		var off := Vector2(float(i) * (1.5 if not mirrored else -1.5), -float(i) * 4.0)
		draw_rect(Rect2(pos + off, Vector2(88, 116)), Color("74723e"))
		draw_rect(Rect2(pos + off + Vector2(4, 4), Vector2(80, 108)), Color("11170d"), false, 2)
	_draw_paw(pos + Vector2(44, 47), 0.45)

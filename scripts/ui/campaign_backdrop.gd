extends Control

## Fondo visual canónico de Nexo de Runas.
## Todo el juego usa el mismo lenguaje del mockup: negro/verde oliva,
## paneles frontales gastados, runas, marcos rígidos y textura pixelada.

var mode := "map"
var ambience_time := 0.0

const BG := Color("060906")
const PANEL := Color("10170d")
const PANEL_2 := Color("172013")
const EDGE := Color("4d5928")
const EDGE_DIM := Color("2e381d")
const GLOW := Color("c5d85a")
const INK := Color("a7a65b")
const PAPER := Color("858344")
const BLOOD := Color("792b22")
const FIRE := Color("bd7b37")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	ambience_time += delta
	queue_redraw()

func set_mode(value: String) -> void:
	mode = value
	queue_redraw()

func _draw() -> void:
	var w := maxf(size.x, 1280.0)
	var h := maxf(size.y, 720.0)
	_draw_base(w, h)
	match mode:
		"menu":
			_draw_menu(w, h)
		"map":
			_draw_map(w, h)
		"choice":
			_draw_choice(w, h)
		"campfire":
			_draw_campfire(w, h)
		"gate":
			_draw_gate(w, h)
		"reward":
			_draw_reward(w, h)
		"defeat":
			_draw_defeat(w, h)
		_:
			_draw_map(w, h)
	_draw_vignette(w, h)

func _draw_base(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), BG)
	# Tablones frontales, no mesa en perspectiva.
	var plank_h := maxf(52.0, h / 12.0)
	for row in range(int(h / plank_h) + 2):
		var y := float(row) * plank_h
		draw_rect(Rect2(0, y, w, plank_h - 3), PANEL if row % 2 == 0 else Color("0c120a"))
		draw_line(Vector2(0, y + plank_h - 3), Vector2(w, y + plank_h - 3), Color("040604"), 3)
	for col in range(int(w / 88.0) + 2):
		var x := float(col) * 88.0
		draw_line(Vector2(x, 0), Vector2(x, h), Color(0.03, 0.05, 0.02, 0.34), 2)

	# Marco metálico oliva.
	draw_rect(Rect2(10, 10, w - 20, h - 20), EDGE_DIM, false, 3)
	draw_rect(Rect2(18, 18, w - 36, h - 36), Color("202914"), false, 1)
	for x in range(30, int(w) - 30, 72):
		draw_circle(Vector2(float(x), 18), 2.2, EDGE)
		draw_circle(Vector2(float(x), h - 18), 2.2, EDGE)

	# Motivos de runas/patas discretos.
	for i in range(14):
		var px := 36.0 + fmod(float(i * 151), maxf(1.0, w - 72.0))
		var py := 45.0 + fmod(float(i * 97), maxf(1.0, h - 90.0))
		_draw_paw(Vector2(px, py), 0.35, Color(0.35, 0.40, 0.17, 0.15))

	# Dithering/grano determinista.
	for i in range(150):
		var px2 := 8.0 + fmod(float(i * 137), maxf(1.0, w - 16.0))
		var py2 := 8.0 + fmod(float(i * 83), maxf(1.0, h - 16.0))
		draw_rect(Rect2(px2, py2, 2, 2), Color(0.72, 0.76, 0.25, 0.055))

func _panel(rect: Rect2, fill := PANEL_2, strong := false) -> void:
	draw_rect(rect, Color("070b06"))
	draw_rect(rect.grow(-4), fill)
	draw_rect(rect.grow(-4), GLOW if strong else EDGE, false, 3 if strong else 2)
	draw_rect(rect.grow(-9), EDGE_DIM, false, 1)

func _draw_menu(w: float, h: float) -> void:
	_panel(Rect2(w * 0.23, h * 0.17, w * 0.47, h * 0.68), PANEL_2, true)
	# Columna de retrato a la derecha, igual al lenguaje de la batalla.
	_panel(Rect2(w * 0.76, h * 0.10, w * 0.17, h * 0.27), PANEL)
	_draw_skull(Vector2(w * 0.845, h * 0.235), minf(w, h) * 0.085)
	_panel(Rect2(w * 0.76, h * 0.40, w * 0.17, h * 0.20), PANEL)
	# Rune totem left.
	_draw_rune_totem(Vector2(w * 0.10, h * 0.38), minf(w, h) * 0.115)
	for y in [h * 0.69, h * 0.76, h * 0.83]:
		draw_line(Vector2(w * 0.06, y), Vector2(w * 0.17, y), EDGE, 2)

func _draw_map(w: float, h: float) -> void:
	var rect := Rect2(w * 0.13, h * 0.13, w * 0.74, h * 0.76)
	_panel(rect, Color("252d18"), true)
	var cx := w * 0.5
	var top := h * 0.27
	var bottom := h * 0.79
	var xoff := minf(w * 0.20, 270.0)
	var points := [
		Vector2(cx, top),
		Vector2(cx - xoff, h * 0.40),
		Vector2(cx + xoff, h * 0.40),
		Vector2(cx, h * 0.54),
		Vector2(cx, h * 0.67),
		Vector2(cx, bottom)
	]
	for chain in [
		PackedVector2Array([points[0], points[1], points[3]]),
		PackedVector2Array([points[0], points[2], points[3]]),
		PackedVector2Array([points[3], points[4], points[5]])
	]:
		draw_polyline(chain, Color("080b06"), 8, true)
		draw_polyline(chain, INK, 2, true)
	for p in points:
		draw_circle(p, 17, Color("080b06"))
		draw_circle(p, 10, PAPER)
		draw_circle(p, 6, GLOW, false, 2)

func _draw_choice(w: float, h: float) -> void:
	_panel(Rect2(w * 0.12, h * 0.12, w * 0.76, h * 0.76), PANEL_2, true)
	var card_w := minf(210.0, w * 0.17)
	var gap := minf(80.0, w * 0.05)
	var total := card_w * 3.0 + gap * 2.0
	var left := (w - total) * 0.5
	for i in range(3):
		var x := left + float(i) * (card_w + gap)
		_panel(Rect2(x - 8, h * 0.27 - 8, card_w + 16, h * 0.47 + 16), Color("0b1008"))
		for radius in range(16, 85, 14):
			draw_circle(Vector2(x + card_w * 0.5, h * 0.49), float(radius), Color(0.70, 0.78, 0.25, 0.006))

func _draw_campfire(w: float, h: float) -> void:
	_panel(Rect2(w * 0.12, h * 0.11, w * 0.76, h * 0.78), PANEL_2, true)
	var c := Vector2(w * 0.5, h * 0.55)
	for radius in range(35, 220, 18):
		draw_circle(c, float(radius), Color(0.75, 0.38, 0.08, 0.012))
	draw_line(c + Vector2(-72, 48), c + Vector2(68, -2), Color("171008"), 23, true)
	draw_line(c + Vector2(-66, -2), c + Vector2(72, 48), Color("1b1209"), 23, true)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-48, 28), c + Vector2(-28, -48), c + Vector2(-9, -8),
		c + Vector2(7, -92), c + Vector2(27, -27), c + Vector2(52, 30)
	]), Color("71311d"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-25, 27), c + Vector2(-11, -34), c + Vector2(4, -2),
		c + Vector2(15, -62), c + Vector2(34, 27)
	]), FIRE)
	for x in [w * 0.28, w * 0.36, w * 0.64, w * 0.72]:
		draw_circle(Vector2(x, h * 0.42), 26, Color("050805"))
		draw_circle(Vector2(x - 8, h * 0.415), 3, GLOW)
		draw_circle(Vector2(x + 8, h * 0.415), 3, GLOW)

func _draw_gate(w: float, h: float) -> void:
	_panel(Rect2(w * 0.15, h * 0.10, w * 0.70, h * 0.80), PANEL_2, true)
	var cx := w * 0.5
	var top := h * 0.23
	var bottom := h * 0.80
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 220, bottom), Vector2(cx - 185, top + 60),
		Vector2(cx - 95, top), Vector2(cx + 95, top),
		Vector2(cx + 185, top + 60), Vector2(cx + 220, bottom)
	]), Color("050805"))
	for i in range(6):
		var y := top + 85.0 + float(i) * 60.0
		draw_line(Vector2(cx - 170 + i * 8, y), Vector2(cx + 170 - i * 8, y), EDGE_DIM, 5)
	draw_circle(Vector2(cx - 37, top + 112), 6, GLOW)
	draw_circle(Vector2(cx + 37, top + 112), 6, GLOW)

func _draw_reward(w: float, h: float) -> void:
	_panel(Rect2(w * 0.12, h * 0.11, w * 0.76, h * 0.78), PANEL_2, true)
	var card_w := minf(210.0, w * 0.17)
	var gap := minf(80.0, w * 0.05)
	var total := card_w * 3.0 + gap * 2.0
	var left := (w - total) * 0.5
	for i in range(3):
		var x := left + float(i) * (card_w + gap)
		_panel(Rect2(x - 8, h * 0.27 - 8, card_w + 16, h * 0.47 + 16), Color("0b1008"))
		for radius in range(22, 120, 16):
			draw_circle(Vector2(x + card_w * 0.5, h * 0.50), float(radius), Color(0.72, 0.80, 0.28, 0.007))

func _draw_defeat(w: float, h: float) -> void:
	_panel(Rect2(w * 0.18, h * 0.17, w * 0.64, h * 0.66), Color("100d09"), true)
	draw_rect(Rect2(0, 0, w, h), Color(0.20, 0.015, 0.01, 0.22))
	_draw_skull(Vector2(w * 0.5, h * 0.45), minf(w, h) * 0.12)

func _draw_paw(pos: Vector2, factor: float, color: Color) -> void:
	draw_circle(pos + Vector2(0, 11) * factor, 11 * factor, color)
	for off in [Vector2(-16, -6), Vector2(-6, -15), Vector2(7, -15), Vector2(17, -5)]:
		draw_circle(pos + off * factor, 6 * factor, color)

func _draw_skull(pos: Vector2, radius: float) -> void:
	draw_circle(pos, radius, Color("696b39"))
	draw_circle(pos + Vector2(-radius * 0.32, -radius * 0.12), radius * 0.20, Color("050805"))
	draw_circle(pos + Vector2(radius * 0.32, -radius * 0.12), radius * 0.20, Color("050805"))
	var pulse := 0.80 + sin(ambience_time * 1.8) * 0.12
	draw_circle(pos + Vector2(-radius * 0.32, -radius * 0.12), radius * 0.055, Color(0.78, 0.90, 0.24, pulse))
	draw_circle(pos + Vector2(radius * 0.32, -radius * 0.12), radius * 0.055, Color(0.78, 0.90, 0.24, pulse))
	draw_rect(Rect2(pos.x - radius * 0.19, pos.y + radius * 0.22, radius * 0.38, radius * 0.24), Color("050805"))

func _draw_rune_totem(pos: Vector2, radius: float) -> void:
	draw_circle(pos, radius * 0.36, GLOW)
	draw_circle(pos, radius * 0.17, BG)
	for angle in range(0, 360, 45):
		var a := deg_to_rad(float(angle))
		var p1 := pos + Vector2(cos(a), sin(a)) * radius * 0.42
		var p2 := pos + Vector2(cos(a), sin(a)) * radius * 0.72
		draw_line(p1, p2, GLOW, maxf(2.0, radius * 0.055))
	draw_line(pos + Vector2(0, radius * 0.34), pos + Vector2(0, radius * 1.15), GLOW, maxf(3.0, radius * 0.075))

func _draw_vignette(w: float, h: float) -> void:
	var edge := maxf(28.0, w * 0.025)
	for i in range(9):
		var inset := float(i) * edge / 9.0
		draw_rect(Rect2(inset, inset, w - inset * 2.0, h - inset * 2.0), Color(0, 0, 0, 0.04 + float(i) * 0.012), false, 7)

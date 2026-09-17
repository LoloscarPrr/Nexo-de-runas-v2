extends Control

## Fondo procedural único para toda la experiencia Acto 1.
## Ninguna pantalla principal debe sentirse como un menú Android/TCG separado:
## todas son distintas vistas de la misma cabaña, mesa y sendero físico.
var mode := "map"
var ambience_time := 0.0

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
	_draw_cabin_and_table(w, h)

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

func _draw_cabin_and_table(w: float, h: float) -> void:
	# Oscuridad de cabaña y pared de tablones.
	draw_rect(Rect2(0, 0, w, h), Color("080604"))
	draw_rect(Rect2(0, 0, w, h * 0.39), Color("100c08"))
	for i in range(int(w / 82.0) + 2):
		var x := float(i) * 82.0
		draw_rect(Rect2(x, 0, 79, h * 0.39), Color("17110c") if i % 2 == 0 else Color("1b130d"))
		draw_line(Vector2(x, 0), Vector2(x, h * 0.39), Color("090705"), 3.0)
		var grain_y := 18.0 + fmod(float(i * 47), maxf(1.0, h * 0.31))
		draw_line(Vector2(x + 9, grain_y), Vector2(x + 61, grain_y + 2), Color(0.58, 0.37, 0.18, 0.07), 1.0)

	# Mesa en perspectiva: ocupa el ancho completo del teléfono.
	var horizon := h * 0.25
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.10, horizon), Vector2(w * 0.90, horizon),
		Vector2(w + 96, h + 12), Vector2(-96, h + 12)
	]), Color("302116"))
	for i in range(17):
		var t := float(i) / 16.0
		draw_line(
			Vector2(lerpf(w * 0.10, w * 0.90, t), horizon),
			Vector2(lerpf(-76.0, w + 76.0, t), h),
			Color("17100b"), 3.0
		)
	for i in range(120):
		var y := horizon + 20.0 + fmod(float(i * 71), maxf(1.0, h - horizon - 30.0))
		var x2 := 18.0 + fmod(float(i * 173), maxf(1.0, w - 70.0))
		draw_line(Vector2(x2, y), Vector2(x2 + 25.0 + float(i % 61), y + 1.5), Color(0.72, 0.50, 0.28, 0.06), 1.0)

	# Luz cálida general sobre el centro de la mesa.
	var center := Vector2(w * 0.5, h * 0.50)
	for radius in range(120, 500, 32):
		draw_circle(center, float(radius), Color(0.84, 0.49, 0.19, 0.0065))

func _paper_polygon(w: float, h: float, inset_x: float, inset_y: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(inset_x + 20, inset_y + 5),
		Vector2(w - inset_x - 31, inset_y),
		Vector2(w - inset_x - 9, h - inset_y - 22),
		Vector2(inset_x, h - inset_y - 9)
	])

func _draw_menu(w: float, h: float) -> void:
	# El Guardián existe en el espacio, no en un panel lateral.
	var gx := w * 0.78
	var gy := h * 0.24
	draw_circle(Vector2(gx, gy), 92, Color("090806"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(gx - 105, gy + 62), Vector2(gx - 75, gy - 20),
		Vector2(gx - 31, gy - 74), Vector2(gx + 42, gy - 68),
		Vector2(gx + 94, gy + 65)
	]), Color("080705"))
	var glow := 0.72 + sin(ambience_time * 1.55) * 0.12
	for eye in [Vector2(gx - 30, gy - 1), Vector2(gx + 28, gy - 1)]:
		draw_circle(eye, 15, Color(0.78, 0.42, 0.15, 0.05))
		draw_circle(eye, 4.2, Color(0.87, 0.64, 0.34, glow))

	# Dos velas marcan el plano de la mesa del mockup.
	_draw_candle(Vector2(w * 0.18, h * 0.53), 1.0)
	_draw_candle(Vector2(w * 0.86, h * 0.57), 0.82)

	# Placa física para el título; los botones reales se superponen desde main.gd.
	var plaque := PackedVector2Array([
		Vector2(w * 0.27, h * 0.21), Vector2(w * 0.65, h * 0.20),
		Vector2(w * 0.67, h * 0.39), Vector2(w * 0.25, h * 0.40)
	])
	draw_colored_polygon(plaque, Color("21170f"))
	draw_polyline(PackedVector2Array([plaque[0], plaque[1], plaque[2], plaque[3], plaque[0]]), Color("694729"), 3.0, true)

func _draw_map(w: float, h: float) -> void:
	var paper := _paper_polygon(w, h, w * 0.15, 78.0)
	draw_colored_polygon(paper, Color("5c4a31"))
	draw_polyline(PackedVector2Array([paper[0], paper[1], paper[2], paper[3], paper[0]]), Color("8e7045"), 3.0, true)
	for i in range(32):
		var px := w * 0.18 + fmod(float(i * 193), w * 0.63)
		var py := 102.0 + fmod(float(i * 97), h - 210.0)
		draw_circle(Vector2(px, py), 2.0 + float(i % 5), Color(0.13, 0.08, 0.04, 0.11))
	var cx := w * 0.5
	var top := 150.0
	var usable := maxf(430.0, h - 245.0)
	var y0 := top
	var y1 := top + usable * 0.20
	var y2 := top + usable * 0.43
	var y3 := top + usable * 0.67
	var y4 := top + usable * 0.90
	var left := cx - minf(270.0, w * 0.18)
	var right := cx + minf(270.0, w * 0.18)
	var ink := Color("2b2117")
	for points in [
		PackedVector2Array([Vector2(cx, y0), Vector2(left, y1), Vector2(cx, y2)]),
		PackedVector2Array([Vector2(cx, y0), Vector2(right, y1), Vector2(cx, y2)]),
		PackedVector2Array([Vector2(cx, y2), Vector2(cx, y3), Vector2(cx, y4)])
	]:
		draw_polyline(points, ink, 7.0, true)
		draw_polyline(points, Color("aa8b56"), 2.0, true)
	for p in [Vector2(cx, y0), Vector2(left, y1), Vector2(right, y1), Vector2(cx, y2), Vector2(cx, y3), Vector2(cx, y4)]:
		draw_circle(p, 16, Color("2b2117"))
		draw_circle(p, 10, Color("b08d55"))

func _draw_choice(w: float, h: float) -> void:
	var paper := _paper_polygon(w, h, w * 0.19, 76.0)
	draw_colored_polygon(paper, Color("4f402b"))
	draw_polyline(PackedVector2Array([paper[0], paper[1], paper[2], paper[3], paper[0]]), Color("7d633f"), 3.0, true)
	var cy := h * 0.57
	for offset in [-250.0, 0.0, 250.0]:
		for radius in range(18, 92, 14):
			draw_circle(Vector2(w * 0.5 + offset, cy), float(radius), Color(0.0, 0.0, 0.0, 0.012))

func _draw_campfire(w: float, h: float) -> void:
	var center := Vector2(w * 0.5, h * 0.56)
	for radius in range(40, 250, 20):
		draw_circle(center, float(radius), Color(0.92, 0.37, 0.08, 0.012))
	draw_line(center + Vector2(-72, 55), center + Vector2(72, -2), Color("311c11"), 24, true)
	draw_line(center + Vector2(-69, -3), center + Vector2(70, 55), Color("3a2214"), 24, true)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-56, 32), center + Vector2(-34, -55), center + Vector2(-8, -8),
		center + Vector2(6, -110), center + Vector2(29, -32), center + Vector2(54, -70),
		center + Vector2(60, 37)
	]), Color("9e3e1c"))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-34, 29), center + Vector2(-18, -42), center + Vector2(2, -2),
		center + Vector2(15, -72), center + Vector2(37, 31)
	]), Color("e69a43"))
	for x in [w * 0.25, w * 0.35, w * 0.65, w * 0.75]:
		draw_circle(Vector2(x, h * 0.42), 30, Color("0a0806"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 54, h * 0.64), Vector2(x - 36, h * 0.47),
			Vector2(x + 36, h * 0.47), Vector2(x + 54, h * 0.64)
		]), Color("0a0806"))
		draw_circle(Vector2(x - 10, h * 0.415), 3, Color("b87937"))
		draw_circle(Vector2(x + 10, h * 0.415), 3, Color("b87937"))

func _draw_gate(w: float, h: float) -> void:
	var cx := w * 0.5
	var floor_y := h * 0.78
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 250, floor_y), Vector2(cx - 205, h * 0.25),
		Vector2(cx - 110, h * 0.13), Vector2(cx + 110, h * 0.13),
		Vector2(cx + 205, h * 0.25), Vector2(cx + 250, floor_y)
	]), Color("080706"))
	for i in range(6):
		var y := h * 0.24 + float(i) * 70.0
		draw_line(Vector2(cx - 230 + i * 13, y), Vector2(cx + 230 - i * 13, y), Color("25170f"), 5)
	for radius in range(12, 110, 14):
		draw_circle(Vector2(cx, h * 0.39), float(radius), Color(0.75, 0.31, 0.08, 0.008))
	draw_circle(Vector2(cx - 44, h * 0.39), 7, Color("d0914b"))
	draw_circle(Vector2(cx + 44, h * 0.39), 7, Color("d0914b"))
	draw_line(Vector2(cx, floor_y), Vector2(cx, h), Color("765437"), 5)

func _draw_reward(w: float, h: float) -> void:
	# Tres espacios iluminados sobre la mesa, como cartas empujadas hacia el jugador.
	var cy := h * 0.57
	for i in range(3):
		var x := w * 0.5 + float(i - 1) * minf(285.0, w * 0.22)
		for radius in range(35, 160, 18):
			draw_circle(Vector2(x, cy), float(radius), Color(0.90, 0.58, 0.26, 0.006))
		draw_rect(Rect2(x - 92, cy - 135, 184, 270), Color(0, 0, 0, 0.20))
	_draw_candle(Vector2(w * 0.14, h * 0.55), 0.9)

func _draw_defeat(w: float, h: float) -> void:
	# Vela apagada y mesa casi sin luz.
	var cx := w * 0.5
	draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.0, 0.0, 0.24))
	draw_rect(Rect2(cx - 12, h * 0.58, 24, 76), Color("766348"))
	for i in range(7):
		var p := Vector2(cx + sin(float(i) * 1.3) * 10.0, h * 0.55 - float(i) * 18.0)
		draw_circle(p, 10.0 + float(i) * 2.5, Color(0.48, 0.43, 0.38, 0.018))

func _draw_candle(pos: Vector2, scale_factor: float) -> void:
	for radius in range(20, 145, 12):
		draw_circle(pos, float(radius) * scale_factor, Color(0.94, 0.49, 0.12, 0.009))
	draw_rect(Rect2(pos.x - 10 * scale_factor, pos.y + 8 * scale_factor, 20 * scale_factor, 62 * scale_factor), Color("b8a178"))
	var wobble := sin(ambience_time * 5.4 + pos.x * 0.01) * 3.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(pos.x - 6 * scale_factor, pos.y + 8 * scale_factor),
		Vector2(pos.x + wobble, pos.y - 18 * scale_factor),
		Vector2(pos.x + 7 * scale_factor, pos.y + 7 * scale_factor),
		Vector2(pos.x, pos.y + 16 * scale_factor)
	]), Color("efbd70"))

func _draw_vignette(w: float, h: float) -> void:
	# Bordes oscuros sin letterbox: sigue llenando toda la pantalla panorámica.
	var edge := maxf(32.0, w * 0.032)
	for i in range(9):
		var alpha := 0.045 + float(i) * 0.011
		var inset := float(i) * edge / 9.0
		draw_rect(Rect2(inset, inset, w - inset * 2.0, h - inset * 2.0), Color(0, 0, 0, alpha), false, 7.0)

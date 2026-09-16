extends Control

var mode := "map"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()

func set_mode(value: String) -> void:
	mode = value
	queue_redraw()

func _draw() -> void:
	var w := maxf(size.x, 1280.0)
	var h := maxf(size.y, 720.0)
	var wood := Color("2d2015")
	var seam := Color("17100b")
	draw_rect(Rect2(0, 0, w, h), Color("0a0806"))
	# Table planks fill the entire wide Android canvas.
	for i in range(18):
		var x := float(i) * w / 18.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 0), Vector2(x + w / 18.0 + 3.0, 0),
			Vector2(x + w / 18.0 + 30.0, h), Vector2(x - 28.0, h)
		]), wood if i % 2 == 0 else Color("332418"))
		draw_line(Vector2(x, 0), Vector2(x - 28.0, h), seam, 3.0)
	for i in range(130):
		var y := 15.0 + fmod(float(i * 67), h - 30.0)
		var x2 := 18.0 + fmod(float(i * 173), w - 70.0)
		draw_line(Vector2(x2, y), Vector2(x2 + 24.0 + float(i % 58), y + 1.0), Color(0.72, 0.50, 0.28, 0.055), 1.0)

	match mode:
		"map":
			_draw_map(w, h)
		"choice":
			_draw_choice(w, h)
		"campfire":
			_draw_campfire(w, h)
		"gate":
			_draw_gate(w, h)
		_:
			_draw_map(w, h)

func _paper_polygon(w: float, h: float, inset_x: float, inset_y: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(inset_x + 20, inset_y + 5),
		Vector2(w - inset_x - 31, inset_y),
		Vector2(w - inset_x - 9, h - inset_y - 22),
		Vector2(inset_x, h - inset_y - 9)
	])

func _draw_map(w: float, h: float) -> void:
	var paper := _paper_polygon(w, h, w * 0.15, 78.0)
	draw_colored_polygon(paper, Color("5c4a31"))
	draw_polyline(PackedVector2Array([paper[0], paper[1], paper[2], paper[3], paper[0]]), Color("8e7045"), 3.0, true)
	# Burnt / dirty edges.
	for i in range(32):
		var px := w * 0.18 + fmod(float(i * 193), w * 0.63)
		var py := 102.0 + fmod(float(i * 97), h - 210.0)
		draw_circle(Vector2(px, py), 2.0 + float(i % 5), Color(0.13, 0.08, 0.04, 0.11))
	# Hand-drawn route matching the interactive nodes.
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
	# Logs.
	draw_line(center + Vector2(-72, 55), center + Vector2(72, -2), Color("311c11"), 24, true)
	draw_line(center + Vector2(-69, -3), center + Vector2(70, 55), Color("3a2214"), 24, true)
	# Fire layers.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-56, 32), center + Vector2(-34, -55), center + Vector2(-8, -8),
		center + Vector2(6, -110), center + Vector2(29, -32), center + Vector2(54, -70),
		center + Vector2(60, 37)
	]), Color("9e3e1c"))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-34, 29), center + Vector2(-18, -42), center + Vector2(2, -2),
		center + Vector2(15, -72), center + Vector2(37, 31)
	]), Color("e69a43"))
	# Hungry silhouettes beyond the fire.
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
	# Tunnel / doorway toward the first boss.
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
	# Path scratched into the tabletop.
	draw_line(Vector2(cx, floor_y), Vector2(cx, h), Color("765437"), 5)

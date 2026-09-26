class_name CanonicalForestBattleBackdrop
extends Control

var phase := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, s), Color("050805"))
	_draw_forest_silhouette(s)
	_draw_glow(Vector2(s.x * 0.18, s.y * 0.18), 230.0, Color(0.21, 0.34, 0.12, 0.10))
	_draw_glow(Vector2(s.x * 0.82, s.y * 0.16), 190.0, Color(0.63, 0.39, 0.11, 0.09))
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.44), 420.0, Color(0.16, 0.25, 0.08, 0.08))
	var table_top := PackedVector2Array([
		Vector2(s.x * 0.055, s.y * 0.105),
		Vector2(s.x * 0.945, s.y * 0.105),
		Vector2(s.x * 0.985, s.y * 0.895),
		Vector2(s.x * 0.015, s.y * 0.895)
	])
	draw_colored_polygon(table_top, Color("21190f"))
	var front_lip := PackedVector2Array([
		Vector2(s.x * 0.015, s.y * 0.895), Vector2(s.x * 0.985, s.y * 0.895),
		Vector2(s.x * 0.955, s.y), Vector2(s.x * 0.045, s.y)
	])
	draw_colored_polygon(front_lip, Color("0e0c08"))
	for i in range(9):
		var y := lerpf(s.y * 0.15, s.y * 0.86, float(i) / 8.0)
		var wobble := sin(float(i) * 1.73) * 7.0
		draw_line(Vector2(s.x * 0.045, y + wobble), Vector2(s.x * 0.955, y - wobble * 0.35), Color(0.43, 0.29, 0.14, 0.18), 2.0)
		draw_line(Vector2(s.x * 0.045, y + wobble + 3), Vector2(s.x * 0.955, y - wobble * 0.35 + 3), Color(0.02, 0.015, 0.01, 0.20), 1.0)
	for i in range(17):
		var px := s.x * (0.09 + fmod(float(i) * 0.137, 0.82))
		var py := s.y * (0.18 + fmod(float(i) * 0.193, 0.63))
		draw_arc(Vector2(px, py), 5.0 + float(i % 4) * 2.0, 0, TAU, 18, Color(0.38, 0.26, 0.13, 0.13), 1.0)
	_draw_root(PackedVector2Array([
		Vector2(0, s.y * 0.17), Vector2(s.x * 0.055, s.y * 0.20), Vector2(s.x * 0.025, s.y * 0.34),
		Vector2(s.x * 0.082, s.y * 0.45), Vector2(s.x * 0.045, s.y * 0.63), Vector2(s.x * 0.105, s.y * 0.80)
	]), Color("344124"), 20.0)
	_draw_root(PackedVector2Array([
		Vector2(s.x, s.y * 0.12), Vector2(s.x * 0.945, s.y * 0.23), Vector2(s.x * 0.974, s.y * 0.38),
		Vector2(s.x * 0.925, s.y * 0.53), Vector2(s.x * 0.968, s.y * 0.70), Vector2(s.x * 0.915, s.y * 0.86)
	]), Color("3a3c20"), 19.0)
	_draw_candle(Vector2(s.x * 0.115, s.y * 0.12), 0.0)
	_draw_candle(Vector2(s.x * 0.885, s.y * 0.11), 1.8)
	_draw_candle(Vector2(s.x * 0.945, s.y * 0.72), 3.2)
	_draw_bone_charm(Vector2(s.x * 0.095, s.y * 0.68), 0.35)
	_draw_bone_charm(Vector2(s.x * 0.905, s.y * 0.37), -0.2)

func _draw_forest_silhouette(s: Vector2) -> void:
	for i in range(13):
		var x := s.x * (0.02 + float(i) / 12.0 * 0.96)
		var trunk_w := 18.0 + float((i * 7) % 5) * 7.0
		var top := s.y * (0.01 + float((i * 3) % 4) * 0.02)
		draw_rect(Rect2(x - trunk_w * 0.5, top, trunk_w, s.y * 0.35), Color(0.035, 0.055, 0.03, 0.90))
		draw_line(Vector2(x, s.y * 0.13), Vector2(x - 55 - float(i % 3) * 18, s.y * 0.045), Color(0.035, 0.055, 0.03, 0.88), 9.0)
		draw_line(Vector2(x, s.y * 0.15), Vector2(x + 50 + float(i % 4) * 16, s.y * 0.055), Color(0.035, 0.055, 0.03, 0.88), 8.0)
	for i in range(20):
		var x := s.x * fmod(0.07 + float(i) * 0.083, 0.94)
		var y := s.y * (0.035 + float(i % 4) * 0.025)
		draw_circle(Vector2(x, y), 38.0 + float(i % 3) * 13.0, Color(0.025, 0.06, 0.028, 0.92))

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var factor := float(i) / 7.0
		var c := color
		c.a *= (1.0 - factor * 0.78)
		draw_circle(center, radius * factor, c)

func _draw_root(points: PackedVector2Array, color: Color, width: float) -> void:
	draw_polyline(points, Color(0.01, 0.018, 0.009, 0.86), width + 8.0, true)
	draw_polyline(points, color.darkened(0.20), width, true)
	draw_polyline(points, Color(color.r * 1.08, color.g * 1.08, color.b * 0.92, 0.42), maxf(2.0, width * 0.18), true)

func _draw_candle(base: Vector2, offset: float) -> void:
	var flicker := sin(phase * 4.2 + offset) * 3.5
	draw_rect(Rect2(base + Vector2(-7, 10), Vector2(14, 37)), Color("8d7141"))
	draw_rect(Rect2(base + Vector2(-5, 12), Vector2(10, 35)), Color("b08d54"))
	_draw_glow(base + Vector2(flicker * 0.2, 3), 72.0 + flicker, Color(0.98, 0.58, 0.14, 0.15))
	draw_circle(base + Vector2(flicker * 0.38, 3), 8.0, Color(1.0, 0.67, 0.20, 0.92))
	draw_circle(base + Vector2(flicker * 0.50, -2), 3.8, Color(1.0, 0.94, 0.65, 0.98))

func _draw_bone_charm(center: Vector2, angle: float) -> void:
	var d := Vector2(cos(angle), sin(angle)) * 18.0
	draw_line(center - d, center + d, Color("9a8d69"), 5.0)
	draw_circle(center - d, 5.5, Color("a89a75"))
	draw_circle(center + d, 5.5, Color("a89a75"))

class_name VerticalBattleBackdrop
extends Control

## Fondo procedural liviano inspirado en el mockup vertical aprobado.
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

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 1.0 or h <= 1.0:
		return

	draw_rect(Rect2(0, 0, w, h), NIGHT)
	for band in range(8):
		var y := h * float(band) / 8.0
		var alpha := 0.02 + float(band) * 0.007
		draw_rect(Rect2(0, y, w, h / 8.0 + 1.0), Color(NIGHT_2.r, NIGHT_2.g, NIGHT_2.b, alpha + 0.12))

	_draw_tree_column(Rect2(0, 0, w * 0.075, h), false)
	_draw_tree_column(Rect2(w * 0.925, 0, w * 0.075, h), true)

	var center := Vector2(w * 0.5, h * 0.37)
	var rune_radius := minf(w, h) * 0.11
	draw_circle(center, rune_radius * 1.6, Color(RUNE.r, RUNE.g, RUNE.b, 0.035))
	draw_arc(center, rune_radius, 0, TAU, 64, RUNE, 2.0)
	draw_arc(center, rune_radius * 0.64, 0, TAU, 48, Color(RUNE.r, RUNE.g, RUNE.b, 0.12), 1.4)
	for angle in [0.0, PI / 2.0, PI, PI * 1.5]:
		var a := center + Vector2(cos(angle), sin(angle)) * rune_radius * 0.68
		var b := center + Vector2(cos(angle), sin(angle)) * rune_radius * 0.94
		draw_line(a, b, RUNE, 2.0)

	_draw_lantern(Vector2(w * 0.075, h * 0.17), minf(w, h) * 0.018)
	_draw_lantern(Vector2(w * 0.925, h * 0.21), minf(w, h) * 0.019)
	_draw_lantern(Vector2(w * 0.06, h * 0.73), minf(w, h) * 0.015)
	_draw_lantern(Vector2(w * 0.94, h * 0.77), minf(w, h) * 0.015)

	_draw_vine(PackedVector2Array([
		Vector2(w * 0.03, h * 0.08), Vector2(w * 0.15, h * 0.13), Vector2(w * 0.22, h * 0.08), Vector2(w * 0.35, h * 0.12)
	]))
	_draw_vine(PackedVector2Array([
		Vector2(w * 0.97, h * 0.11), Vector2(w * 0.85, h * 0.16), Vector2(w * 0.78, h * 0.10), Vector2(w * 0.67, h * 0.14)
	]))

	# Viñeta superior/inferior para que HUD y mano destaquen sobre el bosque.
	draw_rect(Rect2(0, 0, w, h * 0.10), Color(0, 0, 0, 0.28))
	draw_rect(Rect2(0, h * 0.74, w, h * 0.26), Color(0, 0, 0, 0.34))

func _draw_tree_column(rect: Rect2, mirror: bool) -> void:
	draw_rect(rect, BARK)
	draw_rect(rect.grow(-5), BARK_LIGHT)
	var x := rect.end.x - 4.0 if mirror else rect.position.x + 4.0
	for i in range(6):
		var yy := rect.position.y + rect.size.y * (0.08 + float(i) * 0.16)
		var branch_end := Vector2(rect.position.x - rect.size.x * 0.45, yy - 32) if mirror else Vector2(rect.end.x + rect.size.x * 0.45, yy - 32)
		draw_line(Vector2(x, yy), branch_end, BARK_LIGHT, 5.0)
	for i in range(12):
		var yy2 := rect.position.y + rect.size.y * float(i) / 12.0
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
		var p := points[i]
		draw_circle(p + Vector2(8 if i % 2 == 0 else -8, -4), 5.0, MOSS)

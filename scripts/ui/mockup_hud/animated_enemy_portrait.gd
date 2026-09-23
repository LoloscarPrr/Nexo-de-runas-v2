extends Control

const EDGE := Color("53602a")
const GLOW := Color("c4d75a")
const DARK := Color("050705")
const FACE := Color("878344")
const HOOD := Color("272a18")

var time := 0.0
var hit_strength := 0.0
var surrendering := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	hit_strength = maxf(0.0, hit_strength - delta * 6.0)
	queue_redraw()

func hit() -> void:
	hit_strength = 1.0

func set_surrendering(value: bool) -> void:
	surrendering = value
	queue_redraw()

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	_draw_frame(Rect2(0, 0, w, h))
	var breathe := sin(time * TAU / 2.2) * 2.0
	var shake := sin(time * 70.0) * 4.0 * hit_strength
	var off := Vector2(shake, breathe)

	var poly := PackedVector2Array([
		Vector2(w * 0.08, h * 0.93) + off,
		Vector2(w * 0.18, h * 0.24) + off,
		Vector2(w * 0.42, h * 0.05) + off,
		Vector2(w * 0.76, h * 0.06) + off,
		Vector2(w * 0.95, h * 0.28) + off,
		Vector2(w * 0.98, h * 0.94) + off
	])
	draw_colored_polygon(poly, DARK)
	draw_circle(Vector2(w * 0.53, h * 0.43) + off, w * 0.30, HOOD)
	draw_rect(Rect2(Vector2(w * 0.33, h * 0.36) + off, Vector2(w * 0.40, h * 0.35)), FACE)

	var blink_phase := fmod(time, 5.2)
	var blink := blink_phase > 4.92 and blink_phase < 5.06
	var eye_r := w * (0.018 if blink else 0.07)
	draw_circle(Vector2(w * 0.43, h * 0.42) + off, eye_r + w * 0.03, DARK)
	draw_circle(Vector2(w * 0.63, h * 0.42) + off, eye_r + w * 0.03, DARK)

	var eye_alpha := 0.45 if surrendering else (0.80 + sin(time * 2.0) * 0.12)
	if not blink:
		draw_circle(Vector2(w * 0.43, h * 0.42) + off, w * 0.025, Color(0.78, 0.93, 0.24, eye_alpha))
		draw_circle(Vector2(w * 0.63, h * 0.42) + off, w * 0.025, Color(0.78, 0.93, 0.24, eye_alpha))
	draw_rect(Rect2(Vector2(w * 0.47, h * 0.59) + off, Vector2(w * 0.12, h * 0.10)), DARK)

func _draw_frame(rect: Rect2) -> void:
	draw_rect(rect, Color("080c06"))
	draw_rect(rect.grow(-4), EDGE, false, 4)
	draw_rect(rect.grow(-9), Color("1a2212"), false, 2)

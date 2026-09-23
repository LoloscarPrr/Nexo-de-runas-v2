extends Control

const GLOW := Color("c4d75a")
const BG := Color("070a06")

var balance := 0
var left_value := 2
var right_value := 2
var time := 0.0
var impact := 0.0
var change_strength := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	impact = maxf(0.0, impact - delta * 6.0)
	change_strength = maxf(0.0, change_strength - delta * 3.2)
	queue_redraw()

func animate_change(delta_score: int) -> void:
	if delta_score == 0:
		return
	impact = 1.0
	change_strength = minf(1.0, absf(float(delta_score)) * 0.35 + 0.35)

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	var center := Vector2(w * 0.50, h * 0.33)
	var idle := sin(time * TAU / 2.2) * 1.5
	var score_tilt := float(clampi(balance, -5, 5)) * 4.0
	var tilt_deg := idle + score_tilt
	var tilt := tan(deg_to_rad(tilt_deg)) * w * 0.36
	var shake := sin(time * 64.0) * 3.0 * impact
	var cx := center.x + shake

	draw_line(Vector2(cx, h * 0.12), Vector2(cx, h * 0.78), GLOW, maxf(3.0, w * 0.025))
	draw_line(Vector2(cx - w * 0.17, h * 0.79), Vector2(cx + w * 0.17, h * 0.79), GLOW, maxf(3.0, w * 0.025))
	draw_line(Vector2(cx - w * 0.40, center.y - tilt), Vector2(cx + w * 0.40, center.y + tilt), GLOW, maxf(2.0, w * 0.018))
	draw_circle(Vector2(cx, center.y), maxf(4.0, w * 0.035), GLOW)

	for side in [-1.0, 1.0]:
		var pivot := Vector2(cx + w * 0.40 * side, center.y + tilt * side)
		draw_line(pivot, pivot + Vector2(-w * 0.10, h * 0.23), GLOW, maxf(1.5, w * 0.010))
		draw_line(pivot, pivot + Vector2(w * 0.10, h * 0.23), GLOW, maxf(1.5, w * 0.010))
		draw_arc(pivot + Vector2(0, h * 0.25), w * 0.13, 0, PI, 18, GLOW, maxf(2.0, w * 0.014))

	var pulse := 1.0 + change_strength * 0.18
	var font := ThemeDB.fallback_font
	var fs := int(clampf(h * 0.14 * pulse, 16.0, 30.0))
	draw_string(font, Vector2(w * 0.05, h * 0.98), str(left_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.30, fs, GLOW)
	draw_string(font, Vector2(w * 0.65, h * 0.98), str(right_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.30, fs, GLOW)

class_name CanonicalForestNexus
extends Control

const GOLD := Color("d0a950")
const GREEN := Color("9db750")
const DARK := Color("111109")

var integrity := 20
var caption := "TU NEXO"
var hostile := false
var phase := 0.0
var _last_integrity := 20
var hit_flash := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func set_integrity(value: int) -> void:
	if value < _last_integrity:
		hit_flash = 1.0
	_last_integrity = value
	integrity = value
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	hit_flash = maxf(0.0, hit_flash - delta * 2.6)
	queue_redraw()

func _draw() -> void:
	var c := size * 0.5 + Vector2(0, 7)
	var r := minf(size.x, size.y) * 0.30
	var accent := Color("bd5b3d") if hostile else GREEN
	var glow_alpha := 0.10 + sin(phase * 1.8) * 0.025 + hit_flash * 0.18
	for i in range(5, 0, -1):
		var f := float(i) / 5.0
		draw_circle(c, r * (1.15 + f * 0.78), Color(accent.r, accent.g, accent.b, glow_alpha * (1.0 - f * 0.65)))
	draw_circle(c + Vector2(3, 5), r * 1.03, Color(0, 0, 0, 0.60))
	draw_circle(c, r, DARK)
	draw_arc(c, r, 0, TAU, 40, GOLD.darkened(0.15), 3.0)
	draw_arc(c, r * 0.76, 0, TAU, 32, Color(accent.r, accent.g, accent.b, 0.70), 2.0)
	draw_line(c + Vector2(0, -r * 0.58), c + Vector2(0, r * 0.56), accent, 2.0)
	draw_line(c + Vector2(-r * 0.46, -r * 0.12), c + Vector2(r * 0.45, r * 0.15), accent, 2.0)
	draw_line(c + Vector2(-r * 0.38, r * 0.42), c + Vector2(r * 0.38, -r * 0.42), accent, 2.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 20), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color(0.76, 0.72, 0.49, 0.95))
	draw_string(font, Vector2(c.x - 36, c.y + 10), str(integrity), HORIZONTAL_ALIGNMENT_CENTER, 72, 28, Color(0.96, 0.85, 0.50, 1.0))

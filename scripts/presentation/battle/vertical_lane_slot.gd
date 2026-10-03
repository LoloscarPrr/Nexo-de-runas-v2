class_name VerticalLaneSlot
extends Control

## Decoración de carril inspirada en el mockup vertical aprobado.
## No contiene reglas: sólo dibuja el receptáculo visual de una carta.

var side := "player"
var occupied := false
var valid_target := false

const BRONZE := Color("a66d27")
const BRONZE_DARK := Color("4b2b12")
const WOOD := Color("160e08")
const FOREST := Color("0f2315")
const ENEMY := Color("2a120f")
const MOSS := Color("395b2c")
const GLOW := Color("7dde56")

func configure(next_side: String, is_occupied: bool, is_valid_target: bool) -> void:
	side = next_side
	occupied = is_occupied
	valid_target = is_valid_target
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return
	var rect := Rect2(2, 2, size.x - 4, size.y - 4)
	var fill := FOREST if side == "player" else ENEMY
	if occupied:
		fill = Color(fill.r, fill.g, fill.b, 0.28)
	else:
		fill = Color(fill.r, fill.g, fill.b, 0.88)

	draw_style_box(_slot_style(fill, GLOW if valid_target else BRONZE_DARK, 4 if valid_target else 2), rect)
	_draw_corner_vines(rect)

	if not occupied:
		_draw_empty_sigil(rect)

func _slot_style(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 4
	return style

func _draw_corner_vines(rect: Rect2) -> void:
	var inset := 10.0
	var leaf := MOSS if not valid_target else GLOW
	for corner in [Vector2(rect.position.x + inset, rect.position.y + inset), Vector2(rect.end.x - inset, rect.position.y + inset), Vector2(rect.position.x + inset, rect.end.y - inset), Vector2(rect.end.x - inset, rect.end.y - inset)]:
		draw_circle(corner, 4.0, Color(leaf.r, leaf.g, leaf.b, 0.75))
		draw_circle(corner + Vector2(5, -2), 2.6, Color(leaf.r, leaf.g, leaf.b, 0.45))

func _draw_empty_sigil(rect: Rect2) -> void:
	var center := rect.get_center()
	var span := minf(rect.size.x, rect.size.y) * 0.12
	var ink := Color(0.74, 0.58, 0.33, 0.42)
	if side == "player":
		draw_line(center + Vector2(-span, -span), center + Vector2(span, span), ink, 3.0)
		draw_line(center + Vector2(span, -span), center + Vector2(-span, span), ink, 3.0)
		draw_line(center + Vector2(-span * 1.15, -span * 1.15), center + Vector2(-span * 0.72, -span * 0.72), BRONZE, 4.0)
		draw_line(center + Vector2(span * 1.15, -span * 1.15), center + Vector2(span * 0.72, -span * 0.72), BRONZE, 4.0)
	else:
		draw_arc(center, span, 0.0, TAU, 24, ink, 2.0)
		draw_circle(center, 3.0, ink)

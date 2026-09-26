class_name CanonicalForestLane
extends Button

const CardScript = preload("res://scripts/ui/canonical_forest_card.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

const BARK := Color("241c12")
const BARK_DARK := Color("0c0b08")
const MOSS := Color("45582b")
const RUNE := Color("899b43")
const GOLD := Color("a58842")

var unit = null
var player_side := true
var lane_index := 0
var selected_target := false
var _card_view

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	text = ""
	clip_contents = false
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	queue_redraw()

func set_lane(index: int, is_player_side: bool) -> void:
	lane_index = index
	player_side = is_player_side
	queue_redraw()

func set_unit(value, is_target: bool = false) -> void:
	unit = value
	selected_target = is_target
	if _card_view != null:
		_card_view.queue_free()
		_card_view = null
	if unit != null:
		_card_view = CardScript.new()
		_card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_card_view.disabled = true
		var card := Catalog.find_by_id(str(unit.get("id", "")))
		_card_view.configure(card, int(unit.get("attack", 0)), int(unit.get("hp", 0)), false, true, bool(unit.get("ready", false)))
		add_child(_card_view)
		# La carta ocupa el hueco, no el hueco a la carta. Mantener aire visible
		# alrededor ayuda a leer los cuatro carriles como posiciones físicas.
		var card_h := minf(size.y * 0.84, 128.0)
		var card_w := minf(size.x * 0.58, card_h * 0.72)
		_card_view.position = Vector2((size.x - card_w) * 0.5, (size.y - card_h) * 0.48)
		_card_view.size = Vector2(card_w, card_h)
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 10 or h <= 10:
		return
	draw_rect(Rect2(3, 7, w - 2, h - 2), Color(0, 0, 0, 0.46))
	draw_rect(Rect2(1, 1, w - 6, h - 6), BARK_DARK)
	draw_rect(Rect2(5, 5, w - 14, h - 14), Color("17180f"))
	draw_rect(Rect2(8, 8, w - 20, h - 20), MOSS.darkened(0.45), false, 2.0)
	var root := Color("374424")
	for xside in [1.0, -1.0]:
		for yside in [1.0, -1.0]:
			var corner := Vector2(w * (0.11 if xside > 0 else 0.89), h * (0.12 if yside > 0 else 0.88))
			draw_line(corner, corner + Vector2(18 * xside, 10 * yside), root, 4.0)
			draw_line(corner, corner + Vector2(9 * xside, 20 * yside), root.darkened(0.1), 3.0)
	if unit == null:
		var c := Vector2(w * 0.5, h * 0.5)
		var pulse := 0.22 if not selected_target else 0.55
		draw_circle(c, minf(w, h) * 0.13, Color(RUNE.r, RUNE.g, RUNE.b, pulse), false, 2.0)
		draw_line(c + Vector2(-13, 0), c + Vector2(13, 0), Color(RUNE.r, RUNE.g, RUNE.b, pulse), 2.0)
		draw_line(c + Vector2(0, -13), c + Vector2(0, 13), Color(RUNE.r, RUNE.g, RUNE.b, pulse), 2.0)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(0, h - 12), "CARRIL %d" % (lane_index + 1), HORIZONTAL_ALIGNMENT_CENTER, w - 5, 8, Color(0.63, 0.65, 0.45, 0.54))
	if selected_target:
		draw_rect(Rect2(3, 3, w - 10, h - 10), GOLD, false, 3.0)

class_name VerticalBattleCard
extends Button

## Renderer físico de cartas para la Presentation vertical.
## Sólo consume datos ya resueltos por Application; no conoce reglas del Domain.

const FRAME_TEXTURE_PATH := "res://assets/domains/forest/cards/card_frame_overlay.svg"
const COMPACT_CARD_SIZE := Vector2(156, 230)
const HAND_CARD_SIZE := Vector2(198, 286)

const LEGACY_ART := {
	"ardilla_vigilante": "ardilla",
	"zorro_acechante": "coyote",
	"lobo_joven": "cachorro_de_lobo",
	"cierva_lunar": "alce",
	"cuervo_del_sendero": "cuervo",
	"jabali_de_raiz": "puercoespin",
	"lobo_alfa": "lobo_alfa",
	"oso_ancestral": "oso_grizzly",
	"llamado_de_la_manada": "lobo",
	"crecimiento_violento": "gran_abeto",
	"totem_de_manada": "tocon"
}

const BARK := Color("24180d")
const BARK_DARK := Color("0d0b07")
const GOLD := Color("d1a047")
const GOLD_DARK := Color("755426")
const PARCHMENT := Color("d8c28b")
const PARCHMENT_DARK := Color("9d8757")
const INK := Color("17140d")
const MOSS := Color("57753a")
const GLOW := Color("80d25a")
const BLOOD := Color("7e241e")

var card: Dictionary = {}
var current_attack := -1
var current_health := -1
var selected := false
var compact := false
var ready_for_action := true

var _cached_art_id := ""
var _cached_texture: Texture2D
var _frame_texture: Texture2D

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	text = ""
	clip_contents = false
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	button_down.connect(_press_pose)
	button_up.connect(_restore_pose)
	mouse_entered.connect(_hover_pose)
	mouse_exited.connect(_restore_pose)
	_restore_pose()

func configure(data: Dictionary, atk: int = -1, hp: int = -1, is_selected: bool = false, is_compact: bool = false, is_ready: bool = true) -> void:
	card = data.duplicate(true)
	current_attack = atk
	current_health = hp
	selected = is_selected
	compact = is_compact
	ready_for_action = is_ready
	_cached_art_id = ""
	_cached_texture = null
	if compact:
		# El carril es el gran objetivo táctil; la carta mantiene la proporción
		# física del mockup y queda centrada dentro del carril.
		custom_minimum_size = COMPACT_CARD_SIZE
		anchor_left = 0.5
		anchor_top = 0.5
		anchor_right = 0.5
		anchor_bottom = 0.5
		offset_left = -COMPACT_CARD_SIZE.x * 0.5
		offset_top = -COMPACT_CARD_SIZE.y * 0.5
		offset_right = COMPACT_CARD_SIZE.x * 0.5
		offset_bottom = COMPACT_CARD_SIZE.y * 0.5
	else:
		custom_minimum_size = HAND_CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE if compact else Control.MOUSE_FILTER_STOP
	if is_inside_tree():
		_restore_pose()
	queue_redraw()

func _hover_pose() -> void:
	if disabled or compact:
		return
	pivot_offset = size * 0.5
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2(1.035, 1.035), 0.08)

func _press_pose() -> void:
	if disabled or compact:
		return
	pivot_offset = size * 0.5
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2(0.965, 0.965), 0.05)

func _restore_pose() -> void:
	pivot_offset = size * 0.5
	var target := Vector2(1.055, 1.055) if selected and not compact else Vector2.ONE
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", target, 0.08)
	queue_redraw()

func _draw() -> void:
	if card.is_empty() or size.x < 58.0 or size.y < 80.0:
		return
	var w := size.x
	var h := size.y
	var outer := Rect2(3, 3, w - 6, h - 6)
	var inner := outer.grow(-4)

	draw_rect(Rect2(7, 9, w - 6, h - 4), Color(0, 0, 0, 0.55))
	draw_rect(outer, BARK_DARK)
	draw_rect(inner, BARK)
	draw_rect(inner, GOLD_DARK, false, 2.0)

	var header_h := 28.0 if compact else 40.0
	var stats_h := 30.0 if compact else 42.0
	var art_rect := Rect2(11, header_h + 5, w - 22, h - header_h - stats_h - 13)

	_draw_cost_badge(Vector2(20, 19) if compact else Vector2(26, 25), 11.0 if compact else 15.0)
	_draw_title(Rect2(37 if compact else 48, 6, w - (47 if compact else 61), header_h - 3))
	_draw_art(art_rect)

	var card_type := str(card.get("type", ""))
	if card_type == "creature":
		_draw_creature_stats(Rect2(10, h - stats_h - 5, w - 20, stats_h))
	else:
		_draw_non_creature_footer(Rect2(10, h - stats_h - 5, w - 20, stats_h), card_type)

	_draw_canonical_frame(Rect2(0, 0, w, h))

	if not ready_for_action and card_type == "creature":
		draw_rect(art_rect, Color(0.02, 0.03, 0.02, 0.35))
		var wait_font := 8 if compact else 10
		draw_string(ThemeDB.fallback_font, Vector2(art_rect.position.x, art_rect.end.y - 6), "EN ESPERA", HORIZONTAL_ALIGNMENT_CENTER, art_rect.size.x, wait_font, Color("d5c98f"))

	if selected:
		draw_rect(Rect2(1, 1, w - 2, h - 2), GLOW, false, 4.0)
		draw_rect(Rect2(5, 5, w - 10, h - 10), Color(GLOW.r, GLOW.g, GLOW.b, 0.35), false, 2.0)

func _draw_cost_badge(center: Vector2, radius: float) -> void:
	draw_circle(center + Vector2(2, 2), radius + 2.0, Color(0, 0, 0, 0.42))
	draw_circle(center, radius + 1.0, BARK_DARK)
	draw_circle(center, radius, Color("276b2b"))
	draw_arc(center, radius, 0, TAU, 28, GOLD, 2.0)
	var font_size := 11 if compact else 15
	draw_string(ThemeDB.fallback_font, center + Vector2(-radius, font_size * 0.35), str(int(card.get("cost", 0))), HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, font_size, Color("fff0b8"))

func _draw_title(rect: Rect2) -> void:
	var name := str(card.get("name", "CARTA"))
	var font_size := 7 if compact else 11
	if name.length() > 17:
		font_size -= 1
	if name.length() > 23:
		font_size -= 1
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.68), name, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, maxi(font_size, 6), Color("f4dfaa"))

func _draw_art(rect: Rect2) -> void:
	draw_rect(rect.grow(2), BARK_DARK)
	draw_rect(rect, Color("182117"))
	var texture := _get_art_texture()
	if texture == null:
		_draw_rune_art(rect)
	else:
		var source_size := texture.get_size()
		var src := Rect2(source_size.x * 0.055, source_size.y * 0.185, source_size.x * 0.89, source_size.y * 0.565)
		var dst := rect.grow(-1)
		var src_aspect := src.size.x / src.size.y
		var dst_aspect := dst.size.x / dst.size.y
		var fit := dst.size
		if src_aspect > dst_aspect:
			fit.y = dst.size.x / src_aspect
		else:
			fit.x = dst.size.y * src_aspect
		var pos := dst.position + (dst.size - fit) * 0.5
		draw_texture_rect_region(texture, Rect2(pos, fit), src, Color(0.96, 1.0, 0.92, 1.0), false, true)
		draw_rect(rect, Color(0.03, 0.08, 0.02, 0.09))
	draw_rect(rect, GOLD_DARK, false, 1.4)

func _draw_creature_stats(rect: Rect2) -> void:
	draw_rect(rect, PARCHMENT)
	draw_rect(rect, PARCHMENT_DARK, false, 1.5)
	var atk := current_attack if current_attack >= 0 else int(card.get("attack", 0))
	var hp := current_health if current_health >= 0 else int(card.get("health", 0))
	var cy := rect.position.y + rect.size.y * 0.52
	_draw_stat_orb(Vector2(rect.position.x + rect.size.x * 0.18, cy), atk, true)
	_draw_keyword_rune(Rect2(rect.position.x + rect.size.x * 0.34, rect.position.y + 2, rect.size.x * 0.32, rect.size.y - 4))
	_draw_stat_orb(Vector2(rect.end.x - rect.size.x * 0.18, cy), hp, false)

func _draw_non_creature_footer(rect: Rect2, card_type: String) -> void:
	draw_rect(rect, Color("b09964"))
	draw_rect(rect, PARCHMENT_DARK, false, 1.5)
	var kind := card_type.to_upper()
	if kind == "RELIC":
		kind = "RELIQUIA"
	elif kind == "RITE":
		kind = "RITO"
	elif kind == "SEAL":
		kind = "SELLO"
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.65), kind, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8 if compact else 11, INK)

func _draw_stat_orb(center: Vector2, value: int, attack_stat: bool) -> void:
	var radius := 10.0 if compact else 14.0
	var fill := Color("202018") if attack_stat else BLOOD
	draw_circle(center, radius + 2.0, BARK_DARK)
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0, TAU, 24, GOLD, 1.6)
	draw_string(ThemeDB.fallback_font, center + Vector2(-radius, 4 if compact else 5), str(value), HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 10 if compact else 14, Color("fff1bd"))

func _draw_keyword_rune(rect: Rect2) -> void:
	var keywords: Array = card.get("keywords", [])
	if keywords.is_empty():
		return
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.28
	var code := str(keywords[0])
	match code:
		"GUARDIA":
			var pts := PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius * 0.72, -radius * 0.3), center + Vector2(radius * 0.55, radius * 0.7), center + Vector2(0, radius), center + Vector2(-radius * 0.55, radius * 0.7), center + Vector2(-radius * 0.72, -radius * 0.3), center + Vector2(0, -radius)])
			draw_polyline(pts, INK, 1.8)
		"MANADA":
			for dx in [-0.5, 0.0, 0.5]:
				draw_circle(center + Vector2(float(dx) * radius, 0), radius * 0.17, INK, false, 1.6)
		"EMBOSCADA":
			draw_arc(center, radius, PI, TAU, 18, INK, 1.8)
			draw_circle(center, radius * 0.17, INK)
		_:
			draw_arc(center, radius, 0, TAU, 18, INK, 1.5)
			draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), INK, 1.5)

func _draw_rune_art(rect: Rect2) -> void:
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.28
	draw_circle(center, radius * 1.25, Color(0.18, 0.30, 0.13, 0.50))
	draw_arc(center, radius, 0, TAU, 28, Color("87b555"), 2.0)
	draw_line(center + Vector2(0, -radius * 0.8), center + Vector2(0, radius * 0.8), Color("a7ce66"), 2.0)
	draw_line(center + Vector2(-radius * 0.65, -radius * 0.22), center + Vector2(radius * 0.65, radius * 0.22), Color("a7ce66"), 2.0)
	draw_line(center + Vector2(-radius * 0.52, radius * 0.58), center + Vector2(radius * 0.52, -radius * 0.58), Color("a7ce66"), 2.0)

func _draw_canonical_frame(rect: Rect2) -> void:
	if _frame_texture == null and ResourceLoader.exists(FRAME_TEXTURE_PATH):
		_frame_texture = load(FRAME_TEXTURE_PATH) as Texture2D
	if _frame_texture != null:
		draw_texture_rect(_frame_texture, rect, false, Color(1, 1, 1, 0.97))

func _get_art_texture() -> Texture2D:
	var card_id := str(card.get("id", ""))
	var art_id := str(LEGACY_ART.get(card_id, ""))
	if art_id.is_empty():
		return null
	if _cached_art_id == art_id:
		return _cached_texture
	_cached_art_id = art_id
	_cached_texture = null
	var path := "res://assets/card_full/%s.png" % art_id
	if ResourceLoader.exists(path):
		_cached_texture = load(path) as Texture2D
	return _cached_texture

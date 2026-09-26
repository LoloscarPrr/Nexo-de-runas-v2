class_name CanonicalForestCard
extends Button

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

const PARCHMENT := Color("b9a86c")
const PARCHMENT_LIGHT := Color("d0c48b")
const PARCHMENT_DARK := Color("75673d")
const BARK := Color("2a2115")
const BARK_DARK := Color("100e09")
const BRASS := Color("9b7a35")
const INK := Color("16170f")
const MOSS := Color("62753a")
const GLOW := Color("b8cf62")

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

var card: Dictionary = {}
var current_attack := -1
var current_health := -1
var selected := false
var compact := false
var card_ready := true
var _cached_art_id := ""
var _cached_texture: Texture2D

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
	scale = Vector2(1.045, 1.045) if selected else Vector2.ONE
	queue_redraw()

func configure(data: Dictionary, atk: int = -1, hp: int = -1, is_selected: bool = false, is_compact: bool = false, is_ready: bool = true) -> void:
	card = data.duplicate(true)
	current_attack = atk
	current_health = hp
	selected = is_selected
	compact = is_compact
	card_ready = is_ready
	_cached_art_id = ""
	_cached_texture = null
	# Las cartas del tablero reciben su tamaño del carril. No deben forzar un
	# mínimo mayor que el hueco y sobresalir como ocurría en la build anterior.
	custom_minimum_size = Vector2.ZERO if compact else Vector2(132, 184)
	scale = Vector2(1.045, 1.045) if selected else Vector2.ONE
	if is_inside_tree():
		_restore_pose()
	queue_redraw()

func _hover_pose() -> void:
	if disabled or compact:
		return
	pivot_offset = size * 0.5
	create_tween().tween_property(self, "scale", Vector2(1.025, 1.025), 0.08)

func _press_pose() -> void:
	if disabled:
		return
	pivot_offset = size * 0.5
	create_tween().tween_property(self, "scale", Vector2(0.97, 0.97), 0.05)

func _restore_pose() -> void:
	pivot_offset = size * 0.5
	var target := Vector2(1.045, 1.045) if selected else Vector2.ONE
	create_tween().tween_property(self, "scale", target, 0.08)
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 66 or h < 92:
		return
	draw_rect(Rect2(5, 6, w - 3, h - 2), Color(0, 0, 0, 0.62))
	draw_rect(Rect2(1, 1, w - 7, h - 7), BARK_DARK)
	draw_rect(Rect2(4, 4, w - 13, h - 13), BARK)
	draw_rect(Rect2(7, 7, w - 19, h - 19), PARCHMENT_DARK)
	draw_rect(Rect2(10, 10, w - 25, h - 25), PARCHMENT)
	draw_rect(Rect2(10, 10, w - 25, h - 25), BRASS, false, 1.5)
	var font := ThemeDB.fallback_font
	var head_h := 26.0 if compact else 34.0
	var stat_h := 29.0 if compact else 37.0
	var title_text := str(card.get("name", "CARTA"))
	var title_size := 8 if compact else 9
	if title_text.length() > 16:
		title_size -= 1
	if title_text.length() > 22:
		title_size -= 1
	var badge_center := Vector2(22, 22) if compact else Vector2(25, 25)
	var badge_r := 12.5 if compact else 14.0
	draw_circle(badge_center + Vector2(2, 2), badge_r + 2.0, Color(0, 0, 0, 0.38))
	draw_circle(badge_center, badge_r + 1.0, BARK_DARK)
	draw_circle(badge_center, badge_r, PARCHMENT_LIGHT)
	draw_arc(badge_center, badge_r, 0, TAU, 24, BRASS, 2.0)
	draw_string(font, Vector2(badge_center.x - 9, badge_center.y + 6), str(int(card.get("cost", 0))), HORIZONTAL_ALIGNMENT_CENTER, 18, 14 if compact else 15, INK)
	draw_string(font, Vector2(39 if compact else 44, 27 if compact else 30), title_text, HORIZONTAL_ALIGNMENT_CENTER, w - (51 if compact else 58), title_size, INK)
	draw_line(Vector2(15, head_h + 7), Vector2(w - 17, head_h + 7), Color(0.25, 0.22, 0.12, 0.65), 1.0)

	var art_top := head_h + 11.0
	var art_bottom := h - stat_h - 13.0
	var art_rect := Rect2(13, art_top, w - 29, maxf(32.0, art_bottom - art_top))
	draw_rect(art_rect.grow(3), BARK_DARK)
	draw_rect(art_rect, Color("20291a"))
	_draw_art(art_rect)
	draw_rect(art_rect, BRASS.darkened(0.25), false, 1.5)

	var card_type := str(card.get("type", ""))
	var stat_y := h - stat_h - 10.0
	if card_type == Catalog.TYPE_CREATURE:
		draw_rect(Rect2(11, stat_y, w - 25, stat_h), PARCHMENT_LIGHT)
		draw_rect(Rect2(11, stat_y, w - 25, stat_h), INK, false, 1.5)
		var atk := current_attack if current_attack >= 0 else int(card.get("attack", 0))
		var hp := current_health if current_health >= 0 else int(card.get("health", 0))
		_draw_stat_glyph(Vector2(26, stat_y + stat_h * 0.51), atk, true)
		_draw_keyword_rune(Rect2(w * 0.36, stat_y + 2, w * 0.28, stat_h - 4))
		_draw_stat_glyph(Vector2(w - 34, stat_y + stat_h * 0.51), hp, false)
	else:
		draw_rect(Rect2(11, stat_y, w - 25, stat_h), Color("94844f"))
		draw_rect(Rect2(11, stat_y, w - 25, stat_h), INK, false, 1.5)
		var kind := "RITO"
		if card_type == Catalog.TYPE_RELIC:
			kind = "RELIQUIA"
		elif card_type == Catalog.TYPE_SEAL:
			kind = "SELLO"
		draw_string(font, Vector2(16, stat_y + stat_h * 0.68), kind, HORIZONTAL_ALIGNMENT_CENTER, w - 35, 9 if compact else 10, INK)

	if not card_ready and card_type == Catalog.TYPE_CREATURE:
		draw_rect(art_rect, Color(0.03, 0.04, 0.02, 0.30))
		draw_string(font, Vector2(art_rect.position.x, art_rect.end.y - 6), "EN ESPERA", HORIZONTAL_ALIGNMENT_CENTER, art_rect.size.x, 8, Color(0.84, 0.80, 0.58, 0.90))
	if selected:
		draw_rect(Rect2(-1, -1, w - 3, h - 3), GLOW, false, 4.0)
		draw_rect(Rect2(3, 3, w - 11, h - 11), Color(GLOW.r, GLOW.g, GLOW.b, 0.24), false, 2.0)

func _draw_art(rect: Rect2) -> void:
	var texture := _get_art_texture()
	if texture == null:
		_draw_rune_art(rect)
		return
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
	draw_texture_rect_region(texture, Rect2(pos, fit), src, Color(0.88, 0.92, 0.78, 1.0), false, true)
	draw_rect(rect, Color(0.08, 0.14, 0.05, 0.14))
	for y in range(int(rect.position.y) + 2, int(rect.end.y), 4):
		draw_line(Vector2(rect.position.x + 1, y), Vector2(rect.end.x - 1, y), Color(0, 0, 0, 0.035), 1)

func _draw_rune_art(rect: Rect2) -> void:
	var center := rect.get_center()
	var r := minf(rect.size.x, rect.size.y) * 0.28
	draw_circle(center, r, Color(0.26, 0.34, 0.15, 0.32))
	draw_arc(center, r * 0.82, 0, TAU, 24, MOSS, 2.0)
	draw_line(center + Vector2(0, -r * 0.72), center + Vector2(0, r * 0.70), GLOW.darkened(0.2), 2.0)
	draw_line(center + Vector2(-r * 0.58, -r * 0.18), center + Vector2(r * 0.58, r * 0.18), GLOW.darkened(0.2), 2.0)
	draw_line(center + Vector2(-r * 0.48, r * 0.54), center + Vector2(r * 0.48, -r * 0.54), GLOW.darkened(0.2), 2.0)

func _draw_stat_glyph(center: Vector2, value: int, attack_stat: bool) -> void:
	var font := ThemeDB.fallback_font
	if attack_stat:
		draw_line(center + Vector2(-7, 7), center + Vector2(6, -6), INK, 2.0)
		draw_line(center + Vector2(2, -7), center + Vector2(8, -7), INK, 2.0)
	else:
		var pts := PackedVector2Array([center + Vector2(0, -9), center + Vector2(8, -3), center + Vector2(6, 6), center + Vector2(0, 9), center + Vector2(-6, 6), center + Vector2(-8, -3), center + Vector2(0, -9)])
		draw_polyline(pts, INK, 1.7)
	draw_string(font, center + Vector2(9, 5), str(value), HORIZONTAL_ALIGNMENT_LEFT, 18, 13, INK)

func _draw_keyword_rune(rect: Rect2) -> void:
	var keywords: Array = card.get("keywords", [])
	if keywords.is_empty():
		return
	var code := str(keywords[0])
	var c := rect.get_center()
	var r := minf(rect.size.x, rect.size.y) * 0.30
	match code:
		"EMBOSCADA":
			draw_arc(c, r, PI, TAU, 16, INK, 1.7)
			draw_circle(c + Vector2(0, -1), r * 0.18, INK)
		"MANADA":
			for dx in [-0.55, 0.0, 0.55]:
				var p := c + Vector2(float(dx) * r, 0)
				draw_circle(p, r * 0.20, INK, false, 1.6)
		"GUARDIA":
			var pts := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.78, -r * 0.35), c + Vector2(r * 0.58, r * 0.75), c + Vector2(0, r), c + Vector2(-r * 0.58, r * 0.75), c + Vector2(-r * 0.78, -r * 0.35), c + Vector2(0, -r)])
			draw_polyline(pts, INK, 1.7)
		_:
			draw_arc(c, r, 0, TAU, 16, INK, 1.5)
			draw_line(c + Vector2(-r, 0), c + Vector2(r, 0), INK, 1.5)

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

extends Button

const SketchAtlasScript = preload("res://scripts/ui/mockup_hud/sketch_atlas.gd")

var sketch_key := "deck"
var count := 0
var pulse_active := false
var time := 0.0
var draw_strength := 0.0
var press_strength := 0.0
var _art: TextureRect
var _count_label: Label

func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())

	_art = TextureRect.new()
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_art.texture = SketchAtlasScript.texture_for(sketch_key)
	_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_art)

	# El boceto trae un número de muestra. Esta placa oscura lo cubre y muestra
	# siempre el conteo real del BattleState.
	_count_label = Label.new()
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_label.text = str(count)
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_label.add_theme_font_size_override("font_size", 16)
	_count_label.add_theme_color_override("font_color", Color("d4dc72"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("10160d")
	panel.border_color = Color("697337")
	panel.set_border_width_all(2)
	_count_label.add_theme_stylebox_override("normal", panel)
	_count_label.position = Vector2(size.x * 0.31, size.y * 0.69)
	_count_label.size = Vector2(size.x * 0.38, size.y * 0.24)
	add_child(_count_label)

	resized.connect(_layout_children)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(true)
	call_deferred("_layout_children")

func _layout_children() -> void:
	pivot_offset = size * 0.5
	if _art != null:
		_art.position = Vector2.ZERO
		_art.size = size
	if _count_label != null:
		_count_label.position = Vector2(size.x * 0.31, size.y * 0.69)
		_count_label.size = Vector2(size.x * 0.38, size.y * 0.24)
		_count_label.add_theme_font_size_override("font_size", maxi(11, int(size.y * 0.13)))

func animate_draw() -> void:
	draw_strength = 1.0

func _process(delta: float) -> void:
	time += delta
	draw_strength = maxf(0.0, draw_strength - delta * 4.5)
	press_strength = maxf(0.0, press_strength - delta * 8.0)
	var pulse := 1.0
	if pulse_active and not disabled:
		pulse += sin(time * TAU / 2.0) * 0.008
	scale = Vector2.ONE * pulse * (1.0 - press_strength * 0.03)
	position.y -= 8.0 * sin(draw_strength * PI) * delta * 4.5
	modulate = Color(0.45, 0.47, 0.34, 0.58) if disabled else Color.WHITE

func _on_down() -> void:
	press_strength = 1.0

func _on_up() -> void:
	press_strength = 0.45

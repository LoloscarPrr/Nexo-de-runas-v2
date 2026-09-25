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
var _base_position := Vector2.ZERO
var _base_set := false

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
	call_deferred("_capture_base")

func _capture_base() -> void:
	_base_position = position
	_base_set = true

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
	draw_strength = maxf(0.0, draw_strength - delta * 3.8)
	press_strength = maxf(0.0, press_strength - delta * 8.0)

	var phase := 1.7 if sketch_key == "squirrels" else 0.0
	var idle_sway := sin(time * TAU / 3.1 + phase) * 0.55
	var idle_bob := sin(time * TAU / 2.6 + phase) * 0.8
	var pulse := 1.0
	if pulse_active and not disabled:
		pulse += sin(time * TAU / 1.7 + phase) * 0.014

	var draw_arc := sin(draw_strength * PI)
	var draw_kick := -15.0 * draw_arc
	var draw_tilt := (2.2 if sketch_key == "deck" else -2.2) * draw_arc
	scale = Vector2.ONE * pulse * (1.0 + draw_arc * 0.045) * (1.0 - press_strength * 0.035)
	rotation_degrees = idle_sway + draw_tilt + sin(time * 38.0) * press_strength * 0.25
	if _base_set:
		position = _base_position + Vector2(0, idle_bob + draw_kick + press_strength * 2.0)

	if disabled:
		modulate = Color(0.45, 0.47, 0.34, 0.58)
	else:
		var glow := 0.025 * (0.5 + 0.5 * sin(time * 4.0 + phase)) if pulse_active else 0.0
		modulate = Color(1.0 + glow, 1.0 + glow, 1.0 + glow * 0.55, 1.0)

func _on_down() -> void:
	press_strength = 1.0

func _on_up() -> void:
	press_strength = 0.45

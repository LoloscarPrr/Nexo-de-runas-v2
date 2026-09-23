extends Button

var pulse_active := false
var time := 0.0
var press_amount := 0.0

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	pivot_offset = size * 0.5
	resized.connect(_sync_pivot)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(true)

func _sync_pivot() -> void:
	pivot_offset = size * 0.5

func _process(delta: float) -> void:
	time += delta
	press_amount = move_toward(press_amount, 0.0, delta * 8.0)
	var pulse := 1.0
	if pulse_active and not disabled:
		pulse = 1.0 + sin(time * TAU / 1.2) * 0.018
	var press_scale := 1.0 - press_amount * 0.03
	scale = Vector2.ONE * pulse * press_scale
	if pulse_active and not disabled:
		modulate = Color(1.0, 1.0, 1.0, 0.90 + sin(time * TAU / 1.2) * 0.10)
	else:
		modulate = Color.WHITE

func _on_down() -> void:
	press_amount = 1.0

func _on_up() -> void:
	press_amount = 0.45

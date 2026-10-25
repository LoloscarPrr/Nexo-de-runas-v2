class_name CardPreview
extends Control

signal inspection_requested

const CardScript = preload("res://scripts/presentation/battle/vertical_battle_card.gd")
const CARD_SIZE := Vector2(198, 286)
var card_view
var _stage: Control
var _definition: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	card_view = CardScript.new()
	_stage.add_child(card_view)
	card_view.pressed.connect(func():
		if not card_view.consume_inspection_press():
			inspection_requested.emit())
	card_view.inspection_requested.connect(func(): inspection_requested.emit())
	resized.connect(_layout_card)
	configure(_definition)

func configure(card: Dictionary) -> void:
	_definition = card.duplicate(true)
	if not is_instance_valid(card_view):
		return
	card_view.configure(_definition)
	card_view.size = CARD_SIZE
	_layout_card.call_deferred()

func cancel_pointer_gesture() -> void:
	if is_instance_valid(card_view):
		card_view.cancel_pointer_gesture()

func _layout_card() -> void:
	var factor := minf(size.x / CARD_SIZE.x, size.y / CARD_SIZE.y)
	_stage.scale = Vector2.ONE * factor
	_stage.position = (size - CARD_SIZE * factor) * 0.5

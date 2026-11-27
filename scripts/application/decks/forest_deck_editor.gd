class_name ForestDeckEditor
extends RefCounted

## One editable Forest deck. Only validated complete decks become active.
## The repository is injected by the composition root; other save slots are
## never read or written here. Catalog access does not grant card ownership.
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Port = preload("res://scripts/application/ports/save_repository_port.gd")
const SAVE_SLOT := "constructed_forest_deck_v1"
const FORMAT_VERSION := 1
const DOMAIN := "forest"

var _repository: Port
var _draft: Array[String] = []
var _draft_name := "Manada del Claro"
var _saved: Array[String] = []
var _saved_name := ""
var _load_notice := ""
var _future_format := false

func _init(repository: Port) -> void:
	_repository = repository
	_load_saved()
	_draft = _saved.duplicate() if not _saved.is_empty() else Catalog.starter_deck(DOMAIN)
	_draft_name = _saved_name if not _saved.is_empty() else "Manada del Claro"

func snapshot() -> Dictionary:
	var counts := {}
	var curve: Array[int] = [0, 0, 0, 0, 0, 0, 0]
	for card_id in _draft:
		counts[card_id] = int(counts.get(card_id, 0)) + 1
		var card := Catalog.find_by_id(card_id)
		curve[clampi(int(card.get("cost", 0)), 0, 6)] += 1
	var errors := validation_errors()
	var baseline: Array[String] = _saved if not _saved.is_empty() else Catalog.starter_deck(DOMAIN)
	var baseline_name := _saved_name if not _saved.is_empty() else "Manada del Claro"
	return {
		"name": _draft_name, "card_ids": _draft.duplicate(), "count": _draft.size(),
		"counts": counts, "curve": curve, "errors": errors,
		"can_save": errors.is_empty(), "has_saved": not _saved.is_empty(),
		"dirty": _draft != baseline or _draft_name.strip_edges() != baseline_name,
		"load_notice": _load_notice
	}

func card_state(card_id: String) -> Dictionary:
	var candidate := _draft.duplicate()
	candidate.append(card_id)
	return {
		"quantity": _draft.count(card_id), "limit": Catalog.copy_limit(card_id),
		"can_add": Catalog.validate_deck(candidate, DOMAIN, true).is_empty(),
		"can_remove": _draft.has(card_id)
	}

func add_card(card_id: String) -> Dictionary:
	var candidate := _draft.duplicate()
	candidate.append(card_id)
	var errors := Catalog.validate_deck(candidate, DOMAIN, true)
	if not errors.is_empty():
		return _result(false, "Quita una carta para hacer espacio." if _draft.size() >= 20 else "No se puede añadir otra copia de esta carta.")
	_draft = candidate
	return _result(true)

func remove_card(card_id: String) -> Dictionary:
	var index := _draft.find(card_id)
	if index < 0:
		return _result(false, "Esta carta no está en tu mazo.")
	_draft.remove_at(index)
	return _result(true)

func set_name(value: String) -> void:
	_draft_name = value.substr(0, 32)

func restore_starter() -> void:
	_draft = Catalog.starter_deck(DOMAIN)
	_draft_name = "Manada del Claro"

func validation_errors() -> Array[String]:
	var errors := Catalog.validate_deck(_draft, DOMAIN)
	if _draft_name.strip_edges().is_empty():
		errors.append("Escribe un nombre para tu mazo.")
	if _future_format:
		errors.append("El mazo guardado necesita una versión más reciente del juego.")
	return errors

func save_deck() -> Dictionary:
	var errors := validation_errors()
	if not errors.is_empty():
		return _result(false, errors[0])
	var clean_name := _draft_name.strip_edges()
	var error := _repository.save(SAVE_SLOT, {
		"format_version": FORMAT_VERSION, "domain": DOMAIN,
		"name": clean_name, "card_ids": _draft.duplicate()
	})
	if error != OK:
		return _result(false, "No se pudo guardar. Tu borrador sigue disponible para reintentar.")
	_saved = _draft.duplicate()
	_saved_name = clean_name
	_draft_name = clean_name
	_load_notice = ""
	return _result(true, "Mazo guardado. Se usará al pulsar JUGAR.")

func deck_for_battle() -> Array[String]:
	return _saved.duplicate()

func active_name() -> String:
	return _saved_name

func _load_saved() -> void:
	var payload := _repository.load(SAVE_SLOT)
	if payload.is_empty() and not _repository.exists(SAVE_SLOT):
		return
	_load_notice = "No se pudo recuperar el mazo guardado. Puedes editar el mazo inicial."
	var version = payload.get("format_version", 0)
	if typeof(version) != TYPE_INT and typeof(version) != TYPE_FLOAT:
		return
	if int(version) > FORMAT_VERSION:
		_future_format = true
		_load_notice = "El mazo guardado necesita una versión más reciente del juego."
		return
	if int(version) != FORMAT_VERSION or payload.get("domain") != DOMAIN:
		return
	var raw_ids = payload.get("card_ids")
	var raw_name = payload.get("name")
	if typeof(raw_ids) != TYPE_ARRAY or typeof(raw_name) != TYPE_STRING:
		return
	if raw_name.strip_edges().is_empty() or raw_name.length() > 32:
		return
	var ids: Array[String] = []
	for card_id in raw_ids:
		if typeof(card_id) != TYPE_STRING:
			return
		ids.append(card_id)
	if not Catalog.validate_deck(ids, DOMAIN).is_empty():
		return
	_saved = ids
	_saved_name = raw_name.strip_edges()
	_load_notice = ""

func _result(ok: bool, message: String = "") -> Dictionary:
	return {"ok": ok, "message": message, "snapshot": snapshot()}

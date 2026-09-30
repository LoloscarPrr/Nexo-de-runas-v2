extends SceneTree

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const CardDefinitionScript = preload("res://scripts/domain/definitions/card_definition.gd")
const CardInstanceScript = preload("res://scripts/domain/entities/card_instance.gd")
const BoardStateScript = preload("res://scripts/domain/entities/board_state.gd")
const CostDefinitionScript = preload("res://scripts/domain/value_objects/cost_definition.gd")
const CostResolverScript = preload("res://scripts/domain/services/cost_resolver.gd")
const BattleScript = preload("res://scripts/domain/canonical_battle_state.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_card_definition_and_instances()
	_test_board_state()
	_test_cost_resolver_and_events()
	print("Domain entity model checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_card_definition_and_instances() -> void:
	var raw := Catalog.find_by_id("lobo_joven")
	var definition = CardDefinitionScript.from_dictionary(raw)
	check(definition.validate().is_empty(), "CardDefinition accepts canonical catalog data")
	check(definition.id == "lobo_joven", "CardDefinition preserves definition id")
	check(definition.base_attack == 2 and definition.base_health == 3, "CardDefinition exposes base stats")

	var first = CardInstanceScript.from_definition(definition, "card-instance-a", "player")
	var second = CardInstanceScript.from_definition(definition, "card-instance-b", "player")
	check(first.is_valid() and second.is_valid(), "CardInstance requires stable identity")
	check(first.definition_id == second.definition_id, "Two instances can share one definition")
	check(first.instance_id != second.instance_id, "Two copies keep distinct instance ids")
	first.current_health -= 1
	first.add_modifier({"attack": 1, "source": "campfire"})
	check(second.current_health == definition.base_health, "Damage on one instance does not affect another copy")
	check(second.modifiers.is_empty(), "Persistent/runtime modifiers remain instance-specific")

func _test_board_state() -> void:
	var board = BoardStateScript.new()
	check(board.lane_count == 5, "BoardState defaults to exactly five lanes")
	check(board.player_lanes.size() == 5 and board.enemy_lanes.size() == 5, "BoardState creates five lanes per side")
	check(board.occupy(BoardStateScript.SIDE_PLAYER, 4, "card-instance-a"), "Fifth player lane can be occupied")
	check(not board.occupy(BoardStateScript.SIDE_PLAYER, 4, "card-instance-b"), "Occupied lane rejects a second card")
	check(str(board.lane(BoardStateScript.SIDE_PLAYER, 4).occupant_instance_id) == "card-instance-a", "LaneState stores occupant instance identity")
	check(board.clear_lane(BoardStateScript.SIDE_PLAYER, 4) == "card-instance-a", "LaneState returns removed occupant")
	check(board.lane(BoardStateScript.SIDE_PLAYER, 4).is_empty(), "Cleared fifth lane is empty again")

func _test_cost_resolver_and_events() -> void:
	var battle = BattleScript.new()
	battle.setup_starter(Catalog.DOMAIN_FOREST)
	battle.energy_current = 3
	var cost = CostDefinitionScript.energy(2)
	check(CostResolverScript.can_pay(cost, battle), "CostResolver validates available Energy")
	check(CostResolverScript.pay(cost, battle), "CostResolver pays a valid Energy cost")
	check(battle.energy_current == 1, "CostResolver changes payer resource state")
	check(not CostResolverScript.can_pay(CostDefinitionScript.energy(2), battle), "CostResolver rejects insufficient Energy")
	var events := battle.drain_events()
	check(events.size() == 1, "Paying a cost emits one resource event")
	if not events.is_empty():
		check(str(events[0].get("type", "")) == "RESOURCE_SPENT", "Resource payment emits RESOURCE_SPENT")
		check(int(Dictionary(events[0].get("payload", {})).get("amount", 0)) == 2, "Resource event records paid amount")

class_name EffectResolver
extends RefCounted

const EffectScript = preload("res://scripts/domain/definitions/effect_definition.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const GameEventScript = preload("res://scripts/domain/events/game_event.gd")

static func apply(effect: Dictionary, target: Dictionary, context: Dictionary, battle) -> bool:
	var effect_type := str(effect.get("type", ""))
	var params: Dictionary = effect.get("params", {})
	var ok := false
	match effect_type:
		EffectScript.GAIN_RESOURCE:
			var amount := int(params.get("amount", 0))
			var resource := str(params.get("resource", "essence"))
			if resource == "essence":
				battle.gain_essence(amount)
				ok = true
			elif resource == "energy":
				battle.grant_temporary_energy(amount)
				ok = true
		EffectScript.DAMAGE_UNIT:
			if target.get("unit", null) != null:
				battle._deal_damage_to_unit(str(target.get("side", "")) == "player", int(target.get("lane", -1)), int(params.get("amount", 0)))
				ok = true
		EffectScript.DRAW_CARDS:
			ok = true
			for i in range(maxi(0, int(params.get("amount", 0)))):
				battle.draw_card()
		EffectScript.MODIFY_STATS_TEMP:
			var unit = target.get("unit", null)
			if unit != null:
				var attack_bonus := int(params.get("attack", 0))
				var health_bonus := int(params.get("health", 0))
				unit["attack"] = int(unit.get("attack", 0)) + attack_bonus
				unit["temp_attack"] = int(unit.get("temp_attack", 0)) + attack_bonus
				if health_bonus != 0:
					unit["hp"] = int(unit.get("hp", 0)) + health_bonus
					unit["max_hp"] = int(unit.get("max_hp", 1)) + health_bonus
					unit["temp_health"] = int(unit.get("temp_health", 0)) + health_bonus
				ok = true
		EffectScript.SUMMON_TOKEN:
			var lane := int(target.get("lane", -1))
			if lane >= 0 and lane < battle.LANE_COUNT and battle.player_lanes[lane] == null:
				battle.player_lanes[lane] = battle._make_token(
					str(params.get("id", "token")),
					str(params.get("name", "TOKEN")),
					int(params.get("attack", 0)),
					int(params.get("health", 1)),
					Array(params.get("tags", []))
				)
				ok = true
		EffectScript.REVEAL_TOP:
			battle.last_revealed.clear()
			var amount := mini(maxi(0, int(params.get("amount", 0))), battle.draw_pile.size())
			for i in range(amount):
				battle.last_revealed.append(battle.draw_pile[i])
			if bool(params.get("draw_first", false)) and amount > 0 and battle.hand.size() < battle.MAX_HAND:
				battle.hand.append(battle.draw_pile.pop_front())
			ok = true
		EffectScript.KILL_UNIT:
			if target.get("unit", null) != null:
				battle._kill_unit(str(target.get("side", "")) == "player", int(target.get("lane", -1)))
				ok = true
		EffectScript.RETURN_CREATURE_FROM_DISCARD:
			var max_cost := int(params.get("max_cost", 999))
			for i in range(battle.discard_pile.size() - 1, -1, -1):
				var candidate := Catalog.find_by_id(battle.discard_pile[i])
				if str(candidate.get("type", "")) == Catalog.TYPE_CREATURE and int(candidate.get("cost", 999)) <= max_cost and battle.hand.size() < battle.MAX_HAND:
					battle.hand.append(battle.discard_pile[i])
					battle.discard_pile.remove_at(i)
					ok = true
					break
	if ok:
		battle.event_queue.push(GameEventScript.create("EFFECT_APPLIED", str(context.get("source_card_id", "")), [], {"effect": effect_type, "target_lane": int(target.get("lane", -1)), "target_side": str(target.get("side", "none"))}))
	return ok

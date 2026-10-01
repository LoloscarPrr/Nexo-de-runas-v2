class_name EffectResolver
extends RefCounted

const EffectScript = preload("res://scripts/domain/definitions/effect_definition.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const GameEventScript = preload("res://scripts/domain/events/game_event.gd")

static func apply(effect: Dictionary, target: Dictionary, context: Dictionary, battle) -> bool:
	var effect_type := str(effect.get("type", ""))
	var params: Dictionary = effect.get("params", {})
	var source_side := str(context.get("source_side", "player"))
	var ok := false
	match effect_type:
		EffectScript.GAIN_RESOURCE:
			var amount := int(params.get("amount", 0))
			var resource := str(params.get("resource", "essence"))
			if source_side == "enemy":
				if resource == "essence" and battle.has_method("cpu_gain_essence"):
					battle.cpu_gain_essence(amount)
					ok = true
				elif resource == "energy" and battle.has_method("cpu_grant_temporary_energy"):
					battle.cpu_grant_temporary_energy(amount)
					ok = true
			elif resource == "essence":
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
				if source_side == "enemy" and battle.has_method("cpu_draw_card"):
					battle.cpu_draw_card()
				else:
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
			var target_side := str(target.get("side", source_side))
			var lanes: Array = battle.enemy_lanes if target_side == "enemy" else battle.player_lanes
			if lane >= 0 and lane < battle.LANE_COUNT and lanes[lane] == null:
				var token: Dictionary = battle._make_token(
					str(params.get("id", "token")),
					str(params.get("name", "TOKEN")),
					int(params.get("attack", 0)),
					int(params.get("health", 1)),
					Array(params.get("tags", []))
				)
				if target_side == "enemy":
					token["domain"] = battle.enemy_domain
				lanes[lane] = token
				ok = true
		EffectScript.REVEAL_TOP:
			if source_side == "enemy" and battle.has_method("cpu_draw_card"):
				battle.cpu_last_revealed.clear()
				var cpu_amount := mini(maxi(0, int(params.get("amount", 0))), battle.cpu_draw_pile.size())
				for i in range(cpu_amount):
					battle.cpu_last_revealed.append(battle.cpu_draw_pile[i])
				if bool(params.get("draw_first", false)) and cpu_amount > 0 and battle.cpu_hand.size() < battle.MAX_HAND:
					battle.cpu_draw_card()
				ok = true
			else:
				battle.last_revealed.clear()
				var amount := mini(maxi(0, int(params.get("amount", 0))), battle.draw_pile.size())
				for i in range(amount):
					battle.last_revealed.append(battle.draw_pile[i])
				if bool(params.get("draw_first", false)) and amount > 0 and battle.hand.size() < battle.MAX_HAND:
					battle.draw_card()
				ok = true
		EffectScript.KILL_UNIT:
			if target.get("unit", null) != null:
				battle._kill_unit(str(target.get("side", "")) == "player", int(target.get("lane", -1)))
				ok = true
		EffectScript.RETURN_CREATURE_FROM_DISCARD:
			var max_cost := int(params.get("max_cost", 999))
			var discard: Array = battle.enemy_discard if source_side == "enemy" else battle.discard_pile
			var destination: Array = battle.cpu_hand if source_side == "enemy" and battle.has_method("cpu_draw_card") else battle.hand
			for i in range(discard.size() - 1, -1, -1):
				var candidate := Catalog.find_by_id(discard[i])
				if str(candidate.get("type", "")) == Catalog.TYPE_CREATURE and int(candidate.get("cost", 999)) <= max_cost and destination.size() < battle.MAX_HAND:
					destination.append(discard[i])
					discard.remove_at(i)
					ok = true
					break
	if ok:
		battle.event_queue.push(GameEventScript.create("EFFECT_APPLIED", str(context.get("source_card_id", "")), [], {
			"effect": effect_type,
			"source_side": source_side,
			"target_lane": int(target.get("lane", -1)),
			"target_side": str(target.get("side", "none"))
		}))
	return ok

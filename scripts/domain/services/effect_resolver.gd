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
			var damage_targets := _targets(target)
			if not damage_targets.is_empty():
				ok = true
				for item in damage_targets:
					battle._deal_damage_to_unit(str(item.get("side", "")) == "player", int(item.get("lane", -1)), int(params.get("amount", 0)), str(context.get("source_card_id", "")), source_side)
		EffectScript.HEAL_UNIT:
			var heal_targets := _targets(target)
			if not heal_targets.is_empty():
				ok = true
				for item in heal_targets:
					battle._heal_unit(str(item.get("side", "")) == "player", int(item.get("lane", -1)), int(params.get("amount", 0)), str(context.get("source_card_id", "")), source_side)
		EffectScript.DRAW_CARDS:
			ok = true
			for i in range(maxi(0, int(params.get("amount", 0)))):
				if source_side == "enemy" and battle.has_method("cpu_draw_card"):
					battle.cpu_draw_card()
				else:
					battle.draw_card()
		EffectScript.DRAW_THEN_DISCARD:
			ok = true
			for i in range(maxi(0, int(params.get("draw", 0)))):
				if source_side == "enemy" and battle.has_method("cpu_draw_card"):
					battle.cpu_draw_card()
				else:
					battle.draw_card()
			battle.queue_pending_discard(source_side, maxi(0, int(params.get("discard", 0))), str(context.get("source_card_id", "")))
		EffectScript.MODIFY_STATS_PERMANENT:
			var permanent_targets := _targets(target)
			for item in permanent_targets:
				if battle._modify_unit_stats_permanent(str(item.get("side", "")), int(item.get("lane", -1)), int(params.get("attack", 0)), int(params.get("health", 0)), str(context.get("source_card_id", "")), source_side):
					ok = true
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
			var summon_targets := _targets_allow_empty(target)
			for item in summon_targets:
				var lane := int(item.get("lane", -1))
				var target_side := str(item.get("side", source_side))
				var lanes: Array = battle.enemy_lanes if target_side == "enemy" else battle.player_lanes
				if lane < 0 or lane >= battle.LANE_COUNT or lanes[lane] != null:
					continue
				var token: Dictionary = battle._make_token(str(params.get("id", "token")), str(params.get("name", "TOKEN")), int(params.get("attack", 0)), int(params.get("health", 1)), Array(params.get("tags", [])))
				if target_side == "enemy": token["domain"] = battle.enemy_domain
				lanes[lane] = token
				battle._recalculate_auras(target_side)
				if int(params.get("attack_if_adjacent", 0)) != 0 and battle._has_adjacent_ally(target_side, lane):
					var bonus := int(params.get("attack_if_adjacent", 0))
					token["attack"] = int(token.get("attack", 0)) + bonus
					token["temp_attack"] = int(token.get("temp_attack", 0)) + bonus
				battle.event_queue.push(GameEventScript.create("UNIT_SUMMONED", str(token.get("id", "")), [], {"side": target_side, "lane": lane, "token": true, "source_id": str(context.get("source_card_id", ""))}))
				battle._trigger_active_relics(target_side, "first_summon_per_turn", {"source_side":target_side,"source_lane":lane,"target_lane":lane,"summoned_card_id":str(token.get("id",""))})
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
				battle._kill_unit(str(target.get("side", "")) == "player", int(target.get("lane", -1)), str(params.get("reason", "destroyed")), str(context.get("source_card_id", "")), source_side)
				ok = true
		EffectScript.APPLY_STATUS:
			var status_targets := _targets(target)
			for item in status_targets:
				if battle._apply_status_to_unit(str(item.get("side", "")), int(item.get("lane", -1)), str(params.get("status", "")), str(params.get("duration", "until_next_turn")), str(context.get("source_card_id", "")), source_side):
					ok = true
		EffectScript.MOVE_UNIT, EffectScript.FORCED_MOVE_UNIT:
			var move_targets := _targets(target)
			if move_targets.size() == 1:
				var item: Dictionary = move_targets[0]
				ok = battle._move_unit(str(item.get("side", "")), int(item.get("lane", -1)), int(context.get("destination_lane", -1)), effect_type == EffectScript.FORCED_MOVE_UNIT, str(context.get("source_card_id", "")), source_side, int(params.get("max_distance", -1)))
		EffectScript.SWAP_UNITS:
			var swap_targets := _targets(target)
			if swap_targets.size() == 2 and str(swap_targets[0].get("side", "")) == str(swap_targets[1].get("side", "")):
				ok = battle._swap_units(str(swap_targets[0].get("side", "")), int(swap_targets[0].get("lane", -1)), int(swap_targets[1].get("lane", -1)), str(context.get("source_card_id", "")), source_side)
		EffectScript.MOVE_DISCARD_TO_DECK_BOTTOM:
			ok = battle._move_discard_creature_to_deck_bottom(source_side, str(context.get("discard_card_id", "")), int(params.get("max_cost", 999)), str(context.get("source_card_id", "")))
		EffectScript.ADD_COST_MODIFIER:
			battle.add_cost_modifier(source_side, str(params.get("id", str(context.get("source_card_id", "")))), int(params.get("delta", 0)), int(params.get("floor", 1)), str(params.get("duration", "turn")), str(params.get("card_type", "")), int(params.get("min_base_cost", -1)))
			ok = true
		EffectScript.HEAL_NEXUS:
			ok = battle._heal_nexus(source_side, int(params.get("amount", 0)), str(context.get("source_card_id", ""))) > 0
		EffectScript.DAMAGE_NEXUS:
			ok = battle._damage_enemy_nexus(source_side, int(params.get("amount", 0)), str(context.get("source_card_id", ""))) > 0
		EffectScript.HEAL_NEXUS_IF_TARGET_GONE:
			ok = true
			var original_unit = target.get("unit", null)
			if original_unit != null and int(original_unit.get("hp", 1)) <= 0:
				battle._heal_nexus(source_side, int(params.get("amount", 0)), str(context.get("source_card_id", "")))
		EffectScript.ADD_AURA:
			var aura_targets := _targets(target)
			if aura_targets.size() == 1:
				var item: Dictionary = aura_targets[0]
				ok = battle._add_aura_to_unit(str(item.get("side", "")), int(item.get("lane", -1)), str(params.get("id", "")), int(params.get("attack", 0)), int(params.get("health", 0)), int(params.get("radius", 1)))
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

static func _targets(target: Dictionary) -> Array:
	var batch: Array = Array(target.get("targets", []))
	if not batch.is_empty():
		return batch
	if bool(target.get("valid", false)) and target.get("unit", null) != null:
		return [target]
	return []

static func _targets_allow_empty(target: Dictionary) -> Array:
	var batch: Array = Array(target.get("targets", []))
	if not batch.is_empty():
		return batch
	if bool(target.get("valid", false)):
		return [target]
	return []

extends RefCounted
class_name RelationshipEncounterTracker
## Tracks one local encounter at a time: involved enemies, counters, summary. No stat writes.


signal encounter_started(summary: RelationshipEncounterSummary)
signal encounter_updated(summary: RelationshipEncounterSummary)
signal encounter_ended(summary: RelationshipEncounterSummary)
signal encounter_aborted


var is_active: bool = false

var _summary: RelationshipEncounterSummary
var _encounter_counter: int = 0


func get_active_summary() -> RelationshipEncounterSummary:
	if not is_active or _summary == null:
		return null
	return _summary.duplicate_summary()


func get_live_summary() -> RelationshipEncounterSummary:
	if not is_active or _summary == null:
		return null
	return _summary


func is_enemy_involved(enemy_instance_id: int) -> bool:
	if _summary == null or enemy_instance_id == -1:
		return false
	return _summary.involved_enemy_ids.has(enemy_instance_id)


func get_involved_enemy_ids() -> Array[int]:
	if _summary == null:
		return []
	return _summary.involved_enemy_ids.duplicate()


func get_involved_enemy_count() -> int:
	if _summary == null:
		return 0
	return _summary.involved_enemy_ids.size()


func start_encounter() -> void:
	if is_active:
		return

	_encounter_counter += 1
	_summary = RelationshipEncounterSummary.new()
	_summary.encounter_id = "encounter_%d" % _encounter_counter
	_summary.started_at = Time.get_ticks_msec() / 1000.0
	is_active = true
	encounter_started.emit(_summary.duplicate_summary())
	encounter_updated.emit(_summary.duplicate_summary())


func mark_enemy_involved(enemy_instance_id: int) -> void:
	if not is_active or _summary == null:
		return
	if enemy_instance_id == -1:
		return
	if _summary.involved_enemy_ids.has(enemy_instance_id):
		return
	_summary.involved_enemy_ids.append(enemy_instance_id)
	encounter_updated.emit(_summary.duplicate_summary())


func mark_disengaged() -> void:
	if not is_active or _summary == null:
		return

	_summary.was_disengaged = true
	_summary.disengage_count += 1
	_summary.excellent_disqualified = true
	encounter_updated.emit(_summary.duplicate_summary())


func mark_reengaged() -> void:
	if not is_active or _summary == null:
		return

	_summary.reengaged_after_disengage = true
	_summary.excellent_disqualified = true
	encounter_updated.emit(_summary.duplicate_summary())


func record_event(event: RelationshipEvent) -> void:
	if not is_active or _summary == null:
		return

	match event.event_id:
		RelationshipEvent.COMBAT_PLAYER_DAMAGED_ENEMY:
			_summary.player_attacks_landed += 1
		RelationshipEvent.COMBAT_ASSIST_SUCCEEDED:
			_summary.successful_assists += 1
		RelationshipEvent.COMBAT_ASSIST_HESITATED:
			_summary.assist_hesitations += 1
		RelationshipEvent.COMBAT_ASSIST_CANCELED:
			_summary.assist_cancellations += 1
		RelationshipEvent.COMBAT_PROTECTION_TRIGGERED:
			_summary.protection_triggers += 1
		RelationshipEvent.COMBAT_PROTECTION_SUCCEEDED:
			_summary.successful_protections += 1
		RelationshipEvent.COMBAT_ENEMY_DAMAGED_PLAYER:
			var enemy_amount: float = float(event.payload.get("amount", 0.0))
			_summary.player_damage_taken += maxf(enemy_amount, 0.0)
		RelationshipEvent.COMBAT_PLAYER_CRITICAL_HP:
			_summary.player_near_death_count += 1
		RelationshipEvent.COMBAT_PLAYER_DEATH:
			_summary.player_died = true
		RelationshipEvent.COMBAT_ENEMY_DEFEATED:
			_summary.enemies_defeated += 1
		RelationshipEvent.COMMAND_OBEYED:
			_summary.commands_obeyed += 1
		RelationshipEvent.COMMAND_DELAYED:
			_summary.commands_delayed += 1
		_:
			pass

	_summary.refresh_excellent_disqualification()
	encounter_updated.emit(_summary.duplicate_summary())


func end_encounter(
	completed: bool,
	failed: bool,
	outcome: RelationshipEncounterSummary.ResolvedOutcome
) -> RelationshipEncounterSummary:
	if not is_active or _summary == null:
		return null

	_summary.refresh_excellent_disqualification()
	_summary.ended_at = Time.get_ticks_msec() / 1000.0
	_summary.encounter_completed = completed
	_summary.encounter_failed = failed
	_summary.resolved_outcome = outcome

	var result := _summary.duplicate_summary()
	is_active = false
	_summary = null
	encounter_ended.emit(result)
	return result


func abort_encounter() -> void:
	if not is_active or _summary == null:
		return

	is_active = false
	_summary = null
	encounter_aborted.emit()

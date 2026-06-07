extends Node
## Relationship observation infrastructure (Milestone 8). No stat writes.
## Encounters track local combat engagements via involved enemy IDs only.


signal encounter_active_changed(is_active: bool)
signal encounter_aborted
signal encounter_summary_updated(summary: RelationshipEncounterSummary)
signal encounter_result_ready(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality,
	proposed: ProposedRelationshipDeltas
)
signal session_history_updated
signal event_log_updated

const DISENGAGE_TIMEOUT := 4.0
const DISENGAGE_GRACE_TIME := 6.0
const PLAYER_DISENGAGE_DISTANCE := 400.0
const PLAYER_FLEE_END_DELAY := 1.0
const MAX_RECENT_EVENT_LOG := 12
const _ENCOUNTER_START_EVENT_IDS := [
	RelationshipEvent.COMBAT_PLAYER_DAMAGED_ENEMY,
	RelationshipEvent.COMBAT_ENEMY_DAMAGED_PLAYER,
	RelationshipEvent.COMBAT_PROTECTION_TRIGGERED,
	RelationshipEvent.COMBAT_ASSIST_ATTEMPT_STARTED,
	RelationshipEvent.COMBAT_ASSIST_HESITATED,
]

var debug_logging_enabled: bool = true

var _bus: RelationshipEventBus
var _encounter_tracker: RelationshipEncounterTracker
var _session_tracker: RelationshipSessionTracker

var _player: CharacterBody2D
var _cooperation_behavior: DragonCooperationBehavior
var _strike_behavior: DragonStrikeBehavior

var _last_resolved_summary: RelationshipEncounterSummary
var _last_quality: EncounterQualityClassifier.Quality = EncounterQualityClassifier.Quality.NEUTRAL
var _last_proposed: ProposedRelationshipDeltas
var _last_produces_proposed: bool = false
var _pending_end_check: bool = false
var _disengage_timer: float = 0.0
var _grace_timer: float = 0.0
var _in_disengage_grace: bool = false
var _recent_event_log: Array[String] = []


func _ready() -> void:
	_bus = RelationshipEventBus.new()
	_bus.debug_logging_enabled = debug_logging_enabled
	_encounter_tracker = RelationshipEncounterTracker.new()
	_session_tracker = RelationshipSessionTracker.new()

	_bus.event_emitted.connect(_on_event_emitted)
	_encounter_tracker.encounter_started.connect(_on_encounter_started)
	_encounter_tracker.encounter_updated.connect(_on_encounter_updated)
	_encounter_tracker.encounter_ended.connect(_on_encounter_ended)
	_encounter_tracker.encounter_aborted.connect(_on_encounter_aborted)
	_session_tracker.session_updated.connect(func(): session_history_updated.emit())


func _process(delta: float) -> void:
	_tick_local_encounter_lifecycle(delta)


func record_event(event_id: String, payload: Dictionary = {}) -> void:
	var event_payload := payload.duplicate()
	event_payload["event_id"] = event_id
	var event := RelationshipEvent.create(event_id, event_payload)
	_bus.emit_event(event)


func get_active_encounter_summary() -> RelationshipEncounterSummary:
	return _encounter_tracker.get_active_summary()


func get_last_resolved_summary() -> RelationshipEncounterSummary:
	if _last_resolved_summary == null:
		return null
	return _last_resolved_summary.duplicate_summary()


func get_last_resolved_outcome_label() -> String:
	if _last_resolved_summary == null:
		return "-"
	return RelationshipEncounterSummary.outcome_label(_last_resolved_summary.resolved_outcome)


func has_last_proposed_deltas() -> bool:
	return _last_produces_proposed


func get_last_quality() -> EncounterQualityClassifier.Quality:
	return _last_quality


func get_last_quality_label() -> String:
	return EncounterQualityClassifier.quality_label(_last_quality)


func get_last_proposed_deltas() -> ProposedRelationshipDeltas:
	if _last_proposed == null:
		return null
	return _last_proposed.duplicate_deltas()


func get_session_encounter_count() -> int:
	return _session_tracker.encounter_count


func get_session_history_text() -> String:
	return _session_tracker.get_recent_history_text()


func get_recent_event_log_text() -> String:
	if _recent_event_log.is_empty():
		return "(none)"
	return "\n".join(_recent_event_log)


func is_encounter_active() -> bool:
	return _encounter_tracker.is_active


func setup_from_scene(root: Node) -> void:
	if root == null:
		return

	_player = _find_player(root)
	var dragon := _find_dragon(root)
	_wire_player(_player)
	_wire_dragon(dragon)
	_wire_enemies(root)


func _find_player(root: Node) -> CharacterBody2D:
	for node in root.get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			return node as CharacterBody2D
	return null


func _find_dragon(root: Node) -> CharacterBody2D:
	for node in root.get_tree().get_nodes_in_group("dragon"):
		if node is CharacterBody2D:
			return node as CharacterBody2D
	return null


func _wire_player(player: CharacterBody2D) -> void:
	if player == null:
		return

	var melee := player.get_node_or_null("MeleeAttack")
	if melee != null and melee.has_signal("attack_hit"):
		if not melee.attack_hit.is_connected(_on_player_attack_hit):
			melee.attack_hit.connect(_on_player_attack_hit)


func _wire_dragon(dragon: CharacterBody2D) -> void:
	if dragon == null:
		return

	_cooperation_behavior = dragon.get_node_or_null("CooperationBehavior") as DragonCooperationBehavior
	if _cooperation_behavior != null:
		if not _cooperation_behavior.hesitation_started.is_connected(_on_assist_hesitated):
			_cooperation_behavior.hesitation_started.connect(_on_assist_hesitated)
		if not _cooperation_behavior.cooperative_assist_canceled.is_connected(_on_assist_canceled):
			_cooperation_behavior.cooperative_assist_canceled.connect(_on_assist_canceled)

	var command := dragon.get_node_or_null("CommandBehavior") as DragonCommandBehavior
	if command != null:
		if not command.wait_position_set.is_connected(_on_command_obeyed.bind("WAIT")):
			command.wait_position_set.connect(_on_command_obeyed.bind("WAIT"))
		if not command.recalled.is_connected(_on_command_obeyed.bind("RECALL")):
			command.recalled.connect(_on_command_obeyed.bind("RECALL"))

	var threat := dragon.get_node_or_null("ThreatBehavior") as DragonThreatBehavior
	if threat != null:
		if not threat.alert_started.is_connected(_on_alert_entered):
			threat.alert_started.connect(_on_alert_entered)

	_strike_behavior = dragon.get_node_or_null("StrikeBehavior") as DragonStrikeBehavior
	if _strike_behavior != null:
		if not _strike_behavior.strike_hit.is_connected(_on_strike_hit):
			_strike_behavior.strike_hit.connect(_on_strike_hit)
		if not _strike_behavior.strike_started.is_connected(_on_strike_started):
			_strike_behavior.strike_started.connect(_on_strike_started)

	if dragon.has_signal("protection_triggered"):
		if not dragon.protection_triggered.is_connected(_on_protection_triggered):
			dragon.protection_triggered.connect(_on_protection_triggered)


func _wire_enemies(root: Node) -> void:
	var tree := root.get_tree()
	if tree == null:
		return
	if not tree.node_added.is_connected(_on_node_added):
		tree.node_added.connect(_on_node_added)
	for node in tree.get_nodes_in_group("enemy"):
		_connect_enemy_signals(node)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("enemy"):
		_connect_enemy_signals(node)


func _connect_enemy_signals(enemy: Node) -> void:
	if enemy.has_signal("player_detected") and not enemy.player_detected.is_connected(_on_enemy_aggro_started):
		enemy.player_detected.connect(_on_enemy_aggro_started.bind(enemy))
	if enemy.has_signal("attacked_player") and not enemy.attacked_player.is_connected(_on_enemy_attacked_player):
		enemy.attacked_player.connect(_on_enemy_attacked_player.bind(enemy))
	if enemy.has_signal("enemy_died") and not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)


func is_in_disengage_grace() -> bool:
	return _in_disengage_grace


func _on_event_emitted(event: RelationshipEvent) -> void:
	_append_recent_event_log(event)

	var enemy_id := _extract_enemy_id(event)
	var is_telemetry_only := event.event_id in _TELEMETRY_ONLY_EVENT_IDS

	if _event_starts_encounter(event.event_id):
		_ensure_encounter_started(enemy_id)
		if enemy_id != -1:
			_mark_enemy_involved(enemy_id)
	elif is_telemetry_only and _encounter_tracker.is_active:
		if enemy_id != -1:
			_mark_enemy_involved(enemy_id)
		_encounter_tracker.record_event(event)
		return

	if _encounter_tracker.is_active:
		if enemy_id != -1:
			_mark_enemy_involved(enemy_id)
			_try_resume_from_disengage_grace(enemy_id)
		_encounter_tracker.record_event(event)

	match event.event_id:
		RelationshipEvent.COMBAT_PLAYER_DEATH:
			_resolve_encounter(RelationshipEncounterSummary.ResolvedOutcome.PLAYER_DEATH)
		RelationshipEvent.COMBAT_ENEMY_DEFEATED:
			_schedule_encounter_end_check()


func _event_starts_encounter(event_id: String) -> bool:
	return event_id in _ENCOUNTER_START_EVENT_IDS


const _TELEMETRY_ONLY_EVENT_IDS := [
	RelationshipEvent.COMBAT_ENEMY_AGGRO_STARTED,
	RelationshipEvent.COMBAT_ALERT_ENTERED,
]


func _ensure_encounter_started(enemy_instance_id: int = -1) -> void:
	if _encounter_tracker.is_active:
		if _in_disengage_grace and enemy_instance_id != -1 \
				and _encounter_tracker.is_enemy_involved(enemy_instance_id):
			_resume_from_disengage_grace()
		return

	_encounter_tracker.start_encounter()
	_reset_encounter_lifecycle_timers()


func _mark_enemy_involved(enemy_instance_id: int) -> void:
	if enemy_instance_id == -1:
		return
	_encounter_tracker.mark_enemy_involved(enemy_instance_id)


func _extract_enemy_id(event: RelationshipEvent) -> int:
	if event.payload.has("enemy_instance_id"):
		return int(event.payload.get("enemy_instance_id"))
	return -1


func _enemy_payload(
	enemy: Node,
	source_behavior: String = "",
	strike_kind: String = ""
) -> Dictionary:
	var payload := {}
	if enemy == null or not is_instance_valid(enemy):
		return payload
	var enemy_id := EnemyValidation.resolve_instance_id(enemy)
	if enemy_id != -1:
		payload["enemy_instance_id"] = enemy_id
	payload["enemy"] = str(enemy.name)
	if not source_behavior.is_empty():
		payload["source_behavior"] = source_behavior
	if not strike_kind.is_empty():
		payload["strike_kind"] = strike_kind
	return payload


func _strike_kind_name(kind: DragonStrikeBehavior.StrikeKind) -> String:
	if kind == DragonStrikeBehavior.StrikeKind.ASSIST:
		return "ASSIST"
	if kind == DragonStrikeBehavior.StrikeKind.PROTECTION:
		return "PROTECTION"
	return "NONE"


func _append_recent_event_log(event: RelationshipEvent) -> void:
	var strike_kind: String = str(event.payload.get("strike_kind", "-"))
	var source_behavior: String = str(event.payload.get("source_behavior", "-"))
	var enemy_id: int = _extract_enemy_id(event)
	var line := "%s | %s | kind=%s | enemy=%s" % [
		event.event_id,
		source_behavior,
		strike_kind,
		enemy_id if enemy_id != -1 else "-",
	]
	_recent_event_log.append(line)
	if _recent_event_log.size() > MAX_RECENT_EVENT_LOG:
		_recent_event_log = _recent_event_log.slice(_recent_event_log.size() - MAX_RECENT_EVENT_LOG)
	event_log_updated.emit()


func _assist_target_payload() -> Dictionary:
	if _cooperation_behavior == null:
		return {}
	return _enemy_payload(
		_cooperation_behavior.get_pending_assist_target(),
		"cooperative_assist",
		"ASSIST"
	)


func _on_encounter_started(_summary: RelationshipEncounterSummary) -> void:
	encounter_active_changed.emit(true)


func _on_encounter_updated(summary: RelationshipEncounterSummary) -> void:
	encounter_summary_updated.emit(summary)


func _on_encounter_ended(summary: RelationshipEncounterSummary) -> void:
	encounter_active_changed.emit(false)
	_reset_encounter_lifecycle_timers()
	_last_resolved_summary = summary.duplicate_summary()
	_last_quality = EncounterQualityClassifier.classify(summary)
	_last_produces_proposed = ProposedDeltaGenerator.should_propose_deltas(summary, _last_quality)
	_last_proposed = ProposedDeltaGenerator.generate(summary, _last_quality)
	_session_tracker.record_encounter_quality(_last_quality)

	if debug_logging_enabled:
		print(
			"[RelationshipEncounter] RESOLVED | id=%s involved=%d | "
			% [summary.encounter_id, summary.get_involved_enemy_count()],
			EncounterQualityClassifier.quality_debug_summary(summary, _last_quality)
		)
		if _last_produces_proposed:
			print(
				"[RelationshipEncounter] PROPOSED ONLY — NOT APPLIED | Sync=%s Instability=%s Bond=%s"
				% [_last_proposed.format_sync(), _last_proposed.format_instability(), _last_proposed.format_bond()]
			)
		else:
			print("[RelationshipEncounter] No proposed deltas for this resolved outcome.")

	encounter_result_ready.emit(summary, _last_quality, _last_proposed)


func _on_encounter_aborted() -> void:
	encounter_active_changed.emit(false)
	encounter_aborted.emit()
	_reset_encounter_lifecycle_timers()
	if debug_logging_enabled:
		print("[RelationshipEncounter] ABORTED | minor interaction — no resolved outcome or proposed deltas.")


func _on_player_attack_hit(enemy: Node2D) -> void:
	record_event(
		RelationshipEvent.COMBAT_PLAYER_DAMAGED_ENEMY,
		_enemy_payload(enemy, "player_melee", "NONE")
	)


func _on_enemy_aggro_started(enemy: Node) -> void:
	if not _encounter_tracker.is_active:
		return
	record_event(
		RelationshipEvent.COMBAT_ENEMY_AGGRO_STARTED,
		_enemy_payload(enemy, "enemy_ai", "NONE")
	)


func _on_enemy_attacked_player(enemy: Node) -> void:
	var payload := _enemy_payload(enemy, "enemy_melee", "NONE")
	var damage_amount: Variant = enemy.get("attack_damage")
	if damage_amount != null:
		payload["amount"] = float(damage_amount)
	record_event(RelationshipEvent.COMBAT_ENEMY_DAMAGED_PLAYER, payload)


func _on_assist_hesitated() -> void:
	record_event(RelationshipEvent.COMBAT_ASSIST_HESITATED, _assist_target_payload())


func _on_assist_canceled(reason: String) -> void:
	var payload := _assist_target_payload()
	payload["reason"] = reason
	record_event(RelationshipEvent.COMBAT_ASSIST_CANCELED, payload)


func _on_command_obeyed(command_name: String) -> void:
	record_event(RelationshipEvent.COMMAND_OBEYED, {
		"command": command_name,
		"source_behavior": "dragon_command",
		"strike_kind": "NONE",
	})


func notify_command_delayed(command_name: String, delay: float) -> void:
	record_event(RelationshipEvent.COMMAND_DELAYED, {
		"command": command_name,
		"delay": delay,
		"source_behavior": "dragon_command",
		"strike_kind": "NONE",
	})


func _on_alert_entered(threat: Node2D) -> void:
	if not _encounter_tracker.is_active:
		return
	record_event(
		RelationshipEvent.COMBAT_ALERT_ENTERED,
		_enemy_payload(threat, "dragon_threat", "NONE")
	)


func _on_strike_started(enemy: Node2D, kind: DragonStrikeBehavior.StrikeKind) -> void:
	if kind != DragonStrikeBehavior.StrikeKind.ASSIST:
		return
	record_event(
		RelationshipEvent.COMBAT_ASSIST_ATTEMPT_STARTED,
		_enemy_payload(enemy, "cooperative_assist", _strike_kind_name(kind))
	)


func _on_strike_hit(enemy: Node2D, kind: DragonStrikeBehavior.StrikeKind) -> void:
	# Assist and protection are mutually exclusive per strike; never emit both for one hit.
	if kind == DragonStrikeBehavior.StrikeKind.ASSIST:
		record_event(
			RelationshipEvent.COMBAT_ASSIST_SUCCEEDED,
			_enemy_payload(enemy, "cooperative_assist", "ASSIST")
		)
		return
	if kind == DragonStrikeBehavior.StrikeKind.PROTECTION:
		record_event(
			RelationshipEvent.COMBAT_PROTECTION_SUCCEEDED,
			_enemy_payload(enemy, "defensive_protection", "PROTECTION")
		)


func _on_protection_triggered(target: Node2D) -> void:
	record_event(
		RelationshipEvent.COMBAT_PROTECTION_TRIGGERED,
		_enemy_payload(target, "defensive_protection", "PROTECTION")
	)


func _on_enemy_died(enemy: Node) -> void:
	record_event(
		RelationshipEvent.COMBAT_ENEMY_DEFEATED,
		_enemy_payload(enemy, "combat_resolution", "NONE")
	)


func _schedule_encounter_end_check() -> void:
	if _pending_end_check:
		return
	_pending_end_check = true
	call_deferred("_check_involved_encounter_end")


func _check_involved_encounter_end() -> void:
	_pending_end_check = false
	if not _encounter_tracker.is_active:
		return
	if _are_all_involved_enemies_dead():
		_resolve_encounter(RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED)


func _tick_local_encounter_lifecycle(delta: float) -> void:
	if not _encounter_tracker.is_active:
		_reset_encounter_lifecycle_timers()
		return

	if _encounter_tracker.get_involved_enemy_count() == 0:
		return

	if _are_all_involved_enemies_dead():
		_resolve_encounter(RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED)
		return

	if _is_any_involved_enemy_engaged():
		if _in_disengage_grace:
			_resume_from_disengage_grace()
		else:
			_disengage_timer = 0.0
		return

	if _in_disengage_grace:
		_grace_timer += delta
		if _grace_timer >= DISENGAGE_GRACE_TIME:
			_try_resolve_disengage()
		return

	_disengage_timer += delta

	var should_enter_grace := false
	if _is_player_far_from_involved_alive() and _disengage_timer >= PLAYER_FLEE_END_DELAY:
		should_enter_grace = true
	elif _disengage_timer >= DISENGAGE_TIMEOUT:
		should_enter_grace = true

	if should_enter_grace:
		_enter_disengage_grace()


func _enter_disengage_grace() -> void:
	if not _encounter_tracker.is_active or _in_disengage_grace:
		return

	_in_disengage_grace = true
	_grace_timer = 0.0
	_disengage_timer = 0.0
	_encounter_tracker.mark_disengaged()

	if debug_logging_enabled:
		var encounter_id := "?"
		var live_summary := _encounter_tracker.get_live_summary()
		if live_summary != null:
			encounter_id = live_summary.encounter_id
		print(
			"[RelationshipEncounter] DISENGAGE GRACE | id=%s | %.0fs to re-engage or resolve"
			% [encounter_id, DISENGAGE_GRACE_TIME]
		)


func _try_resume_from_disengage_grace(enemy_instance_id: int) -> void:
	if not _in_disengage_grace:
		return
	if not _encounter_tracker.is_enemy_involved(enemy_instance_id):
		return
	_resume_from_disengage_grace()


func _resume_from_disengage_grace() -> void:
	if not _encounter_tracker.is_active or not _in_disengage_grace:
		return

	_in_disengage_grace = false
	_grace_timer = 0.0
	_disengage_timer = 0.0
	_encounter_tracker.mark_reengaged()

	if debug_logging_enabled:
		print("[RelationshipEncounter] RE-ENGAGED | same encounter resumed; Excellent disqualified.")


func _reset_encounter_lifecycle_timers() -> void:
	_disengage_timer = 0.0
	_grace_timer = 0.0
	_in_disengage_grace = false


func _try_resolve_disengage() -> void:
	if not _encounter_tracker.is_active:
		return

	var live_summary := _encounter_tracker.get_live_summary()
	if live_summary != null and live_summary.has_meaningful_combat_progress():
		_resolve_encounter(RelationshipEncounterSummary.ResolvedOutcome.FLED_DISENGAGED)
	else:
		_abort_active_encounter()


func _resolve_encounter(outcome: RelationshipEncounterSummary.ResolvedOutcome) -> void:
	if not _encounter_tracker.is_active:
		return

	var completed := outcome in [
		RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED,
		RelationshipEncounterSummary.ResolvedOutcome.FLED_DISENGAGED,
	]
	var failed := outcome == RelationshipEncounterSummary.ResolvedOutcome.PLAYER_DEATH

	if completed:
		record_event(RelationshipEvent.COMBAT_ENCOUNTER_COMPLETED)
	elif failed:
		record_event(RelationshipEvent.COMBAT_ENCOUNTER_FAILED)

	_encounter_tracker.end_encounter(completed, failed, outcome)


func _abort_active_encounter() -> void:
	if not _encounter_tracker.is_active:
		return
	_encounter_tracker.abort_encounter()


func _resolve_enemy_from_id(enemy_instance_id: int) -> Node2D:
	if enemy_instance_id == -1:
		return null
	if not is_instance_id_valid(enemy_instance_id):
		return null
	var obj := instance_from_id(enemy_instance_id)
	if obj is Node2D and is_instance_valid(obj):
		return obj as Node2D
	return null


func _is_enemy_alive(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
		return false
	if enemy.has_method("is_dead") and enemy.is_dead:
		return false
	var health := enemy.get_node_or_null("Health") as Health
	if health != null and not health.is_alive():
		return false
	return true


func _is_enemy_engaged(enemy: Node2D) -> bool:
	if not _is_enemy_alive(enemy):
		return false
	if enemy.has_method("is_engaging_player") and enemy.is_engaging_player():
		return true
	if enemy.has_method("is_chasing_player") and enemy.is_chasing_player():
		return true
	return false


func _are_all_involved_enemies_dead() -> bool:
	var involved_ids := _encounter_tracker.get_involved_enemy_ids()
	if involved_ids.is_empty():
		return false

	for enemy_id: int in involved_ids:
		var enemy := _resolve_enemy_from_id(enemy_id)
		if _is_enemy_alive(enemy):
			return false
	return true


func _is_any_involved_enemy_engaged() -> bool:
	for enemy_id: int in _encounter_tracker.get_involved_enemy_ids():
		var enemy := _resolve_enemy_from_id(enemy_id)
		if _is_enemy_engaged(enemy):
			return true
	return false


func _is_player_far_from_involved_alive() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false

	var involved_ids := _encounter_tracker.get_involved_enemy_ids()
	if involved_ids.is_empty():
		return false

	var player_pos := _player.global_position
	for enemy_id: int in involved_ids:
		var enemy := _resolve_enemy_from_id(enemy_id)
		if not _is_enemy_alive(enemy):
			continue
		if player_pos.distance_to(enemy.global_position) <= PLAYER_DISENGAGE_DISTANCE:
			return false
	return true

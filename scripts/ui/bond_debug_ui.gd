extends Control
## Docked debug readout for BondProfile, dragon state, and relationship observation.


const FONT_TITLE := 24
const FONT_BODY := 18
const FONT_VALUE := 20
const FONT_NOTICE := 18
const _CONTENT_ROOT := "FillPanel/Margin/Scroll/ContentPanel/ContentMargin/VBox"

var _protection_radius_value: Label
var _alert_range_value: Label
var _threat_distance_value: Label
var _protection_delay_value: Label
var _protection_persistence_value: Label
var _pending_command_value: Label
var _command_delay_value: Label
var _dragon_state_value: Label
var _bond_tier_value: Label
var _bond_tier_progress_value: Label
var _future_sync_floor_value: Label
var _future_instability_resistance_value: Label
var _future_instability_recovery_value: Label
var _dragon_thought_value: Label
var _assists_value: Label
var _protections_value: Label
var _cancellations_value: Label
var _damage_value: Label
var _deaths_value: Label
var _encounter_active_value: Label
var _encounter_id_value: Label
var _involved_count_value: Label
var _was_disengaged_value: Label
var _disengage_count_value: Label
var _excellent_eligible_value: Label
var _cooperation_rating_value: Label
var _current_bond_value: Label
var _current_sync_value: Label
var _current_instability_value: Label
var _last_encounter_id_value: Label
var _last_resolved_outcome_value: Label
var _last_quality_value: Label
var _last_cooperation_value: Label
var _last_involved_value: Label
var _last_summary_value: Label
var _last_was_disengaged_value: Label
var _last_disengage_count_value: Label
var _last_excellent_eligible_value: Label
var _last_applied_sync_value: Label
var _last_applied_instability_value: Label
var _applied_sync_value: Label
var _applied_instability_value: Label
var _applied_bond_value: Label
var _proposed_bond_value: Label
var _session_count_value: Label
var _session_history_value: Label
var _recent_events_value: Label
var _dragon: CharacterBody2D
var _protection_behavior: DragonProtectionBehavior
var _threat_behavior: DragonThreatBehavior
var _command_behavior: DragonCommandBehavior
var _communication_behavior: DragonCommunicationBehavior
var _ui_ready := false


func _ready() -> void:
	_ui_ready = _cache_ui_nodes()
	if not _ui_ready:
		push_error("BondDebugUI: failed to bind label nodes — check scene tree under FillPanel/Margin/Scroll/ContentPanel.")
		return
	_initialize_ui()


func _cache_ui_nodes() -> bool:
	_protection_radius_value = get_node_or_null("%s/Grid/ProtectionRadiusValue" % _CONTENT_ROOT) as Label
	_alert_range_value = get_node_or_null("%s/Grid/AlertRangeValue" % _CONTENT_ROOT) as Label
	_threat_distance_value = get_node_or_null("%s/Grid/ThreatDistanceValue" % _CONTENT_ROOT) as Label
	_protection_delay_value = get_node_or_null("%s/Grid/ProtectionDelayValue" % _CONTENT_ROOT) as Label
	_protection_persistence_value = get_node_or_null("%s/Grid/ProtectionPersistenceValue" % _CONTENT_ROOT) as Label
	_pending_command_value = get_node_or_null("%s/Grid/PendingCommandValue" % _CONTENT_ROOT) as Label
	_command_delay_value = get_node_or_null("%s/Grid/CommandDelayValue" % _CONTENT_ROOT) as Label
	_dragon_state_value = get_node_or_null("%s/Grid/DragonStateValue" % _CONTENT_ROOT) as Label
	_bond_tier_value = get_node_or_null("%s/Grid/BondTierValue" % _CONTENT_ROOT) as Label
	_bond_tier_progress_value = get_node_or_null("%s/Grid/BondTierProgressValue" % _CONTENT_ROOT) as Label
	_future_sync_floor_value = get_node_or_null("%s/Grid/FutureSyncFloorValue" % _CONTENT_ROOT) as Label
	_future_instability_resistance_value = get_node_or_null("%s/Grid/FutureInstabilityResistanceValue" % _CONTENT_ROOT) as Label
	_future_instability_recovery_value = get_node_or_null("%s/Grid/FutureInstabilityRecoveryValue" % _CONTENT_ROOT) as Label
	_dragon_thought_value = get_node_or_null("%s/Communication/DragonThoughtValue" % _CONTENT_ROOT) as Label
	_assists_value = get_node_or_null("%s/Relationship/EncounterGrid/AssistsValue" % _CONTENT_ROOT) as Label
	_protections_value = get_node_or_null("%s/Relationship/EncounterGrid/ProtectionsValue" % _CONTENT_ROOT) as Label
	_cancellations_value = get_node_or_null("%s/Relationship/EncounterGrid/CancellationsValue" % _CONTENT_ROOT) as Label
	_damage_value = get_node_or_null("%s/Relationship/EncounterGrid/DamageValue" % _CONTENT_ROOT) as Label
	_deaths_value = get_node_or_null("%s/Relationship/EncounterGrid/DeathsValue" % _CONTENT_ROOT) as Label
	_encounter_active_value = get_node_or_null("%s/Relationship/EncounterGrid/EncounterActiveValue" % _CONTENT_ROOT) as Label
	_encounter_id_value = get_node_or_null("%s/Relationship/EncounterGrid/EncounterIdValue" % _CONTENT_ROOT) as Label
	_involved_count_value = get_node_or_null("%s/Relationship/EncounterGrid/InvolvedCountValue" % _CONTENT_ROOT) as Label
	_was_disengaged_value = get_node_or_null("%s/Relationship/EncounterGrid/WasDisengagedValue" % _CONTENT_ROOT) as Label
	_disengage_count_value = get_node_or_null("%s/Relationship/EncounterGrid/DisengageCountValue" % _CONTENT_ROOT) as Label
	_excellent_eligible_value = get_node_or_null("%s/Relationship/EncounterGrid/ExcellentEligibleValue" % _CONTENT_ROOT) as Label
	_cooperation_rating_value = get_node_or_null("%s/Relationship/EncounterGrid/CooperationRatingValue" % _CONTENT_ROOT) as Label
	_current_bond_value = get_node_or_null("%s/Relationship/CurrentStatsGrid/CurrentBondValue" % _CONTENT_ROOT) as Label
	_current_sync_value = get_node_or_null("%s/Relationship/CurrentStatsGrid/CurrentSyncValue" % _CONTENT_ROOT) as Label
	_current_instability_value = get_node_or_null("%s/Relationship/CurrentStatsGrid/CurrentInstabilityValue" % _CONTENT_ROOT) as Label
	_last_encounter_id_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastEncounterIdValue" % _CONTENT_ROOT) as Label
	_last_resolved_outcome_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastResolvedOutcomeValue" % _CONTENT_ROOT) as Label
	_last_quality_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastQualityValue" % _CONTENT_ROOT) as Label
	_last_cooperation_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastCooperationValue" % _CONTENT_ROOT) as Label
	_last_involved_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastInvolvedValue" % _CONTENT_ROOT) as Label
	_last_summary_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastSummaryValue" % _CONTENT_ROOT) as Label
	_last_was_disengaged_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastWasDisengagedValue" % _CONTENT_ROOT) as Label
	_last_disengage_count_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastDisengageCountValue" % _CONTENT_ROOT) as Label
	_last_excellent_eligible_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastExcellentEligibleValue" % _CONTENT_ROOT) as Label
	_last_applied_sync_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastAppliedSyncValue" % _CONTENT_ROOT) as Label
	_last_applied_instability_value = get_node_or_null("%s/Relationship/LastEncounterGrid/LastAppliedInstabilityValue" % _CONTENT_ROOT) as Label
	_applied_sync_value = get_node_or_null("%s/Relationship/AppliedGrid/AppliedSyncValue" % _CONTENT_ROOT) as Label
	_applied_instability_value = get_node_or_null("%s/Relationship/AppliedGrid/AppliedInstabilityValue" % _CONTENT_ROOT) as Label
	_applied_bond_value = get_node_or_null("%s/Relationship/AppliedGrid/AppliedBondValue" % _CONTENT_ROOT) as Label
	_proposed_bond_value = get_node_or_null("%s/Relationship/ProposedBondGrid/ProposedBondValue" % _CONTENT_ROOT) as Label
	_session_count_value = get_node_or_null("%s/Relationship/SessionCountValue" % _CONTENT_ROOT) as Label
	_session_history_value = get_node_or_null("%s/Relationship/SessionHistoryValue" % _CONTENT_ROOT) as Label
	_recent_events_value = get_node_or_null("%s/Relationship/RecentEventsValue" % _CONTENT_ROOT) as Label

	var required: Array[Label] = [
		_bond_tier_value,
		_threat_distance_value,
		_dragon_state_value,
		_assists_value,
		_current_bond_value,
		_dragon_thought_value,
	]
	for label in required:
		if label == null:
			return false
	return true


func _set_label_text(label: Label, text: String) -> void:
	if label != null:
		label.text = text


func _initialize_ui() -> void:
	if not is_inside_tree():
		return
	_setup_panel()
	_connect_parent_resize()
	var content_root := _get_content_root()
	if content_root != null:
		_apply_large_text(content_root)

	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_refresh_current_stats(bond)
	_refresh_dragon_state(DragonState.State.FOLLOWING)
	_connect_relationship_signals()
	_refresh_relationship_ui()


func _get_content_root() -> VBoxContainer:
	return get_node_or_null("FillPanel/Margin/Scroll/ContentPanel/ContentMargin/VBox") as VBoxContainer


func _setup_panel() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var fill_panel := get_node_or_null("FillPanel") as PanelContainer
	if fill_panel == null:
		return
	fill_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	fill_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	visible = true


func _connect_parent_resize() -> void:
	var debug_panel := get_parent()
	if debug_panel is Control and not debug_panel.resized.is_connected(_on_parent_resized):
		debug_panel.resized.connect(_on_parent_resized)
	var sidebar := debug_panel.get_parent() if debug_panel != null else null
	if sidebar is Control and not sidebar.resized.is_connected(_on_parent_resized):
		sidebar.resized.connect(_on_parent_resized)


func _on_parent_resized() -> void:
	call_deferred("_setup_panel")


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		call_deferred("_setup_panel")


func bind_to_dragon(dragon: CharacterBody2D) -> void:
	if not _ui_ready:
		return
	_dragon = dragon
	if _dragon == null:
		push_warning("BondDebugUI: dragon reference is null.")
		return

	_protection_behavior = _dragon.get_node_or_null("ProtectionBehavior") as DragonProtectionBehavior
	_threat_behavior = _dragon.get_node_or_null("ThreatBehavior") as DragonThreatBehavior
	_command_behavior = _dragon.get_node_or_null("CommandBehavior") as DragonCommandBehavior
	_communication_behavior = _dragon.get_node_or_null("CommunicationBehavior") as DragonCommunicationBehavior

	if _communication_behavior != null:
		if not _communication_behavior.message_changed.is_connected(_on_dragon_message_changed):
			_communication_behavior.message_changed.connect(_on_dragon_message_changed)
		_refresh_dragon_thought(_communication_behavior.get_message())

	if not _dragon.state_changed.is_connected(_on_dragon_state_changed):
		_dragon.state_changed.connect(_on_dragon_state_changed)

	_refresh_dragon_state(_dragon.state)
	_refresh_protection_stats(BondSystem.get_profile().bond_strength)
	_refresh_command_pending()


func _process(_delta: float) -> void:
	if not _ui_ready:
		return
	_refresh_command_pending()
	_refresh_threat_distance()


func _apply_large_text(node: Node) -> void:
	if node == null:
		return
	if node is Label:
		var label := node as Label
		var node_name := node.name.to_lower()
		label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95, 1.0))
		if node_name == "titlelabel" or node_name.ends_with("title"):
			label.add_theme_font_size_override("font_size", FONT_TITLE)
		elif node_name.ends_with("value"):
			label.add_theme_font_size_override("font_size", FONT_VALUE)
		elif node_name == "proposednotice" or node_name == "appliednotice":
			label.add_theme_font_size_override("font_size", FONT_NOTICE)
		else:
			label.add_theme_font_size_override("font_size", FONT_BODY)

	for child in node.get_children():
		if child != null:
			_apply_large_text(child)


func _on_bond_profile_changed(_unused = null) -> void:
	var bond := BondSystem.get_profile()
	_refresh_bond(bond)
	_refresh_current_stats(bond)


func _on_dragon_state_changed(state: DragonState.State) -> void:
	_refresh_dragon_state(state)


func _on_dragon_message_changed(message: String) -> void:
	_refresh_dragon_thought(message)


func _refresh_bond(bond: BondProfile) -> void:
	_refresh_resilience_stats(bond.bond_strength)
	_refresh_protection_stats(bond.bond_strength)


func _refresh_resilience_stats(bond_strength: float) -> void:
	_set_label_text(_bond_tier_value, BondResilience.get_bond_tier_label(bond_strength))
	_set_label_text(_bond_tier_progress_value, str(snapped(BondResilience.get_bond_tier_progress(bond_strength), 0.01)))
	_set_label_text(_future_sync_floor_value, str(snapped(BondResilience.get_sync_floor(bond_strength), 0.1)))
	var resistance_percent: int = int(round(BondResilience.get_instability_resistance(bond_strength) * 100.0))
	_set_label_text(_future_instability_resistance_value, "%d%%" % resistance_percent)
	_set_label_text(_future_instability_recovery_value, "%.2fx" % BondResilience.get_instability_recovery_rate(bond_strength))


func _refresh_protection_stats(bond_strength: float) -> void:
	_set_label_text(_alert_range_value, str(int(BondResilience.get_alert_range(bond_strength))))

	if _protection_behavior == null:
		_set_label_text(_protection_radius_value, "-")
		_set_label_text(_protection_delay_value, "-")
		_set_label_text(_protection_persistence_value, "-")
		return

	_set_label_text(_protection_radius_value, str(int(_protection_behavior.get_protection_radius(bond_strength))))
	_set_label_text(_protection_delay_value, str(_protection_behavior.get_response_delay(bond_strength)))
	_set_label_text(_protection_persistence_value, str(_protection_behavior.get_persistence_duration(bond_strength)))


func _refresh_threat_distance() -> void:
	if _threat_behavior == null:
		_set_label_text(_threat_distance_value, "-")
		return

	var distance: float = _threat_behavior.get_nearest_enemy_distance()
	if distance < 0.0:
		_set_label_text(_threat_distance_value, "-")
	else:
		_set_label_text(_threat_distance_value, str(int(distance)))


func _refresh_command_pending() -> void:
	if _command_behavior == null:
		_set_label_text(_pending_command_value, "-")
		_set_label_text(_command_delay_value, "-")
		return

	_set_label_text(_pending_command_value, _command_behavior.get_pending_command_label())
	var delay_remaining: float = _command_behavior.get_command_delay_remaining()
	if delay_remaining <= 0.0:
		_set_label_text(_command_delay_value, "0")
	else:
		_set_label_text(_command_delay_value, str(snapped(delay_remaining, 0.01)))


func _refresh_dragon_state(state: DragonState.State) -> void:
	_set_label_text(_dragon_state_value, DragonState.state_display_name(state))


func _refresh_dragon_thought(message: String) -> void:
	if message.is_empty():
		var fallback := DragonCommunicationCatalog.get_dragon_message(
			DragonCommunicationCatalog.Cue.FOLLOWING,
			BondSystem.get_profile().bond_strength
		)
		_set_label_text(_dragon_thought_value, "\"%s\"" % fallback)
	else:
		_set_label_text(_dragon_thought_value, "\"%s\"" % message)


func _refresh_current_stats(bond: BondProfile) -> void:
	_set_label_text(_current_bond_value, str(int(bond.bond_strength)))
	_set_label_text(_current_sync_value, str(int(bond.sync)))
	_set_label_text(_current_instability_value, str(int(bond.instability)))


func _connect_relationship_signals() -> void:
	if not RelationshipSystem.encounter_summary_updated.is_connected(_on_relationship_updated):
		RelationshipSystem.encounter_summary_updated.connect(_on_relationship_updated)
	if not RelationshipSystem.encounter_result_ready.is_connected(_on_relationship_result_ready):
		RelationshipSystem.encounter_result_ready.connect(_on_relationship_result_ready)
	if not RelationshipSystem.session_history_updated.is_connected(_on_relationship_session_updated):
		RelationshipSystem.session_history_updated.connect(_on_relationship_session_updated)
	if not RelationshipSystem.encounter_active_changed.is_connected(_on_relationship_active_changed):
		RelationshipSystem.encounter_active_changed.connect(_on_relationship_active_changed)
	if not RelationshipSystem.encounter_aborted.is_connected(_on_relationship_aborted):
		RelationshipSystem.encounter_aborted.connect(_on_relationship_aborted)
	if not RelationshipSystem.event_log_updated.is_connected(_on_relationship_event_log_updated):
		RelationshipSystem.event_log_updated.connect(_on_relationship_event_log_updated)
	if not RelationshipSystem.relationship_stats_applied.is_connected(_on_relationship_stats_applied):
		RelationshipSystem.relationship_stats_applied.connect(_on_relationship_stats_applied)


func _on_relationship_stats_applied(
	_encounter_id: String,
	_sync_delta: float,
	_instability_delta: float
) -> void:
	_refresh_current_stats(BondSystem.get_profile())
	_refresh_relationship_ui()


func _on_relationship_updated(_summary: RelationshipEncounterSummary) -> void:
	_refresh_relationship_ui()


func _on_relationship_result_ready(
	_summary: RelationshipEncounterSummary,
	_quality: EncounterQualityClassifier.Quality,
	_proposed: ProposedRelationshipDeltas
) -> void:
	_refresh_relationship_ui()
	_refresh_session_history()


func _on_relationship_session_updated() -> void:
	_refresh_session_history()


func _on_relationship_active_changed(_is_active: bool) -> void:
	_refresh_relationship_ui()


func _on_relationship_aborted() -> void:
	_refresh_relationship_ui()


func _on_relationship_event_log_updated() -> void:
	_refresh_recent_events()


func _refresh_recent_events() -> void:
	_set_label_text(_recent_events_value, RelationshipSystem.get_recent_event_log_text())


func _refresh_relationship_ui() -> void:
	var active := RelationshipSystem.get_active_encounter_summary()
	if active == null:
		_set_label_text(_assists_value, "0")
		_set_label_text(_protections_value, "0")
		_set_label_text(_cancellations_value, "0")
		_set_label_text(_damage_value, "0")
		_set_label_text(_deaths_value, "NO")
		_set_label_text(_encounter_active_value, "NO")
		_set_label_text(_encounter_id_value, "-")
		_set_label_text(_involved_count_value, "0")
		_set_label_text(_was_disengaged_value, "NO")
		_set_label_text(_disengage_count_value, "0")
		_set_label_text(_excellent_eligible_value, "NO")
		_set_label_text(_cooperation_rating_value, "-")
	else:
		_set_label_text(_assists_value, str(active.successful_assists))
		_set_label_text(_protections_value, str(active.successful_protections))
		_set_label_text(_cancellations_value, str(active.assist_cancellations))
		_set_label_text(_damage_value, str(int(active.player_damage_taken)))
		_set_label_text(_deaths_value, "YES" if active.player_died else "NO")
		if RelationshipSystem.is_in_disengage_grace():
			_set_label_text(_encounter_active_value, "YES (grace)")
		else:
			_set_label_text(_encounter_active_value, "YES")
		_set_label_text(_encounter_id_value, active.encounter_id)
		_set_label_text(_involved_count_value, str(active.get_involved_enemy_count()))
		_set_label_text(_was_disengaged_value, RelationshipEncounterSummary.yes_no(active.was_disengaged))
		_set_label_text(_disengage_count_value, str(active.disengage_count))
		_set_label_text(
			_excellent_eligible_value,
			RelationshipEncounterSummary.yes_no(active.is_excellent_quality_eligible())
		)
		_set_label_text(
			_cooperation_rating_value,
			CooperationRatingClassifier.rating_label(CooperationRatingClassifier.classify(active))
		)

	_refresh_last_encounter()
	_refresh_applied_deltas()
	_refresh_proposed_bond()
	_refresh_recent_events()


func _refresh_last_encounter() -> void:
	var last := RelationshipSystem.get_last_resolved_summary()
	if last == null:
		_set_label_text(_last_encounter_id_value, "-")
		_set_label_text(_last_resolved_outcome_value, "-")
		_set_label_text(_last_quality_value, "-")
		_set_label_text(_last_cooperation_value, "-")
		_set_label_text(_last_involved_value, "-")
		_set_label_text(_last_summary_value, "-")
		_set_label_text(_last_was_disengaged_value, "-")
		_set_label_text(_last_disengage_count_value, "-")
		_set_label_text(_last_excellent_eligible_value, "-")
		_set_label_text(_last_applied_sync_value, "-")
		_set_label_text(_last_applied_instability_value, "-")
		return

	_set_label_text(_last_encounter_id_value, last.encounter_id)
	_set_label_text(_last_resolved_outcome_value, RelationshipSystem.get_last_resolved_outcome_label())
	_set_label_text(_last_quality_value, RelationshipSystem.get_last_quality_label())
	_set_label_text(_last_cooperation_value, RelationshipSystem.get_last_cooperation_label())
	_set_label_text(_last_involved_value, str(last.get_involved_enemy_count()))
	_set_label_text(_last_summary_value, last.format_counter_summary())
	_set_label_text(_last_was_disengaged_value, RelationshipEncounterSummary.yes_no(last.was_disengaged))
	_set_label_text(_last_disengage_count_value, str(last.disengage_count))
	_set_label_text(
		_last_excellent_eligible_value,
		RelationshipEncounterSummary.yes_no(last.is_excellent_quality_eligible())
	)
	if RelationshipSystem.has_last_applied_stats():
		_set_label_text(
			_last_applied_sync_value,
			_format_applied_delta(RelationshipSystem.get_last_applied_sync_delta())
		)
		_set_label_text(
			_last_applied_instability_value,
			_format_applied_delta(RelationshipSystem.get_last_applied_instability_delta())
		)
	else:
		_set_label_text(_last_applied_sync_value, "-")
		_set_label_text(_last_applied_instability_value, "-")


func _refresh_applied_deltas() -> void:
	if not RelationshipSystem.has_last_applied_stats():
		_set_label_text(_applied_sync_value, "-")
		_set_label_text(_applied_instability_value, "-")
		_set_label_text(_applied_bond_value, "NOT APPLIED")
		return

	_set_label_text(_applied_sync_value, _format_applied_delta(RelationshipSystem.get_last_applied_sync_delta()))
	_set_label_text(
		_applied_instability_value,
		_format_applied_delta(RelationshipSystem.get_last_applied_instability_delta())
	)
	_set_label_text(_applied_bond_value, "NOT APPLIED")


func _refresh_proposed_bond() -> void:
	if not RelationshipSystem.has_last_proposed_deltas():
		_set_label_text(_proposed_bond_value, "-")
		return

	var proposed := RelationshipSystem.get_last_proposed_deltas()
	if proposed == null or is_zero_approx(proposed.bond_delta):
		_set_label_text(_proposed_bond_value, "0")
		return

	_set_label_text(_proposed_bond_value, proposed.format_bond())


func _format_applied_delta(value: float) -> String:
	if is_zero_approx(value):
		return "0"
	if value > 0.0:
		return "+%s" % str(snapped(value, 0.1))
	return str(snapped(value, 0.1))


func _refresh_session_history() -> void:
	_set_label_text(_session_count_value, "Encounters: %d" % RelationshipSystem.get_session_encounter_count())
	_set_label_text(_session_history_value, RelationshipSystem.get_session_history_text())

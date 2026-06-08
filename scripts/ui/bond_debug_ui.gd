extends Control
## Docked debug readout for BondProfile, dragon state, and relationship observation.


const FONT_TITLE := 24
const FONT_BODY := 18
const FONT_VALUE := 20
const FONT_NOTICE := 18

@onready var _content_root: VBoxContainer = $Margin/Scroll/Panel/ContentMargin/VBox
@onready var _protection_radius_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/ProtectionRadiusValue
@onready var _alert_range_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/AlertRangeValue
@onready var _threat_distance_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/ThreatDistanceValue
@onready var _protection_delay_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/ProtectionDelayValue
@onready var _protection_persistence_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/ProtectionPersistenceValue
@onready var _pending_command_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/PendingCommandValue
@onready var _command_delay_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/CommandDelayValue
@onready var _dragon_state_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/DragonStateValue
@onready var _bond_tier_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/BondTierValue
@onready var _bond_tier_progress_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/BondTierProgressValue
@onready var _future_sync_floor_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/FutureSyncFloorValue
@onready var _future_instability_resistance_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/FutureInstabilityResistanceValue
@onready var _future_instability_recovery_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Grid/FutureInstabilityRecoveryValue
@onready var _dragon_thought_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Communication/DragonThoughtValue

@onready var _assists_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/AssistsValue
@onready var _protections_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/ProtectionsValue
@onready var _cancellations_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/CancellationsValue
@onready var _damage_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/DamageValue
@onready var _deaths_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/DeathsValue
@onready var _encounter_active_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/EncounterActiveValue
@onready var _encounter_id_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/EncounterIdValue
@onready var _involved_count_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/InvolvedCountValue
@onready var _was_disengaged_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/WasDisengagedValue
@onready var _disengage_count_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/DisengageCountValue
@onready var _excellent_eligible_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/ExcellentEligibleValue
@onready var _cooperation_rating_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/EncounterGrid/CooperationRatingValue
@onready var _current_bond_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/CurrentStatsGrid/CurrentBondValue
@onready var _current_sync_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/CurrentStatsGrid/CurrentSyncValue
@onready var _current_instability_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/CurrentStatsGrid/CurrentInstabilityValue
@onready var _last_encounter_id_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastEncounterIdValue
@onready var _last_resolved_outcome_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastResolvedOutcomeValue
@onready var _last_quality_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastQualityValue
@onready var _last_cooperation_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastCooperationValue
@onready var _last_involved_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastInvolvedValue
@onready var _last_summary_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastSummaryValue
@onready var _last_was_disengaged_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastWasDisengagedValue
@onready var _last_disengage_count_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastDisengageCountValue
@onready var _last_excellent_eligible_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastExcellentEligibleValue
@onready var _last_applied_sync_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastAppliedSyncValue
@onready var _last_applied_instability_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/LastEncounterGrid/LastAppliedInstabilityValue
@onready var _applied_sync_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/AppliedGrid/AppliedSyncValue
@onready var _applied_instability_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/AppliedGrid/AppliedInstabilityValue
@onready var _applied_bond_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/AppliedGrid/AppliedBondValue
@onready var _proposed_bond_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/ProposedBondGrid/ProposedBondValue
@onready var _session_count_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/SessionCountValue
@onready var _session_history_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/SessionHistoryValue
@onready var _recent_events_value: Label = $Margin/Scroll/Panel/ContentMargin/VBox/Relationship/RecentEventsValue

var _dragon: CharacterBody2D
var _protection_behavior: DragonProtectionBehavior
var _threat_behavior: DragonThreatBehavior
var _command_behavior: DragonCommandBehavior
var _communication_behavior: DragonCommunicationBehavior


func _ready() -> void:
	_setup_panel()
	_apply_large_text(_content_root)

	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_refresh_current_stats(bond)
	_refresh_dragon_state(DragonState.State.FOLLOWING)
	_connect_relationship_signals()
	_refresh_relationship_ui()


func _setup_panel() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = true


func bind_to_dragon(dragon: CharacterBody2D) -> void:
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
	_refresh_command_pending()
	_refresh_threat_distance()


func _apply_large_text(node: Node) -> void:
	if node is Label:
		var label := node as Label
		var node_name := node.name.to_lower()
		if node_name == "titlelabel" or node_name.ends_with("title"):
			label.add_theme_font_size_override("font_size", FONT_TITLE)
		elif node_name.ends_with("value"):
			label.add_theme_font_size_override("font_size", FONT_VALUE)
		elif node_name == "proposednotice" or node_name == "appliednotice":
			label.add_theme_font_size_override("font_size", FONT_NOTICE)
		else:
			label.add_theme_font_size_override("font_size", FONT_BODY)

	for child in node.get_children():
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
	_bond_tier_value.text = BondResilience.get_bond_tier_label(bond_strength)
	_bond_tier_progress_value.text = str(snapped(BondResilience.get_bond_tier_progress(bond_strength), 0.01))
	_future_sync_floor_value.text = str(snapped(BondResilience.get_sync_floor(bond_strength), 0.1))
	var resistance_percent: int = int(round(BondResilience.get_instability_resistance(bond_strength) * 100.0))
	_future_instability_resistance_value.text = "%d%%" % resistance_percent
	_future_instability_recovery_value.text = "%.2fx" % BondResilience.get_instability_recovery_rate(bond_strength)


func _refresh_protection_stats(bond_strength: float) -> void:
	_alert_range_value.text = str(int(BondResilience.get_alert_range(bond_strength)))

	if _protection_behavior == null:
		_protection_radius_value.text = "-"
		_protection_delay_value.text = "-"
		_protection_persistence_value.text = "-"
		return

	_protection_radius_value.text = str(int(_protection_behavior.get_protection_radius(bond_strength)))
	_protection_delay_value.text = str(_protection_behavior.get_response_delay(bond_strength))
	_protection_persistence_value.text = str(_protection_behavior.get_persistence_duration(bond_strength))


func _refresh_threat_distance() -> void:
	if _threat_behavior == null:
		_threat_distance_value.text = "-"
		return

	var distance: float = _threat_behavior.get_nearest_enemy_distance()
	if distance < 0.0:
		_threat_distance_value.text = "-"
	else:
		_threat_distance_value.text = str(int(distance))


func _refresh_command_pending() -> void:
	if _command_behavior == null:
		_pending_command_value.text = "-"
		_command_delay_value.text = "-"
		return

	_pending_command_value.text = _command_behavior.get_pending_command_label()
	var delay_remaining: float = _command_behavior.get_command_delay_remaining()
	if delay_remaining <= 0.0:
		_command_delay_value.text = "0"
	else:
		_command_delay_value.text = str(snapped(delay_remaining, 0.01))


func _refresh_dragon_state(state: DragonState.State) -> void:
	_dragon_state_value.text = DragonState.state_display_name(state)


func _refresh_dragon_thought(message: String) -> void:
	if message.is_empty():
		var fallback := DragonCommunicationCatalog.get_dragon_message(
			DragonCommunicationCatalog.Cue.FOLLOWING,
			BondSystem.get_profile().bond_strength
		)
		_dragon_thought_value.text = "\"%s\"" % fallback
	else:
		_dragon_thought_value.text = "\"%s\"" % message


func _refresh_current_stats(bond: BondProfile) -> void:
	_current_bond_value.text = str(int(bond.bond_strength))
	_current_sync_value.text = str(int(bond.sync))
	_current_instability_value.text = str(int(bond.instability))


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
	_recent_events_value.text = RelationshipSystem.get_recent_event_log_text()


func _refresh_relationship_ui() -> void:
	var active := RelationshipSystem.get_active_encounter_summary()
	if active == null:
		_assists_value.text = "0"
		_protections_value.text = "0"
		_cancellations_value.text = "0"
		_damage_value.text = "0"
		_deaths_value.text = "NO"
		_encounter_active_value.text = "NO"
		_encounter_id_value.text = "-"
		_involved_count_value.text = "0"
		_was_disengaged_value.text = "NO"
		_disengage_count_value.text = "0"
		_excellent_eligible_value.text = "NO"
		_cooperation_rating_value.text = "-"
	else:
		_assists_value.text = str(active.successful_assists)
		_protections_value.text = str(active.successful_protections)
		_cancellations_value.text = str(active.assist_cancellations)
		_damage_value.text = str(int(active.player_damage_taken))
		_deaths_value.text = "YES" if active.player_died else "NO"
		if RelationshipSystem.is_in_disengage_grace():
			_encounter_active_value.text = "YES (grace)"
		else:
			_encounter_active_value.text = "YES"
		_encounter_id_value.text = active.encounter_id
		_involved_count_value.text = str(active.get_involved_enemy_count())
		_was_disengaged_value.text = RelationshipEncounterSummary.yes_no(active.was_disengaged)
		_disengage_count_value.text = str(active.disengage_count)
		_excellent_eligible_value.text = RelationshipEncounterSummary.yes_no(
			active.is_excellent_quality_eligible()
		)
		_cooperation_rating_value.text = CooperationRatingClassifier.rating_label(
			CooperationRatingClassifier.classify(active)
		)

	_refresh_last_encounter()
	_refresh_applied_deltas()
	_refresh_proposed_bond()
	_refresh_recent_events()


func _refresh_last_encounter() -> void:
	var last := RelationshipSystem.get_last_resolved_summary()
	if last == null:
		_last_encounter_id_value.text = "-"
		_last_resolved_outcome_value.text = "-"
		_last_quality_value.text = "-"
		_last_cooperation_value.text = "-"
		_last_involved_value.text = "-"
		_last_summary_value.text = "-"
		_last_was_disengaged_value.text = "-"
		_last_disengage_count_value.text = "-"
		_last_excellent_eligible_value.text = "-"
		_last_applied_sync_value.text = "-"
		_last_applied_instability_value.text = "-"
		return

	_last_encounter_id_value.text = last.encounter_id
	_last_resolved_outcome_value.text = RelationshipSystem.get_last_resolved_outcome_label()
	_last_quality_value.text = RelationshipSystem.get_last_quality_label()
	_last_cooperation_value.text = RelationshipSystem.get_last_cooperation_label()
	_last_involved_value.text = str(last.get_involved_enemy_count())
	_last_summary_value.text = last.format_counter_summary()
	_last_was_disengaged_value.text = RelationshipEncounterSummary.yes_no(last.was_disengaged)
	_last_disengage_count_value.text = str(last.disengage_count)
	_last_excellent_eligible_value.text = RelationshipEncounterSummary.yes_no(
		last.is_excellent_quality_eligible()
	)
	if RelationshipSystem.has_last_applied_stats():
		_last_applied_sync_value.text = _format_applied_delta(RelationshipSystem.get_last_applied_sync_delta())
		_last_applied_instability_value.text = _format_applied_delta(
			RelationshipSystem.get_last_applied_instability_delta()
		)
	else:
		_last_applied_sync_value.text = "-"
		_last_applied_instability_value.text = "-"


func _refresh_applied_deltas() -> void:
	if not RelationshipSystem.has_last_applied_stats():
		_applied_sync_value.text = "-"
		_applied_instability_value.text = "-"
		_applied_bond_value.text = "NOT APPLIED"
		return

	_applied_sync_value.text = _format_applied_delta(RelationshipSystem.get_last_applied_sync_delta())
	_applied_instability_value.text = _format_applied_delta(
		RelationshipSystem.get_last_applied_instability_delta()
	)
	_applied_bond_value.text = "NOT APPLIED"


func _refresh_proposed_bond() -> void:
	if not RelationshipSystem.has_last_proposed_deltas():
		_proposed_bond_value.text = "-"
		return

	var proposed := RelationshipSystem.get_last_proposed_deltas()
	if proposed == null or is_zero_approx(proposed.bond_delta):
		_proposed_bond_value.text = "0"
		return

	_proposed_bond_value.text = proposed.format_bond()


func _format_applied_delta(value: float) -> String:
	if is_zero_approx(value):
		return "0"
	if value > 0.0:
		return "+%s" % str(snapped(value, 0.1))
	return str(snapped(value, 0.1))


func _refresh_session_history() -> void:
	_session_count_value.text = "Encounters: %d" % RelationshipSystem.get_session_encounter_count()
	_session_history_value.text = RelationshipSystem.get_session_history_text()

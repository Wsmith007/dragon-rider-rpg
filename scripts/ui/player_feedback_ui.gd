extends Control
## Player-facing communication layer — encounter summary, relationship direction, area announce.


const SUMMARY_VISIBLE_SECONDS := 2.6
const TOAST_VISIBLE_SECONDS := 1.8
const FLOATER_LIFETIME := 0.85
const AREA_VISIBLE_SECONDS := 3.2

@onready var _encounter_panel: PanelContainer = $EncounterSummaryPanel
@onready var _encounter_title: Label = $EncounterSummaryPanel/Margin/VBox/TitleLabel
@onready var _encounter_outcome: Label = $EncounterSummaryPanel/Margin/VBox/OutcomeLabel
@onready var _encounter_teamwork: Label = $EncounterSummaryPanel/Margin/VBox/TeamworkLabel
@onready var _encounter_relationship: Label = $EncounterSummaryPanel/Margin/VBox/RelationshipLabel
@onready var _relationship_toast: Label = $RelationshipToast
@onready var _area_announce: Label = $AreaAnnounceLabel
@onready var _floater_root: Control = $FloaterRoot

var _summary_tween: Tween
var _toast_tween: Tween
var _area_tween: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_encounter_panel.visible = false
	_encounter_panel.modulate.a = 0.0
	_relationship_toast.visible = false
	_relationship_toast.modulate.a = 0.0
	_area_announce.visible = false
	_area_announce.modulate.a = 0.0
	_connect_relationship_signals()


func announce_area(area_name: String) -> void:
	if area_name.is_empty():
		return
	_area_announce.text = area_name
	_show_area_announce()


func show_toast(text: String) -> void:
	if text.is_empty():
		return
	_show_relationship_toast(text)


func bind(game_root: Node2D) -> void:
	if game_root == null:
		return

	var player := game_root.get_node_or_null("Entities/Player") as CharacterBody2D
	if player == null:
		return

	var melee := player.get_node_or_null("MeleeAttack")
	if melee != null and melee.has_signal("attack_hit"):
		if not melee.attack_hit.is_connected(_on_attack_hit):
			melee.attack_hit.connect(_on_attack_hit)


func _connect_relationship_signals() -> void:
	if not RelationshipSystem.encounter_result_ready.is_connected(_on_encounter_result_ready):
		RelationshipSystem.encounter_result_ready.connect(_on_encounter_result_ready)
	if not RelationshipSystem.relationship_stats_applied.is_connected(_on_relationship_stats_applied):
		RelationshipSystem.relationship_stats_applied.connect(_on_relationship_stats_applied)


func _on_encounter_result_ready(
	_summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality,
	_proposed: ProposedRelationshipDeltas
) -> void:
	var sync_delta := RelationshipSystem.get_last_applied_sync_delta()
	var instability_delta := RelationshipSystem.get_last_applied_instability_delta()

	_encounter_title.text = "Encounter Complete"
	_encounter_outcome.text = "Outcome: %s" % PlayerFeedbackLabels.outcome_rating_label(quality)
	_encounter_teamwork.text = "Teamwork: %s" % PlayerFeedbackLabels.teamwork_label(
		RelationshipSystem.get_last_cooperation()
	)
	_encounter_relationship.text = PlayerFeedbackLabels.relationship_direction_label(
		sync_delta,
		instability_delta
	)

	_show_encounter_summary()


func _on_relationship_stats_applied(
	_encounter_id: String,
	sync_delta: float,
	instability_delta: float
) -> void:
	var lines := PlayerFeedbackLabels.stat_change_lines(sync_delta, instability_delta)
	if lines.is_empty():
		return
	_show_relationship_toast("\n".join(lines))


func _on_attack_hit(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return

	_spawn_floater(enemy.global_position + Vector2(0.0, -28.0), "Hit!", Color(1.0, 0.92, 0.55, 1.0))
	call_deferred("_evaluate_hit_result", enemy)


func _evaluate_hit_result(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if not enemy.has_method("is_staggered"):
		return

	if enemy.is_staggered():
		_spawn_floater(enemy.global_position + Vector2(0.0, -46.0), "Staggered", Color(0.85, 0.95, 1.0, 1.0))
		return

	if _is_brute(enemy):
		_spawn_floater(enemy.global_position + Vector2(0.0, -46.0), "Resisted", Color(0.82, 0.72, 0.68, 1.0))
		return

	if _is_scout(enemy) and enemy.has_method("is_engaging_player") and not enemy.is_engaging_player():
		_spawn_floater(enemy.global_position + Vector2(0.0, -46.0), "Retreating", Color(0.78, 0.88, 1.0, 1.0))


func _is_brute(enemy: Node2D) -> bool:
	if not enemy.has_meta("slice_archetype"):
		return false
	return int(enemy.get_meta("slice_archetype")) == VerticalSliceArchetypePresets.Archetype.BRUTE


func _is_scout(enemy: Node2D) -> bool:
	if not enemy.has_meta("slice_archetype"):
		return false
	return int(enemy.get_meta("slice_archetype")) == VerticalSliceArchetypePresets.Archetype.SCOUT


func _show_encounter_summary() -> void:
	if _summary_tween != null and _summary_tween.is_valid():
		_summary_tween.kill()

	_encounter_panel.visible = true
	_encounter_panel.modulate.a = 0.0
	_summary_tween = create_tween()
	_summary_tween.tween_property(_encounter_panel, "modulate:a", 1.0, 0.18)
	_summary_tween.tween_interval(SUMMARY_VISIBLE_SECONDS)
	_summary_tween.tween_property(_encounter_panel, "modulate:a", 0.0, 0.28)
	_summary_tween.tween_callback(func() -> void:
		_encounter_panel.visible = false
	)


func _show_area_announce() -> void:
	if _area_tween != null and _area_tween.is_valid():
		_area_tween.kill()

	_area_announce.visible = true
	_area_announce.modulate.a = 0.0
	_area_tween = create_tween()
	_area_tween.tween_property(_area_announce, "modulate:a", 1.0, 0.2)
	_area_tween.tween_interval(AREA_VISIBLE_SECONDS)
	_area_tween.tween_property(_area_announce, "modulate:a", 0.0, 0.35)
	_area_tween.tween_callback(func() -> void:
		_area_announce.visible = false
	)


func _show_relationship_toast(text: String) -> void:
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()

	_relationship_toast.text = text
	_relationship_toast.visible = true
	_relationship_toast.modulate.a = 0.0
	_toast_tween = create_tween()
	_toast_tween.tween_property(_relationship_toast, "modulate:a", 1.0, 0.12)
	_toast_tween.tween_interval(TOAST_VISIBLE_SECONDS)
	_toast_tween.tween_property(_relationship_toast, "modulate:a", 0.0, 0.22)
	_toast_tween.tween_callback(func() -> void:
		_relationship_toast.visible = false
	)


func _spawn_floater(world_position: Vector2, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.08, 0.95))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_font_size_override("font_size", 14)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floater_root.add_child(label)

	var screen_pos := get_viewport().get_canvas_transform() * world_position
	label.position = screen_pos - Vector2(24.0, 8.0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 22.0, FLOATER_LIFETIME)
	tween.tween_property(label, "modulate:a", 0.0, FLOATER_LIFETIME).set_delay(0.28)
	tween.chain().tween_callback(label.queue_free)

extends RefCounted
class_name EncounterQualityClassifier
## Outcome / stress rating for an encounter. Label only — drives Instability deltas.
##
## EXCELLENT — clean outcome: enemy defeated with zero rider/dragon harm.
## GOOD — enemy defeated with light harm or manageable flee stress.
## NEUTRAL — unremarkable solo kill, minor flee, or moderate unresolved strain.
## POOR — heavy harm, near-death, or stressful failed/disengaged outcome.
## DISASTROUS — player or dragon death.


enum Quality {
	EXCELLENT,
	GOOD,
	NEUTRAL,
	POOR,
	DISASTROUS,
}


const REFERENCE_MAX_HP := 100.0
const DAMAGE_GOOD_RATIO := 0.30
const DAMAGE_POOR_RATIO := 0.35


static func classify(summary: RelationshipEncounterSummary) -> Quality:
	if summary == null:
		return Quality.NEUTRAL

	if summary.player_died or summary.dragon_died:
		return Quality.DISASTROUS

	match summary.resolved_outcome:
		RelationshipEncounterSummary.ResolvedOutcome.PLAYER_DEATH:
			return Quality.DISASTROUS
		RelationshipEncounterSummary.ResolvedOutcome.FLED_DISENGAGED:
			return _classify_fled(summary)
		RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED:
			return _classify_enemy_defeated(summary)
		_:
			return Quality.NEUTRAL


static func _classify_fled(summary: RelationshipEncounterSummary) -> Quality:
	var damage_ratio := summary.player_damage_taken / REFERENCE_MAX_HP

	if summary.player_near_death_count >= 1 or damage_ratio >= DAMAGE_POOR_RATIO:
		return Quality.POOR

	if damage_ratio >= DAMAGE_GOOD_RATIO:
		return Quality.NEUTRAL

	return Quality.NEUTRAL


static func _classify_enemy_defeated(summary: RelationshipEncounterSummary) -> Quality:
	var damage_ratio := summary.player_damage_taken / REFERENCE_MAX_HP

	if summary.player_near_death_count >= 1 or damage_ratio >= DAMAGE_POOR_RATIO:
		return Quality.POOR

	if _is_excellent_quality(summary):
		return Quality.EXCELLENT

	if damage_ratio <= DAMAGE_GOOD_RATIO:
		return Quality.GOOD

	return Quality.NEUTRAL


static func _is_excellent_quality(summary: RelationshipEncounterSummary) -> bool:
	if summary.player_near_death_count > 0 or summary.player_died:
		return false
	if not is_zero_approx(summary.player_damage_taken):
		return false
	if not is_zero_approx(summary.dragon_damage_taken) or summary.dragon_critical or summary.dragon_died:
		return false
	if summary.was_disengaged or summary.reengaged_after_disengage:
		return false
	return true


static func quality_label(quality: Quality) -> String:
	match quality:
		Quality.EXCELLENT:
			return "Excellent"
		Quality.GOOD:
			return "Good"
		Quality.NEUTRAL:
			return "Neutral"
		Quality.POOR:
			return "Poor"
		Quality.DISASTROUS:
			return "Disastrous"
		_:
			return "Unknown"


static func quality_debug_summary(summary: RelationshipEncounterSummary, quality: Quality) -> String:
	return (
		"Outcome=%s | Quality=%s | excellent_quality=%s | disengage=%d | damage=%.0f (%.0f%%) | "
		+ "near_death=%d | died=%s | defeated=%d"
	) % [
		RelationshipEncounterSummary.outcome_label(summary.resolved_outcome),
		quality_label(quality),
		RelationshipEncounterSummary.yes_no(summary.is_excellent_quality_eligible()),
		summary.disengage_count,
		summary.player_damage_taken,
		(summary.player_damage_taken / REFERENCE_MAX_HP) * 100.0,
		summary.player_near_death_count,
		str(summary.player_died),
		summary.enemies_defeated,
	]

extends RefCounted
class_name EncounterQualityClassifier
## Prototype encounter quality classifier. Label only — no stat writes.
##
## EXCELLENT — flawless cooperation: both contributed, zero rider/dragon damage,
##   zero cancels, no disengage, not previously disqualified.
##
## GOOD — enemy defeated with rider-dragon cooperation and manageable strain.
##
## NEUTRAL — solo kills, minor flee, or unremarkable resolve.
##
## POOR — heavy harm, near-death, messy victory, or bad fled outcome.
##
## DISASTROUS — player death (future: dragon death).


enum Quality {
	EXCELLENT,
	GOOD,
	NEUTRAL,
	POOR,
	DISASTROUS,
}


const REFERENCE_MAX_HP := 1000.0
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

	if summary.assist_cancellations >= 3:
		return Quality.POOR

	if summary.assist_cancellations >= 2 and damage_ratio >= 0.12:
		return Quality.POOR

	return Quality.NEUTRAL


static func _classify_enemy_defeated(summary: RelationshipEncounterSummary) -> Quality:
	var damage_ratio := summary.player_damage_taken / REFERENCE_MAX_HP
	var player_involved := summary.player_contributed_meaningfully()
	var dragon_involved := summary.dragon_contributed_meaningfully()

	if _is_messy_victory(summary, damage_ratio):
		return Quality.POOR

	if summary.is_excellent_eligible():
		return Quality.EXCELLENT

	if player_involved and dragon_involved \
			and damage_ratio <= DAMAGE_GOOD_RATIO \
			and summary.assist_cancellations <= 1 \
			and summary.player_near_death_count == 0:
		return Quality.GOOD

	if player_involved and not dragon_involved:
		return Quality.NEUTRAL

	if dragon_involved and not player_involved:
		return Quality.NEUTRAL

	return Quality.NEUTRAL


static func _is_messy_victory(summary: RelationshipEncounterSummary, damage_ratio: float) -> bool:
	if summary.player_near_death_count >= 1:
		return true
	if damage_ratio >= DAMAGE_POOR_RATIO:
		return true
	if summary.assist_cancellations >= 2:
		return true
	if summary.assist_cancellations >= 1 and damage_ratio >= 0.12:
		return true
	if summary.was_disengaged and damage_ratio >= 0.20:
		return true
	return false


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
		"Outcome=%s | Quality=%s | excellent=%s | disengage=%d | damage=%.0f (%.0f%%) | "
		+ "assists=%d | prot=%d | cancel=%d | player_hits=%d | near_death=%d | died=%s"
	) % [
		RelationshipEncounterSummary.outcome_label(summary.resolved_outcome),
		quality_label(quality),
		RelationshipEncounterSummary.yes_no(summary.is_excellent_eligible()),
		summary.disengage_count,
		summary.player_damage_taken,
		(summary.player_damage_taken / REFERENCE_MAX_HP) * 100.0,
		summary.successful_assists,
		summary.successful_protections,
		summary.assist_cancellations,
		summary.player_attacks_landed,
		summary.player_near_death_count,
		str(summary.player_died),
	]

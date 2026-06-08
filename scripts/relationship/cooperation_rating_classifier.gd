extends RefCounted
class_name CooperationRatingClassifier
## Teamwork / execution rating for an encounter. Label only — drives Sync deltas.
##
## EXCELLENT — rider and dragon both contributed with clean assist/protection execution.
## GOOD — both contributed with minor hesitations or a single cancel.
## NEUTRAL — solo rider or solo dragon outcome; no meaningful teamwork to score.
## POOR — repeated cancels/hesitations or weak joint execution despite involvement.
## DISASTROUS — sustained failed cooperation with no successful joint actions.


enum Rating {
	EXCELLENT,
	GOOD,
	NEUTRAL,
	POOR,
	DISASTROUS,
}


static func classify(summary: RelationshipEncounterSummary) -> Rating:
	if summary == null:
		return Rating.NEUTRAL

	var player_involved := summary.player_contributed_meaningfully()
	var dragon_involved := summary.dragon_contributed_meaningfully()

	if player_involved and not dragon_involved:
		return Rating.NEUTRAL

	if dragon_involved and not player_involved:
		if summary.assist_cancellations >= 2 or summary.assist_hesitations >= 2:
			return Rating.POOR
		return Rating.NEUTRAL

	if not player_involved and not dragon_involved:
		return _classify_non_contribution(summary)

	return _classify_teamwork(summary)


static func _classify_non_contribution(summary: RelationshipEncounterSummary) -> Rating:
	if summary.assist_cancellations >= 4 or summary.assist_hesitations >= 4:
		return Rating.POOR
	return Rating.NEUTRAL


static func _classify_teamwork(summary: RelationshipEncounterSummary) -> Rating:
	var cancels := summary.assist_cancellations
	var hesitations := summary.assist_hesitations
	var successes := summary.get_dragon_successes()

	if successes == 0 and cancels >= 4 and hesitations >= 2:
		return Rating.DISASTROUS

	if cancels >= 4:
		return Rating.POOR

	if cancels >= 3 and successes <= 1:
		return Rating.POOR

	if cancels >= 2 and successes == 0:
		return Rating.POOR

	if hesitations >= 3 and successes <= 1:
		return Rating.POOR

	if cancels == 0 and hesitations == 0 and successes >= 1:
		return Rating.EXCELLENT

	if cancels <= 1 and hesitations <= 1 and successes >= 1:
		return Rating.GOOD

	if cancels >= 2 or hesitations >= 2:
		return Rating.POOR

	return Rating.NEUTRAL


static func rating_label(rating: Rating) -> String:
	match rating:
		Rating.EXCELLENT:
			return "Excellent"
		Rating.GOOD:
			return "Good"
		Rating.NEUTRAL:
			return "Neutral"
		Rating.POOR:
			return "Poor"
		Rating.DISASTROUS:
			return "Disastrous"
		_:
			return "Unknown"


static func rating_debug_summary(
	summary: RelationshipEncounterSummary,
	rating: Rating
) -> String:
	return (
		"Cooperation=%s | assists=%d | prot=%d | cancel=%d | hesitate=%d | "
		+ "player_hits=%d | dragon_success=%d"
	) % [
		rating_label(rating),
		summary.successful_assists,
		summary.successful_protections,
		summary.assist_cancellations,
		summary.assist_hesitations,
		summary.player_attacks_landed,
		summary.get_dragon_successes(),
	]

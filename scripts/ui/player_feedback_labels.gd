extends RefCounted
class_name PlayerFeedbackLabels
## Player-facing labels derived from existing encounter classifiers and applied deltas.


static func outcome_rating_label(quality: EncounterQualityClassifier.Quality) -> String:
	match quality:
		EncounterQualityClassifier.Quality.EXCELLENT:
			return "Flawless Outcome"
		EncounterQualityClassifier.Quality.GOOD:
			return "Clean Outcome"
		EncounterQualityClassifier.Quality.NEUTRAL:
			return "Fair Outcome"
		EncounterQualityClassifier.Quality.POOR:
			return "Rough Outcome"
		EncounterQualityClassifier.Quality.DISASTROUS:
			return "Dangerous Outcome"
		_:
			return "Fair Outcome"


static func teamwork_label(rating: CooperationRatingClassifier.Rating) -> String:
	match rating:
		CooperationRatingClassifier.Rating.EXCELLENT:
			return "Excellent Teamwork"
		CooperationRatingClassifier.Rating.GOOD:
			return "Good Teamwork"
		CooperationRatingClassifier.Rating.NEUTRAL:
			return "Independent Fight"
		CooperationRatingClassifier.Rating.POOR:
			return "Poor Coordination"
		CooperationRatingClassifier.Rating.DISASTROUS:
			return "Failed Coordination"
		_:
			return "Independent Fight"


static func relationship_direction_label(sync_delta: float, instability_delta: float) -> String:
	if instability_delta < -0.01 or (sync_delta > 0.01 and instability_delta <= 0.01):
		return "Relationship Improved"
	if instability_delta > 0.01 or sync_delta < -0.01:
		return "Relationship Strained"
	if sync_delta > 0.01:
		return "Partnership Stronger"
	return "Relationship Steady"


static func stat_change_lines(sync_delta: float, instability_delta: float) -> PackedStringArray:
	var lines: PackedStringArray = []
	if sync_delta > 0.01:
		lines.append("↑ Sync")
	elif sync_delta < -0.01:
		lines.append("↓ Sync")
	if instability_delta > 0.01:
		lines.append("↑ Instability")
	elif instability_delta < -0.01:
		lines.append("↓ Instability")
	return lines


static func dragon_status_label(state: DragonState.State) -> String:
	match state:
		DragonState.State.FOLLOWING, DragonState.State.ALERT:
			return "Following"
		DragonState.State.WAITING:
			return "Waiting"
		DragonState.State.PROTECTING:
			return "Protecting"
		DragonState.State.ASSISTING:
			return "Assisting"
		DragonState.State.HESITATING:
			return "Hesitating"
		_:
			return "Following"

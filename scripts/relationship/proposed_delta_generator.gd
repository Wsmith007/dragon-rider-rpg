extends RefCounted
class_name ProposedDeltaGenerator
## Encounter Quality → Instability. Cooperation Rating → Sync. Bond remains preview-only.


static func get_instability_delta_for_quality(
	quality: EncounterQualityClassifier.Quality
) -> float:
	match quality:
		EncounterQualityClassifier.Quality.EXCELLENT:
			return -2.0
		EncounterQualityClassifier.Quality.GOOD:
			return -1.0
		EncounterQualityClassifier.Quality.POOR:
			return 2.0
		EncounterQualityClassifier.Quality.DISASTROUS:
			return 4.0
		_:
			return 0.0


static func get_sync_delta_for_cooperation(
	cooperation: CooperationRatingClassifier.Rating
) -> float:
	match cooperation:
		CooperationRatingClassifier.Rating.EXCELLENT:
			return 2.0
		CooperationRatingClassifier.Rating.GOOD:
			return 1.0
		CooperationRatingClassifier.Rating.POOR:
			return -1.0
		CooperationRatingClassifier.Rating.DISASTROUS:
			return -2.0
		_:
			return 0.0


static func get_stat_deltas(
	quality: EncounterQualityClassifier.Quality,
	cooperation: CooperationRatingClassifier.Rating
) -> Dictionary:
	return {
		"sync_delta": get_sync_delta_for_cooperation(cooperation),
		"instability_delta": get_instability_delta_for_quality(quality),
	}


static func should_propose_bond_delta(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality
) -> bool:
	if summary == null:
		return false

	match summary.resolved_outcome:
		RelationshipEncounterSummary.ResolvedOutcome.PLAYER_DEATH:
			return quality == EncounterQualityClassifier.Quality.DISASTROUS
		RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED:
			return quality != EncounterQualityClassifier.Quality.NEUTRAL
		RelationshipEncounterSummary.ResolvedOutcome.FLED_DISENGAGED:
			return quality in [
				EncounterQualityClassifier.Quality.POOR,
				EncounterQualityClassifier.Quality.DISASTROUS,
			]
		_:
			return false


static func should_propose_deltas(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality,
	_cooperation: CooperationRatingClassifier.Rating
) -> bool:
	return should_propose_bond_delta(summary, quality)


static func generate(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality,
	cooperation: CooperationRatingClassifier.Rating
) -> ProposedRelationshipDeltas:
	var deltas := ProposedRelationshipDeltas.new()
	deltas.quality = quality
	deltas.cooperation_rating = cooperation

	var stat_deltas := get_stat_deltas(quality, cooperation)
	deltas.sync_delta = stat_deltas.sync_delta
	deltas.instability_delta = stat_deltas.instability_delta

	if not should_propose_bond_delta(summary, quality):
		deltas.bond_delta = 0.0
		deltas.notes = "Bond unchanged (preview only)."
		return deltas

	match quality:
		EncounterQualityClassifier.Quality.EXCELLENT:
			deltas.bond_delta = 0.0
			deltas.notes = "Clean outcome; Bond unchanged until pattern pass."
		EncounterQualityClassifier.Quality.GOOD:
			deltas.bond_delta = 0.0
			deltas.notes = "Solid outcome; Bond unchanged until pattern pass."
		EncounterQualityClassifier.Quality.POOR:
			deltas.bond_delta = 0.0
			deltas.notes = "Stressful outcome; Bond unchanged until pattern pass."
		EncounterQualityClassifier.Quality.DISASTROUS:
			deltas.bond_delta = -1.0
			deltas.notes = "Catastrophic outcome; Bond preview for future pattern pass."
		_:
			deltas.bond_delta = 0.0
			deltas.notes = "No proposed Bond change."

	return deltas

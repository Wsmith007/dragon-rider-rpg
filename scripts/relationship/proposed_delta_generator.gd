extends RefCounted
class_name ProposedDeltaGenerator
## Debug-only evaluator: encounter summary + quality → proposed deltas. NOT APPLIED.
##
## Proposed deltas appear only for resolved encounters with meaningful outcomes.
## Neutral fled/disengage and player-only kills intentionally produce no preview.


static func should_propose_deltas(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality
) -> bool:
	if summary == null:
		return false

	match summary.resolved_outcome:
		RelationshipEncounterSummary.ResolvedOutcome.PLAYER_DEATH:
			return true
		RelationshipEncounterSummary.ResolvedOutcome.ENEMY_DEFEATED:
			return quality != EncounterQualityClassifier.Quality.NEUTRAL
		RelationshipEncounterSummary.ResolvedOutcome.FLED_DISENGAGED:
			return quality in [
				EncounterQualityClassifier.Quality.POOR,
				EncounterQualityClassifier.Quality.DISASTROUS,
			]
		_:
			return false


static func generate(
	summary: RelationshipEncounterSummary,
	quality: EncounterQualityClassifier.Quality
) -> ProposedRelationshipDeltas:
	var deltas := ProposedRelationshipDeltas.new()
	deltas.quality = quality

	if not should_propose_deltas(summary, quality):
		deltas.notes = "No proposed changes for this outcome."
		return deltas

	match quality:
		EncounterQualityClassifier.Quality.EXCELLENT:
			deltas.sync_delta = 2.0
			deltas.instability_delta = -1.0
			deltas.bond_delta = 0.0
			deltas.notes = "Strong cooperation, low harm."
		EncounterQualityClassifier.Quality.GOOD:
			deltas.sync_delta = 1.0
			deltas.instability_delta = -1.0
			deltas.bond_delta = 0.0
			deltas.notes = "Solid teamwork with minor strain."
		EncounterQualityClassifier.Quality.POOR:
			deltas.sync_delta = -1.0
			deltas.instability_delta = 2.0
			deltas.bond_delta = 0.0
			deltas.notes = "Heavy strain or messy cooperation."
		EncounterQualityClassifier.Quality.DISASTROUS:
			deltas.sync_delta = -2.0
			deltas.instability_delta = 3.0
			deltas.bond_delta = -1.0
			deltas.notes = "Catastrophic outcome; Bond preview for future pattern pass."
		_:
			deltas.notes = "No proposed changes for this outcome."

	return deltas

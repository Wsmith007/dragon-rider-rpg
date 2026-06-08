extends RefCounted
class_name ProposedRelationshipDeltas
## Encounter quality → relationship deltas. Sync/Instability are applied (M9A).
## Bond delta is preview-only until a future Bond pattern pass.


var sync_delta: float = 0.0
var instability_delta: float = 0.0
var bond_delta: float = 0.0
var quality: EncounterQualityClassifier.Quality = EncounterQualityClassifier.Quality.NEUTRAL
var cooperation_rating: CooperationRatingClassifier.Rating = CooperationRatingClassifier.Rating.NEUTRAL
var notes: String = ""


func duplicate_deltas() -> ProposedRelationshipDeltas:
	var copy := ProposedRelationshipDeltas.new()
	copy.sync_delta = sync_delta
	copy.instability_delta = instability_delta
	copy.bond_delta = bond_delta
	copy.quality = quality
	copy.cooperation_rating = cooperation_rating
	copy.notes = notes
	return copy


func format_sync() -> String:
	return _format_delta(sync_delta)


func format_instability() -> String:
	return _format_delta(instability_delta)


func format_bond() -> String:
	return _format_delta(bond_delta)


func _format_delta(value: float) -> String:
	if is_zero_approx(value):
		return "0"
	if value > 0.0:
		return "+%s" % str(snapped(value, 0.1))
	return str(snapped(value, 0.1))

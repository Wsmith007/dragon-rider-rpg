extends RefCounted
class_name RelationshipSessionTracker
## Session-level encounter quality history. No Bond evaluation or stat writes.


const MAX_HISTORY := 10

signal session_updated

var encounter_count: int = 0
var encounter_qualities: Array[int] = []


func record_encounter_quality(quality: EncounterQualityClassifier.Quality) -> void:
	encounter_count += 1
	encounter_qualities.append(quality)
	if encounter_qualities.size() > MAX_HISTORY:
		encounter_qualities = encounter_qualities.slice(encounter_qualities.size() - MAX_HISTORY)
	session_updated.emit()


func get_recent_quality_labels() -> PackedStringArray:
	var labels := PackedStringArray()
	for quality_value: int in encounter_qualities:
		labels.append(EncounterQualityClassifier.quality_label(quality_value as EncounterQualityClassifier.Quality))
	return labels


func get_recent_history_text() -> String:
	var labels := get_recent_quality_labels()
	if labels.is_empty():
		return "(none)"
	return ", ".join(labels)

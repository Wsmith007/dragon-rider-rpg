extends RefCounted
class_name GameAudioCatalog
## Maps gameplay events to placeholder streams, buses, and playback tweaks.
## Replace stream paths here when final assets arrive — callers stay unchanged.


const BUS_COMBAT := &"Combat"
const BUS_UI := &"UI"
const BUS_DRAGON := &"Dragon"
const BUS_AMBIENT := &"Ambient"
const BUS_MUSIC := &"Music"
const BUS_VOICE := &"Voice"

const PLACEHOLDER_SWING := "res://assets/audio/placeholders/swing.wav"
const PLACEHOLDER_IMPACT := "res://assets/audio/placeholders/impact.wav"
const PLACEHOLDER_UI_SOFT := "res://assets/audio/placeholders/ui_soft.wav"
const PLACEHOLDER_DEFEAT := "res://assets/audio/placeholders/defeat.wav"
const PLACEHOLDER_DRAGON := "res://assets/audio/placeholders/dragon_soft.wav"
const PLACEHOLDER_HEAVY := "res://assets/audio/placeholders/heavy_thud.wav"


static func get_playback(event: GameAudioEvent.Event) -> Dictionary:
	match event:
		GameAudioEvent.Event.PLAYER_SWING:
			return _entry(PLACEHOLDER_SWING, BUS_COMBAT, -8.0, 1.05, 1.12, true)
		GameAudioEvent.Event.PLAYER_CC:
			return _entry(PLACEHOLDER_SWING, BUS_COMBAT, -6.0, 0.88, 0.96, true)
		GameAudioEvent.Event.PLAYER_HIT, GameAudioEvent.Event.ENEMY_HIT:
			return _entry(PLACEHOLDER_IMPACT, BUS_COMBAT, -5.0, 0.95, 1.08, true)
		GameAudioEvent.Event.ATTACK_MISS:
			return _entry(PLACEHOLDER_SWING, BUS_COMBAT, -16.0, 0.72, 0.8, true)
		GameAudioEvent.Event.PLAYER_DAMAGED:
			return _entry(PLACEHOLDER_IMPACT, BUS_COMBAT, -6.0, 0.78, 0.88, true)
		GameAudioEvent.Event.ENEMY_DEFEATED:
			return _entry(PLACEHOLDER_DEFEAT, BUS_COMBAT, -4.0, 0.92, 1.0, true)
		GameAudioEvent.Event.BRUTE_HEAVY:
			return _entry(PLACEHOLDER_HEAVY, BUS_COMBAT, -2.0, 0.9, 1.0, true)
		GameAudioEvent.Event.BRUTE_RESIST:
			return _entry(PLACEHOLDER_HEAVY, BUS_COMBAT, -10.0, 1.15, 1.22, true)
		GameAudioEvent.Event.TARGET_FOCUS_ON:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -14.0, 1.0, 1.05, false)
		GameAudioEvent.Event.TARGET_FOCUS_SWITCH:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -16.0, 1.12, 1.18, false)
		GameAudioEvent.Event.TARGET_FOCUS_OFF:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -18.0, 0.82, 0.9, false)
		GameAudioEvent.Event.ENCOUNTER_COMPLETE:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -10.0, 0.72, 0.8, false)
		GameAudioEvent.Event.RELATIONSHIP_IMPROVED:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -12.0, 1.05, 1.12, false)
		GameAudioEvent.Event.RELATIONSHIP_STRAINED:
			return _entry(PLACEHOLDER_UI_SOFT, BUS_UI, -12.0, 0.88, 0.95, false)
		GameAudioEvent.Event.DRAGON_ASSIST:
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, -12.0, 1.0, 1.08, true)
		GameAudioEvent.Event.DRAGON_PROTECT:
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, -10.0, 0.88, 0.96, true)
		GameAudioEvent.Event.DRAGON_WAIT:
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, -16.0, 0.78, 0.86, true)
		_:
			return {}


static func unique_stream_paths() -> PackedStringArray:
	return PackedStringArray([
		PLACEHOLDER_SWING,
		PLACEHOLDER_IMPACT,
		PLACEHOLDER_UI_SOFT,
		PLACEHOLDER_DEFEAT,
		PLACEHOLDER_DRAGON,
		PLACEHOLDER_HEAVY,
	])


static func _entry(
	stream_path: String,
	bus_name: StringName,
	volume_db: float,
	pitch_min: float,
	pitch_max: float,
	positional: bool
) -> Dictionary:
	return {
		"stream_path": stream_path,
		"bus": bus_name,
		"volume_db": volume_db,
		"pitch_min": pitch_min,
		"pitch_max": pitch_max,
		"positional": positional,
	}

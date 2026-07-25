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
const PLACEHOLDER_SWING_DAGGER := "res://assets/audio/placeholders/swing_dagger.wav"
const PLACEHOLDER_SWING_SWORD := "res://assets/audio/placeholders/swing_sword.wav"
const PLACEHOLDER_SWING_POLEARM := "res://assets/audio/placeholders/swing_polearm.wav"
const PLACEHOLDER_IMPACT := "res://assets/audio/placeholders/impact.wav"
const PLACEHOLDER_UI_SOFT := "res://assets/audio/placeholders/ui_soft.wav"
const PLACEHOLDER_DEFEAT := "res://assets/audio/placeholders/defeat.wav"
const PLACEHOLDER_DRAGON := "res://assets/audio/placeholders/dragon_soft.wav"
const PLACEHOLDER_HEAVY := "res://assets/audio/placeholders/heavy_thud.wav"

## Small global trim on player attack feedback (swings + connects).
const ATTACK_VOLUME_TRIM_DB := -1.5
## Extra trim on weapon whoosh/swing only (impacts unchanged). Combat Stakes validation: ~-3 dB.
const SWING_VOLUME_TRIM_DB := -3.0
## Extra trim on CC swing sequence only (focused attacks unchanged).
const CC_VOLUME_TRIM_DB := -2.5
## Weapon impact library mix — normalized perceived loudness across profiles.
const WEAPON_IMPACT_VOLUME_DB := 1.5 + ATTACK_VOLUME_TRIM_DB
## Duck active swing layers ~12% so impacts read clearly.
const SWING_DUCK_DB := -1.35


static func get_playback(event: GameAudioEvent.Event) -> Dictionary:
	# Pass 1A mix intent (placeholder-normalized, catalog-only):
	# encounter > hit / enemy feedback > dragon > swing > lock-on UI
	match event:
		GameAudioEvent.Event.PLAYER_SWING:
			return _entry(
				PLACEHOLDER_SWING,
				BUS_COMBAT,
				-10.0 + ATTACK_VOLUME_TRIM_DB + SWING_VOLUME_TRIM_DB,
				1.05,
				1.12,
				true,
			)
		GameAudioEvent.Event.PLAYER_CC:
			return _entry(
				PLACEHOLDER_SWING,
				BUS_COMBAT,
				-8.0 + ATTACK_VOLUME_TRIM_DB + CC_VOLUME_TRIM_DB + SWING_VOLUME_TRIM_DB,
				0.88,
				0.96,
				true,
			)
		GameAudioEvent.Event.PLAYER_HIT, GameAudioEvent.Event.ENEMY_HIT:
			return {}
		GameAudioEvent.Event.ATTACK_MISS:
			return _entry(
				PLACEHOLDER_SWING,
				BUS_COMBAT,
				-16.0 + ATTACK_VOLUME_TRIM_DB + SWING_VOLUME_TRIM_DB,
				0.72,
				0.8,
				true,
			)
		GameAudioEvent.Event.PLAYER_DAMAGED:
			return _entry(PLACEHOLDER_IMPACT, BUS_COMBAT, -1.0, 0.82, 0.92, true)
		# Status warnings: non-positional UI bus. heavy_thud source peak ~0.28 — needs strong
		# catalog lift and near-normal pitch or it is inaudible under combat swings.
		GameAudioEvent.Event.PLAYER_CRITICAL_WARNING:
			return _entry(PLACEHOLDER_HEAVY, BUS_UI, 4.0, 0.92, 1.0, false)
		GameAudioEvent.Event.PLAYER_NEAR_DEATH_WARNING:
			return _entry(PLACEHOLDER_HEAVY, BUS_UI, 7.0, 0.82, 0.9, false)
		GameAudioEvent.Event.ENEMY_DEFEATED:
			return _entry(PLACEHOLDER_DEFEAT, BUS_COMBAT, -2.0, 0.92, 1.0, true)
		GameAudioEvent.Event.BRUTE_HEAVY:
			return _entry(PLACEHOLDER_HEAVY, BUS_COMBAT, 1.0, 0.92, 1.0, true)
		GameAudioEvent.Event.BRUTE_RESIST:
			return _entry(PLACEHOLDER_HEAVY, BUS_COMBAT, -6.0, 1.08, 1.15, true)
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
			# dragon_soft.wav source 0.06 vs swing 0.14; 220 Hz sine needs strong catalog lift.
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, 2.0, 1.02, 1.08, true)
		GameAudioEvent.Event.DRAGON_PROTECT:
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, 3.0, 0.96, 1.02, true)
		GameAudioEvent.Event.DRAGON_WAIT:
			return _entry(PLACEHOLDER_DRAGON, BUS_DRAGON, -2.0, 0.92, 0.98, true)
		_:
			return {}


static func get_weapon_swing_playback(
	profile_id: WeaponProfilePrototype.Id,
	cc_step: int = -1
) -> Dictionary:
	var tuning := _weapon_swing_tuning(profile_id)
	var volume_db: float = tuning["volume_db"]
	var pitch_min: float = tuning["pitch_min"]
	var pitch_max: float = tuning["pitch_max"]

	if cc_step >= 0:
		volume_db += CC_VOLUME_TRIM_DB
		volume_db += float(cc_step) * 2.25
		var pitch_lift := 0.05 + float(cc_step) * 0.045
		pitch_min += pitch_lift
		pitch_max += pitch_lift
		if cc_step == 2:
			volume_db += 1.5
			if profile_id == WeaponProfilePrototype.Id.POLEARM:
				pitch_min -= 0.04
				pitch_max -= 0.02

	return _entry(
		_weapon_swing_stream(profile_id),
		BUS_COMBAT,
		volume_db + ATTACK_VOLUME_TRIM_DB + SWING_VOLUME_TRIM_DB,
		pitch_min,
		pitch_max,
		true,
	)


static func get_weapon_impact_playback(stream_path: String) -> Dictionary:
	return _entry(stream_path, BUS_COMBAT, WEAPON_IMPACT_VOLUME_DB, 0.98, 1.02, true)


static func swing_stream_paths() -> PackedStringArray:
	return PackedStringArray([
		PLACEHOLDER_SWING,
		PLACEHOLDER_SWING_DAGGER,
		PLACEHOLDER_SWING_SWORD,
		PLACEHOLDER_SWING_POLEARM,
	])


static func _weapon_swing_stream(profile_id: WeaponProfilePrototype.Id) -> String:
	match int(profile_id):
		WeaponProfilePrototype.Id.DAGGER:
			return PLACEHOLDER_SWING_DAGGER
		WeaponProfilePrototype.Id.POLEARM:
			return PLACEHOLDER_SWING_POLEARM
		_:
			return PLACEHOLDER_SWING_SWORD


static func _weapon_swing_tuning(profile_id: WeaponProfilePrototype.Id) -> Dictionary:
	match int(profile_id):
		WeaponProfilePrototype.Id.DAGGER:
			return {"volume_db": -7.0, "pitch_min": 0.98, "pitch_max": 1.06}
		WeaponProfilePrototype.Id.POLEARM:
			return {"volume_db": -5.5, "pitch_min": 0.94, "pitch_max": 1.02}
		_:
			return {"volume_db": -9.0, "pitch_min": 0.96, "pitch_max": 1.04}


static func unique_stream_paths() -> PackedStringArray:
	var paths := PackedStringArray([
		PLACEHOLDER_SWING,
		PLACEHOLDER_SWING_DAGGER,
		PLACEHOLDER_SWING_SWORD,
		PLACEHOLDER_SWING_POLEARM,
		PLACEHOLDER_IMPACT,
		PLACEHOLDER_UI_SOFT,
		PLACEHOLDER_DEFEAT,
		PLACEHOLDER_DRAGON,
		PLACEHOLDER_HEAVY,
	])
	for impact_path in WeaponAudioProfile.all_stream_paths():
		if not paths.has(impact_path):
			paths.append(impact_path)
	return paths


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

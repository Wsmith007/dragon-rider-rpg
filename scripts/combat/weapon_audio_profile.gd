extends RefCounted
class_name WeaponAudioProfile
## Impact sound profiles — arrays of variation streams, independent of reach class.


enum Id { HIT_DAGGER, HIT_SWORD, HIT_POLEARM }

const LIBRARY_ROOT := "res://assets/audio/weapon_impact_library_v1/"

const PROFILE_STREAMS: Dictionary = {
	Id.HIT_DAGGER: [
		LIBRARY_ROOT + "hit_dagger_01.wav",
	],
	Id.HIT_SWORD: [
		LIBRARY_ROOT + "hit_sword_01.wav",
		LIBRARY_ROOT + "hit_sword_02.wav",
	],
	Id.HIT_POLEARM: [
		LIBRARY_ROOT + "hit_polearm_01.wav",
	],
}


static func profile_for_identity(identity_id: WeaponIdentity.Id) -> Id:
	match identity_id:
		WeaponIdentity.Id.DAGGER:
			return Id.HIT_DAGGER
		WeaponIdentity.Id.POLEARM:
			return Id.HIT_POLEARM
		_:
			return Id.HIT_SWORD


static func profile_for_weapon_profile(profile_id: WeaponProfilePrototype.Id) -> Id:
	return profile_for_identity(WeaponIdentity.from_weapon_profile(profile_id))


static func stream_paths_for_profile(profile_id: Id) -> PackedStringArray:
	var paths: Array = PROFILE_STREAMS.get(profile_id, [])
	return PackedStringArray(paths)


static func all_stream_paths() -> PackedStringArray:
	var unique: Dictionary = {}
	for profile_id in PROFILE_STREAMS.keys():
		for path in PROFILE_STREAMS[profile_id]:
			unique[path] = true
	return PackedStringArray(unique.keys())


static func pick_stream_path(profile_id: Id, variation_state: Dictionary) -> String:
	var paths: Array = PROFILE_STREAMS.get(profile_id, [])
	if paths.is_empty():
		return ""
	if paths.size() == 1:
		return String(paths[0])

	var state_key := str(int(profile_id))
	var state: Dictionary = variation_state.get(state_key, {"last_index": -1, "repeat_count": 0})
	var last_index: int = int(state.get("last_index", -1))
	var repeat_count: int = int(state.get("repeat_count", 0))

	var candidates: Array[int] = []
	for index in range(paths.size()):
		if index == last_index and repeat_count >= 2:
			continue
		candidates.append(index)

	if candidates.is_empty():
		for index in range(paths.size()):
			candidates.append(index)

	var pick_index: int = candidates[randi() % candidates.size()]
	if pick_index == last_index:
		state["repeat_count"] = repeat_count + 1
	else:
		state["repeat_count"] = 1
	state["last_index"] = pick_index
	variation_state[state_key] = state
	return String(paths[pick_index])

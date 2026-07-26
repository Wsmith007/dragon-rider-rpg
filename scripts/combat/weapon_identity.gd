extends RefCounted
class_name WeaponIdentity
## Weapon identity — what the weapon is. Audio comes from WeaponAudioProfile, not reach.


enum Id { DAGGER, SWORD, POLEARM }


static func display_name(identity_id: Id) -> String:
	match identity_id:
		Id.DAGGER:
			return "Dagger"
		Id.POLEARM:
			return "Polearm"
		_:
			return "Sword"


static func from_weapon_profile(profile_id: WeaponProfilePrototype.Id) -> Id:
	return WeaponProfilePrototype.get_identity(profile_id)


static func from_archetype(archetype: VerticalSliceArchetypePresets.Archetype) -> Id:
	match archetype:
		VerticalSliceArchetypePresets.Archetype.SCOUT:
			return Id.DAGGER
		VerticalSliceArchetypePresets.Archetype.BRUTE:
			# Warhammer placeholder maps to POLEARM identity for audio reuse.
			return Id.POLEARM
		_:
			return Id.SWORD

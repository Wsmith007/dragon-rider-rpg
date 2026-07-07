extends RefCounted
class_name WeaponReachClass
## Gameplay reach tier — range, arc, spacing. Does NOT select impact audio.


enum Id { SHORT, MEDIUM, LONG }


static func for_weapon_profile(profile_id: WeaponProfilePrototype.Id) -> Id:
	return WeaponProfilePrototype.get_reach_class(profile_id)

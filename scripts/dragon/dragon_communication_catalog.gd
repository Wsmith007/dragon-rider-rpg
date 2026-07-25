class_name DragonCommunicationCatalog
## Catalog helpers for dragon text.
##
## Ambient combat lines ("Danger.", "Clear.", "Together.", etc.) were playtested and
## rejected — they duplicated body-language cues and added clutter.
## Pass 1 personality is behavioral. Future player-initiated dialogue will use a
## different content model (context options), not automatic combat bubbles.


enum Cue {
	FOLLOWING,
	WAITING,
	ALERT,
	PROTECTING,
	ASSISTING,
	HESITATING,
	ASSIST_CANCELED,
	CLEAR,
	RECALLED,
	ENCOUNTER_CLEAR,
}


enum CommunicationTier {
	INSTINCTIVE,
	INTENT,
	REASONED,
	TELEPATHIC,
}


static func cue_for_state(state: DragonState.State) -> Cue:
	match state:
		DragonState.State.FOLLOWING:
			return Cue.FOLLOWING
		DragonState.State.WAITING:
			return Cue.WAITING
		DragonState.State.ALERT:
			return Cue.ALERT
		DragonState.State.PROTECTING:
			return Cue.PROTECTING
		DragonState.State.ASSISTING:
			return Cue.ASSISTING
		DragonState.State.HESITATING:
			return Cue.HESITATING
		_:
			return Cue.FOLLOWING


static func get_communication_tier(bond_strength: float) -> CommunicationTier:
	match BondResilience.get_bond_tier(bond_strength):
		BondResilience.BondTier.ONE:
			return CommunicationTier.INSTINCTIVE
		BondResilience.BondTier.TWO:
			return CommunicationTier.INTENT
		BondResilience.BondTier.THREE:
			return CommunicationTier.REASONED
		_:
			return CommunicationTier.TELEPATHIC


static func get_communication_tier_index(bond_strength: float) -> int:
	return BondResilience.get_bond_tier(bond_strength)


static func get_dragon_message(_event_key: Cue, _bond_strength: float) -> String:
	# Ambient catalog retired. Future dialogue content will not reuse combat bubble lines.
	return ""


static func get_message(cue: Cue, profile: BondProfile = null) -> String:
	var bond_strength: float = profile.bond_strength if profile != null else 50.0
	return get_dragon_message(cue, bond_strength)

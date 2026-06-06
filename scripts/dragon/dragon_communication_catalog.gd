class_name DragonCommunicationCatalog
## Player-facing dragon state feedback. Not dialogue — short situational lines only.
##
## Bond Strength controls how completely the rider understands the dragon's thoughts.
## The dragon is always intelligent; low bond = simpler perceived impressions.


enum Cue {
	FOLLOWING,
	WAITING,
	ALERT,
	PROTECTING,
	ASSISTING,
	HESITATING,
	ASSIST_CANCELED,
}


enum CommunicationTier {
	INSTINCTIVE,
	INTENT,
	REASONED,
	TELEPATHIC,
}


const _MESSAGES: Dictionary = {
	CommunicationTier.INSTINCTIVE: {
		Cue.FOLLOWING: "Watch.",
		Cue.WAITING: "Stay.",
		Cue.ALERT: "Danger.",
		Cue.PROTECTING: "No!",
		Cue.ASSISTING: "Hunt.",
		Cue.HESITATING: "Wrong.",
		Cue.ASSIST_CANCELED: "No.",
	},
	CommunicationTier.INTENT: {
		Cue.FOLLOWING: "Observing.",
		Cue.WAITING: "Holding.",
		Cue.ALERT: "Threat.",
		Cue.PROTECTING: "Protecting.",
		Cue.ASSISTING: "Assisting.",
		Cue.HESITATING: "Uncertain.",
		Cue.ASSIST_CANCELED: "Wait.",
	},
	CommunicationTier.REASONED: {
		Cue.FOLLOWING: "Keeping watch.",
		Cue.WAITING: "Waiting here.",
		Cue.ALERT: "Something's there.",
		Cue.PROTECTING: "Stay near.",
		Cue.ASSISTING: "Together.",
		Cue.HESITATING: "Something's off.",
		Cue.ASSIST_CANCELED: "Not now.",
	},
	CommunicationTier.TELEPATHIC: {
		Cue.FOLLOWING: "Watching over us.",
		Cue.WAITING: "I'll be here.",
		Cue.ALERT: "We aren't alone.",
		Cue.PROTECTING: "Behind me.",
		Cue.ASSISTING: "I'm with you.",
		Cue.HESITATING: "I don't trust this.",
		Cue.ASSIST_CANCELED: "Bad timing.",
	},
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


static func get_dragon_message(event_key: Cue, bond_strength: float) -> String:
	var tier := get_communication_tier(bond_strength)
	var tier_messages: Dictionary = _MESSAGES.get(tier, {})
	return tier_messages.get(event_key, _MESSAGES[CommunicationTier.INSTINCTIVE][Cue.FOLLOWING])


static func get_message(cue: Cue, profile: BondProfile = null) -> String:
	var bond_strength: float = profile.bond_strength if profile != null else 50.0
	return get_dragon_message(cue, bond_strength)

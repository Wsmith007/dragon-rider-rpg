extends Node
## Global access point for the active BondProfile. Register as autoload: BondSystem.

signal bond_changed(profile: BondProfile)

var profile: BondProfile


func _ready() -> void:
	profile = BondProfile.new()
	profile.profile_changed.connect(_on_profile_changed)


func get_profile() -> BondProfile:
	return profile


func set_bond_strength(value: float) -> void:
	profile.bond_strength = value


func set_sync(value: float) -> void:
	profile.sync = value


func set_instability(value: float) -> void:
	profile.instability = value


## DEPRECATED: Retained for compatibility. Does not affect gameplay.
func set_trust_state(value: String) -> void:
	profile.trust_state = value


func adjust_bond_strength(delta: float) -> void:
	profile.bond_strength = profile.bond_strength + delta


func adjust_sync(delta: float) -> void:
	profile.sync = profile.sync + delta


func adjust_instability(delta: float) -> void:
	profile.instability = profile.instability + delta


func _on_profile_changed() -> void:
	bond_changed.emit(profile)

extends Control
## Live debug readout for BondProfile and dragon state. Does not modify gameplay.

@onready var _bond_strength_value: Label = $Panel/Margin/VBox/Grid/BondStrengthValue
@onready var _sync_value: Label = $Panel/Margin/VBox/Grid/SyncValue
@onready var _instability_value: Label = $Panel/Margin/VBox/Grid/InstabilityValue
@onready var _trust_state_value: Label = $Panel/Margin/VBox/Grid/TrustStateValue
@onready var _dragon_state_value: Label = $Panel/Margin/VBox/Grid/DragonStateValue

var _dragon: CharacterBody2D


func bind_to_dragon(dragon: CharacterBody2D) -> void:
	_dragon = dragon
	if _dragon == null:
		push_warning("BondDebugUI: dragon reference is null.")
		return

	if not _dragon.state_changed.is_connected(_on_dragon_state_changed):
		_dragon.state_changed.connect(_on_dragon_state_changed)

	_refresh_dragon_state(_dragon.state)


func _ready() -> void:
	var bond := BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_refresh_dragon_state(DragonState.State.FOLLOWING)


func _on_bond_profile_changed(_unused = null) -> void:
	_refresh_bond(BondSystem.get_profile())


func _on_dragon_state_changed(state: DragonState.State) -> void:
	_refresh_dragon_state(state)


func _refresh_bond(bond: BondProfile) -> void:
	_bond_strength_value.text = str(int(bond.bond_strength))
	_sync_value.text = str(int(bond.sync))
	_instability_value.text = str(int(bond.instability))
	_trust_state_value.text = bond.trust_state


func _refresh_dragon_state(state: DragonState.State) -> void:
	_dragon_state_value.text = DragonState.state_display_name(state)

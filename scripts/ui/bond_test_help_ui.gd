extends Control
## On-screen help for bond test keys with live Bond / Sync / Instability readouts.


@onready var _bond_strength_value: Label = $Panel/Margin/VBox/Ctrl1Row/BondStrengthValue
@onready var _sync_value: Label = $Panel/Margin/VBox/Ctrl3Row/SyncValue
@onready var _instability_value: Label = $Panel/Margin/VBox/Ctrl5Row/InstabilityValue


func _ready() -> void:
	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)


func _on_bond_profile_changed(_unused = null) -> void:
	_refresh_bond(BondSystem.get_profile())


func _refresh_bond(bond: BondProfile) -> void:
	_bond_strength_value.text = str(int(bond.bond_strength))
	_sync_value.text = str(int(bond.sync))
	_instability_value.text = str(int(bond.instability))

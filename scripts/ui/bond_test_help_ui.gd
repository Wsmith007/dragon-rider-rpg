extends Control
## On-screen help for bond test keys with live Bond / Sync / Instability readouts.


@onready var _bond_strength_value: Label = $Panel/Margin/Scroll/VBox/Ctrl1Row/BondStrengthValue
@onready var _sync_value: Label = $Panel/Margin/Scroll/VBox/Ctrl3Row/SyncValue
@onready var _instability_value: Label = $Panel/Margin/Scroll/VBox/Ctrl5Row/InstabilityValue
@onready var _weapon_profile_value: Label = $Panel/Margin/Scroll/VBox/WeaponProfileRow/WeaponProfileValue
@onready var _weapon_profile_detail: Label = $Panel/Margin/Scroll/VBox/WeaponProfileDetail


func _ready() -> void:
	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_bind_weapon_profile()


func _refresh_weapon_profile(melee: Node) -> void:
	if melee.has_method("get_weapon_profile_summary"):
		_weapon_profile_value.text = melee.get_weapon_profile_summary()
	elif melee.has_method("get_weapon_profile_name"):
		_weapon_profile_value.text = melee.get_weapon_profile_name()
	if melee.has_method("get_weapon_profile_detail"):
		_weapon_profile_detail.text = melee.get_weapon_profile_detail()


func _bind_weapon_profile() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player := players[0] as Node
	var melee := player.get_node_or_null("MeleeAttack")
	if melee == null or not melee.has_signal("weapon_profile_changed"):
		return
	_refresh_weapon_profile(melee)
	melee.weapon_profile_changed.connect(_on_weapon_profile_changed)


func _on_bond_profile_changed(_unused = null) -> void:
	_refresh_bond(BondSystem.get_profile())


func _on_weapon_profile_changed(_summary: String) -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var melee := (players[0] as Node).get_node_or_null("MeleeAttack")
	if melee != null:
		_refresh_weapon_profile(melee)


func _refresh_bond(bond: BondProfile) -> void:
	_bond_strength_value.text = str(int(bond.bond_strength))
	_sync_value.text = str(int(bond.sync))
	_instability_value.text = str(int(bond.instability))

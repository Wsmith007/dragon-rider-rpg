extends Control
## On-screen help for bond test keys with live Bond / Sync / Instability readouts.


@onready var _bond_strength_value: Label = $Panel/Margin/Scroll/VBox/Ctrl1Row/BondStrengthValue
@onready var _sync_value: Label = $Panel/Margin/Scroll/VBox/Ctrl3Row/SyncValue
@onready var _instability_value: Label = $Panel/Margin/Scroll/VBox/Ctrl5Row/InstabilityValue
@onready var _weapon_profile_value: Label = $Panel/Margin/Scroll/VBox/WeaponProfileRow/WeaponProfileValue
@onready var _weapon_profile_detail: Label = $Panel/Margin/Scroll/VBox/WeaponProfileDetail
@onready var _movement_state_value: Label = $Panel/Margin/Scroll/VBox/MovementStateRow/MovementStateValue
@onready var _facing_value: Label = $Panel/Margin/Scroll/VBox/FacingRow/FacingValue
@onready var _stance_value: Label = $Panel/Margin/Scroll/VBox/StanceRow/StanceValue
@onready var _move_speed_value: Label = $Panel/Margin/Scroll/VBox/MoveSpeedRow/MoveSpeedValue
@onready var _target_focus_active_value: Label = $Panel/Margin/Scroll/VBox/TargetFocusActiveRow/TargetFocusActiveValue
@onready var _focused_target_value: Label = $Panel/Margin/Scroll/VBox/FocusedTargetRow/FocusedTargetValue

var _player: CharacterBody2D


func _ready() -> void:
	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_bind_player()


func _process(_delta: float) -> void:
	_refresh_movement_debug()


func _bind_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	_player = players[0] as CharacterBody2D
	if _player != null and _player.has_signal("movement_state_changed"):
		_player.movement_state_changed.connect(_on_movement_state_changed)
	var target_focus: PlayerTargetFocus = _player.get_node_or_null("TargetFocus") as PlayerTargetFocus
	if target_focus != null:
		target_focus.focus_changed.connect(_on_target_focus_changed)
	_bind_weapon_profile()
	_refresh_movement_debug()


func _refresh_weapon_profile(melee: Node) -> void:
	if melee.has_method("get_weapon_profile_summary"):
		_weapon_profile_value.text = melee.get_weapon_profile_summary()
	elif melee.has_method("get_weapon_profile_name"):
		_weapon_profile_value.text = melee.get_weapon_profile_name()
	if melee.has_method("get_weapon_profile_detail"):
		_weapon_profile_detail.text = melee.get_weapon_profile_detail()


func _bind_weapon_profile() -> void:
	if _player == null:
		return
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee == null or not melee.has_signal("weapon_profile_changed"):
		return
	_refresh_weapon_profile(melee)
	melee.weapon_profile_changed.connect(_on_weapon_profile_changed)


func _refresh_movement_debug() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	if _player.has_method("get_movement_state_label"):
		_movement_state_value.text = _player.get_movement_state_label()
	if _player.has_method("get_facing_label"):
		_facing_value.text = _player.get_facing_label()
	if _player.has_method("is_combat_stance_active"):
		_stance_value.text = "On" if _player.is_combat_stance_active() else "Off"
	if _player.has_method("get_total_move_speed_multiplier"):
		var total: float = _player.get_total_move_speed_multiplier()
		_move_speed_value.text = "×%.2f" % total
	if _player.has_method("is_target_focus_active"):
		_target_focus_active_value.text = "Yes" if _player.is_target_focus_active() else "No"
	if _player.has_method("get_target_focus_label"):
		_focused_target_value.text = _player.get_target_focus_label()


func _on_bond_profile_changed(_unused = null) -> void:
	_refresh_bond(BondSystem.get_profile())


func _on_weapon_profile_changed(_summary: String) -> void:
	if _player == null:
		return
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee != null:
		_refresh_weapon_profile(melee)
	_refresh_movement_debug()


func _on_movement_state_changed(_state_name: String) -> void:
	_refresh_movement_debug()


func _on_target_focus_changed(_active: bool, _target: Node2D) -> void:
	_refresh_movement_debug()


func _refresh_bond(bond: BondProfile) -> void:
	_bond_strength_value.text = str(int(bond.bond_strength))
	_sync_value.text = str(int(bond.sync))
	_instability_value.text = str(int(bond.instability))

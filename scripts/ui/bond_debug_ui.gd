extends Control
## Live debug readout for BondProfile and dragon state. Does not modify gameplay.

@onready var _bond_strength_value: Label = $Panel/Margin/VBox/Grid/BondStrengthValue
@onready var _sync_value: Label = $Panel/Margin/VBox/Grid/SyncValue
@onready var _instability_value: Label = $Panel/Margin/VBox/Grid/InstabilityValue
@onready var _protection_radius_value: Label = $Panel/Margin/VBox/Grid/ProtectionRadiusValue
@onready var _protection_delay_value: Label = $Panel/Margin/VBox/Grid/ProtectionDelayValue
@onready var _protection_persistence_value: Label = $Panel/Margin/VBox/Grid/ProtectionPersistenceValue
@onready var _pending_command_value: Label = $Panel/Margin/VBox/Grid/PendingCommandValue
@onready var _command_delay_value: Label = $Panel/Margin/VBox/Grid/CommandDelayValue
@onready var _dragon_state_value: Label = $Panel/Margin/VBox/Grid/DragonStateValue
@onready var _bond_tier_value: Label = $Panel/Margin/VBox/Grid/BondTierValue
@onready var _bond_tier_progress_value: Label = $Panel/Margin/VBox/Grid/BondTierProgressValue
@onready var _future_sync_floor_value: Label = $Panel/Margin/VBox/Grid/FutureSyncFloorValue
@onready var _future_instability_resistance_value: Label = $Panel/Margin/VBox/Grid/FutureInstabilityResistanceValue
@onready var _future_instability_recovery_value: Label = $Panel/Margin/VBox/Grid/FutureInstabilityRecoveryValue
@onready var _dragon_thought_value: Label = $Panel/Margin/VBox/Communication/DragonThoughtValue

var _dragon: CharacterBody2D
var _protection_behavior: DragonProtectionBehavior
var _command_behavior: DragonCommandBehavior
var _communication_behavior: DragonCommunicationBehavior


func bind_to_dragon(dragon: CharacterBody2D) -> void:
	_dragon = dragon
	if _dragon == null:
		push_warning("BondDebugUI: dragon reference is null.")
		return

	_protection_behavior = _dragon.get_node_or_null("ProtectionBehavior") as DragonProtectionBehavior
	_command_behavior = _dragon.get_node_or_null("CommandBehavior") as DragonCommandBehavior
	_communication_behavior = _dragon.get_node_or_null("CommunicationBehavior") as DragonCommunicationBehavior

	if _communication_behavior != null:
		if not _communication_behavior.message_changed.is_connected(_on_dragon_message_changed):
			_communication_behavior.message_changed.connect(_on_dragon_message_changed)
		_refresh_dragon_thought(_communication_behavior.get_message())

	if not _dragon.state_changed.is_connected(_on_dragon_state_changed):
		_dragon.state_changed.connect(_on_dragon_state_changed)

	_refresh_dragon_state(_dragon.state)
	_refresh_protection_stats(BondSystem.get_profile().bond_strength)
	_refresh_command_pending()


func _ready() -> void:
	var bond: BondProfile = BondSystem.get_profile()
	bond.profile_changed.connect(_on_bond_profile_changed)
	BondSystem.bond_changed.connect(_on_bond_profile_changed)
	_refresh_bond(bond)
	_refresh_dragon_state(DragonState.State.FOLLOWING)


func _process(_delta: float) -> void:
	_refresh_command_pending()


func _on_bond_profile_changed(_unused = null) -> void:
	_refresh_bond(BondSystem.get_profile())


func _on_dragon_state_changed(state: DragonState.State) -> void:
	_refresh_dragon_state(state)


func _on_dragon_message_changed(message: String) -> void:
	_refresh_dragon_thought(message)


func _refresh_bond(bond: BondProfile) -> void:
	_bond_strength_value.text = str(int(bond.bond_strength))
	_sync_value.text = str(int(bond.sync))
	_instability_value.text = str(int(bond.instability))
	_refresh_resilience_stats(bond.bond_strength)
	_refresh_protection_stats(bond.bond_strength)


func _refresh_resilience_stats(bond_strength: float) -> void:
	_bond_tier_value.text = BondResilience.get_bond_tier_label(bond_strength)
	_bond_tier_progress_value.text = str(snapped(BondResilience.get_bond_tier_progress(bond_strength), 0.01))
	_future_sync_floor_value.text = str(snapped(BondResilience.get_sync_floor(bond_strength), 0.1))
	var resistance_percent: int = int(round(BondResilience.get_instability_resistance(bond_strength) * 100.0))
	_future_instability_resistance_value.text = "%d%%" % resistance_percent
	_future_instability_recovery_value.text = "%.2fx" % BondResilience.get_instability_recovery_rate(bond_strength)


func _refresh_protection_stats(bond_strength: float) -> void:
	if _protection_behavior == null:
		_protection_radius_value.text = "-"
		_protection_delay_value.text = "-"
		_protection_persistence_value.text = "-"
		return

	_protection_radius_value.text = str(int(_protection_behavior.get_protection_radius(bond_strength)))
	_protection_delay_value.text = str(_protection_behavior.get_response_delay(bond_strength))
	_protection_persistence_value.text = str(_protection_behavior.get_persistence_duration(bond_strength))


func _refresh_command_pending() -> void:
	if _command_behavior == null:
		_pending_command_value.text = "-"
		_command_delay_value.text = "-"
		return

	_pending_command_value.text = _command_behavior.get_pending_command_label()
	var delay_remaining: float = _command_behavior.get_command_delay_remaining()
	if delay_remaining <= 0.0:
		_command_delay_value.text = "0"
	else:
		_command_delay_value.text = str(snapped(delay_remaining, 0.01))


func _refresh_dragon_state(state: DragonState.State) -> void:
	_dragon_state_value.text = DragonState.state_display_name(state)


func _refresh_dragon_thought(message: String) -> void:
	if message.is_empty():
		var fallback := DragonCommunicationCatalog.get_dragon_message(
			DragonCommunicationCatalog.Cue.FOLLOWING,
			BondSystem.get_profile().bond_strength
		)
		_dragon_thought_value.text = "\"%s\"" % fallback
	else:
		_dragon_thought_value.text = "\"%s\"" % message

extends Node
class_name DragonCommunicationBehavior
## Maps dragon activity to short player-facing feedback lines.


signal message_changed(message: String)


var _current_message: String = ""
var _current_cue: DragonCommunicationCatalog.Cue = DragonCommunicationCatalog.Cue.FOLLOWING
var _current_tier_index: int = -1
var _suppress_state_update_frame: int = -1


func _ready() -> void:
	call_deferred("_connect_signals")


func get_message() -> String:
	return _current_message


func _connect_signals() -> void:
	var dragon := get_parent()
	if dragon == null:
		return

	if dragon.has_signal("state_changed") and not dragon.state_changed.is_connected(_on_state_changed):
		dragon.state_changed.connect(_on_state_changed)

	var cooperation := dragon.get_node_or_null("CooperationBehavior") as DragonCooperationBehavior
	if cooperation != null:
		if not cooperation.hesitation_started.is_connected(_on_hesitation_started):
			cooperation.hesitation_started.connect(_on_hesitation_started)
		if not cooperation.cooperative_assist_canceled.is_connected(_on_cooperative_assist_canceled):
			cooperation.cooperative_assist_canceled.connect(_on_cooperative_assist_canceled)

	var bond := BondSystem.get_profile()
	if not bond.profile_changed.is_connected(_on_bond_profile_changed):
		bond.profile_changed.connect(_on_bond_profile_changed)

	if dragon.get("state") != null:
		_apply_cue(DragonCommunicationCatalog.cue_for_state(dragon.state))
	else:
		_apply_cue(DragonCommunicationCatalog.Cue.FOLLOWING)


func _on_state_changed(state: DragonState.State) -> void:
	if Engine.get_process_frames() == _suppress_state_update_frame:
		return
	_apply_cue(DragonCommunicationCatalog.cue_for_state(state))


func _on_hesitation_started() -> void:
	_apply_cue(DragonCommunicationCatalog.Cue.HESITATING)


func _on_cooperative_assist_canceled(_reason: String) -> void:
	_suppress_state_update_frame = Engine.get_process_frames()
	_apply_cue(DragonCommunicationCatalog.Cue.ASSIST_CANCELED)


func _on_bond_profile_changed() -> void:
	var tier_index := BondResilience.get_bond_tier(BondSystem.get_profile().bond_strength)
	if tier_index == _current_tier_index:
		return
	_current_tier_index = tier_index
	_publish_current_cue()


func _apply_cue(cue: DragonCommunicationCatalog.Cue) -> void:
	_current_cue = cue
	_current_tier_index = BondResilience.get_bond_tier(BondSystem.get_profile().bond_strength)
	_publish_current_cue()


func _publish_current_cue() -> void:
	var message := DragonCommunicationCatalog.get_dragon_message(
		_current_cue,
		BondSystem.get_profile().bond_strength
	)
	if message == _current_message:
		return
	_current_message = message
	message_changed.emit(message)

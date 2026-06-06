extends Node
class_name DragonCommandBehavior
## Player command layer: FOLLOW vs WAIT with bond-strength response delay.


enum PendingCommand { NONE, WAIT, RECALL }

signal command_mode_changed(is_waiting: bool)
signal wait_position_set(position: Vector2)
signal recalled


var is_waiting: bool = false
var wait_position: Vector2 = Vector2.ZERO

var _pending_command: PendingCommand = PendingCommand.NONE
var _command_delay_remaining: float = 0.0


func tick(delta: float, dragon_global_position: Vector2) -> void:
	if _pending_command == PendingCommand.NONE:
		return

	_command_delay_remaining = maxf(_command_delay_remaining - delta, 0.0)
	if _command_delay_remaining > 0.0:
		return

	var command := _pending_command
	_pending_command = PendingCommand.NONE
	_command_delay_remaining = 0.0
	_execute_command(command, dragon_global_position)


func request_toggle(dragon_global_position: Vector2) -> void:
	var requested := PendingCommand.RECALL if is_waiting else PendingCommand.WAIT
	var bond_strength: float = BondSystem.get_profile().bond_strength
	var delay: float = BondProfile.get_command_response_delay(bond_strength)
	var command_name := _pending_command_name(requested)

	print("BOND STRENGTH | ", int(bond_strength))
	print("COMMAND REQUESTED | ", command_name)
	print("COMMAND DELAY APPLIED | ", delay)

	if _pending_command == requested:
		_cancel_pending("toggle_cancel")
		return

	_pending_command = requested
	_command_delay_remaining = delay

	if delay <= 0.0:
		_pending_command = PendingCommand.NONE
		_command_delay_remaining = 0.0
		_execute_command(requested, dragon_global_position)


func has_pending_command() -> bool:
	return _pending_command != PendingCommand.NONE


func get_pending_command_label() -> String:
	return _pending_command_name(_pending_command)


func get_command_delay_remaining() -> float:
	if _pending_command == PendingCommand.NONE:
		return 0.0
	return _command_delay_remaining


func set_wait(position: Vector2) -> void:
	wait_position = position
	is_waiting = true
	wait_position_set.emit(wait_position)
	command_mode_changed.emit(true)


func recall() -> void:
	if not is_waiting:
		return
	is_waiting = false
	recalled.emit()
	command_mode_changed.emit(false)


func _execute_command(command: PendingCommand, dragon_global_position: Vector2) -> void:
	match command:
		PendingCommand.WAIT:
			print("COMMAND EXECUTED | WAIT")
			set_wait(dragon_global_position)
		PendingCommand.RECALL:
			print("COMMAND EXECUTED | RECALL")
			recall()


func _cancel_pending(reason: String) -> void:
	_pending_command = PendingCommand.NONE
	_command_delay_remaining = 0.0
	print("COMMAND PENDING CANCELED | reason=", reason)


func _pending_command_name(command: PendingCommand) -> String:
	match command:
		PendingCommand.WAIT:
			return "WAIT"
		PendingCommand.RECALL:
			return "RECALL"
		_:
			return "NONE"

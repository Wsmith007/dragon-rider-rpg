extends Node
class_name DragonCommandBehavior
## Player command layer: FOLLOW vs WAIT. Future trust/sync may delay or refuse toggles.


signal command_mode_changed(is_waiting: bool)
signal wait_position_set(position: Vector2)
signal recalled


var is_waiting: bool = false
var wait_position: Vector2 = Vector2.ZERO


func toggle_wait(dragon_global_position: Vector2) -> void:
	if is_waiting:
		recall()
	else:
		set_wait(dragon_global_position)


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

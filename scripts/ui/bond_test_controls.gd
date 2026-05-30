extends Node
## Temporary F1–F4 bond testers. Does not affect dragon behavior.

const ADJUST_STEP: float = 5.0


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_F1:
			BondSystem.adjust_sync(ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_F2:
			BondSystem.adjust_sync(-ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_F3:
			BondSystem.adjust_instability(ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_F4:
			BondSystem.adjust_instability(-ADJUST_STEP)
			get_viewport().set_input_as_handled()

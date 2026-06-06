extends Node
## Temporary Ctrl+1–6 bond stat testers (hold Ctrl).


const ADJUST_STEP: float = 5.0


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if not event.ctrl_pressed:
		return

	match event.keycode:
		KEY_1, KEY_KP_1:
			BondSystem.adjust_bond_strength(ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_2, KEY_KP_2:
			BondSystem.adjust_bond_strength(-ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_3, KEY_KP_3:
			BondSystem.adjust_sync(ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_4, KEY_KP_4:
			BondSystem.adjust_sync(-ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_5, KEY_KP_5:
			BondSystem.adjust_instability(ADJUST_STEP)
			get_viewport().set_input_as_handled()
		KEY_6, KEY_KP_6:
			BondSystem.adjust_instability(-ADJUST_STEP)
			get_viewport().set_input_as_handled()

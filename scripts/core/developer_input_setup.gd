extends RefCounted
class_name DeveloperInputSetup
## Registers developer Input Map actions using Godot Key constants (export-safe).


const InputActions := preload("res://scripts/core/developer_input_actions.gd")


static func register_playtest_actions() -> void:
	_set_action(InputActions.TOGGLE_DEVELOPER_MODE, [_key(KEY_F10)])
	_set_action(InputActions.COMBAT_RANGE_OVERLAY, [_key(KEY_F11)])
	_set_action(InputActions.DRAGON_NAVIGATION, [_key(KEY_F12)])
	_set_action(InputActions.WEAPON_DAGGER, [_key(KEY_1)])
	_set_action(InputActions.WEAPON_SWORD, [_key(KEY_2)])
	_set_action(InputActions.WEAPON_POLEARM, [_key(KEY_3)])
	_set_action(
		InputActions.BOND_STRENGTH_UP,
		[_key(KEY_1, false, true), _key(KEY_KP_1, false, true)]
	)
	_set_action(
		InputActions.BOND_STRENGTH_DOWN,
		[_key(KEY_2, false, true), _key(KEY_KP_2, false, true)]
	)
	_set_action(
		InputActions.BOND_SYNC_UP,
		[_key(KEY_3, false, true), _key(KEY_KP_3, false, true)]
	)
	_set_action(
		InputActions.BOND_SYNC_DOWN,
		[_key(KEY_4, false, true), _key(KEY_KP_4, false, true)]
	)
	_set_action(
		InputActions.BOND_INSTABILITY_UP,
		[_key(KEY_5, false, true), _key(KEY_KP_5, false, true)]
	)
	_set_action(
		InputActions.BOND_INSTABILITY_DOWN,
		[_key(KEY_6, false, true), _key(KEY_KP_6, false, true)]
	)
	_set_action(InputActions.HEALTH_HEAL, [_key(KEY_F5)])
	_set_action(InputActions.HEALTH_MAX_UP, [_key(KEY_F6)])
	_set_action(InputActions.HEALTH_MAX_DOWN, [_key(KEY_F7)])
	_set_action(InputActions.SPAWN_ENEMY, [_key(KEY_F1)])
	_set_action(InputActions.SPAWN_ENEMY_PACK, [_key(KEY_F1, true, false)])
	_set_action(InputActions.RESTART_SLICE, [_key(KEY_R, true, false)])
	_set_action(InputActions.RELOAD_GAMEPLAY, [_key(KEY_R, true, true)])


static func _key(
	key: Key,
	shift_pressed: bool = false,
	ctrl_pressed: bool = false
) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.shift_pressed = shift_pressed
	event.ctrl_pressed = ctrl_pressed
	return event


static func _set_action(action: StringName, events: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)

	for existing in InputMap.action_get_events(action):
		InputMap.action_erase_event(action, existing)

	for event in events:
		if event is InputEventKey:
			InputMap.action_add_event(action, event)

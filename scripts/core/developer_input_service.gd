extends Node
## Autoload: polls developer Input Map actions via the global Input singleton.


const InputActions := preload("res://scripts/core/developer_input_actions.gd")
const WeaponProfiles := preload("res://scripts/combat/weapon_profile_prototype.gd")
const InputSetup := preload("res://scripts/core/developer_input_setup.gd")
const SETTING_DEVELOPER_TOOLS := "gameplay/developer_tools_enabled"
const BOND_ADJUST_STEP: float = 5.0
const TOGGLE_COOLDOWN_MS: int = 280

var _shell: Node = null
var _gameplay: GameplayBindings = null
var _reload_gameplay_enabled: bool = false
var _toggle_blocked_until_ms: int = 0
var _actions_registered: bool = false


class GameplayBindings:
	var telegraph: Node = null
	var dragon: Node = null
	var melee_attack: Node = null
	var health_debug: Node = null
	var spawn_debug: Node = null
	var slice_level: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ensure_actions_registered()


func ensure_actions_registered() -> void:
	if _actions_registered:
		return
	InputSetup.register_playtest_actions()
	_actions_registered = true


func bind_shell(shell: Node) -> void:
	_shell = shell


func bind_gameplay(bindings: GameplayBindings) -> void:
	_gameplay = bindings


func clear_gameplay_bindings() -> void:
	_gameplay = null


func set_reload_gameplay_enabled(enabled: bool) -> void:
	_reload_gameplay_enabled = enabled


func _process(_delta: float) -> void:
	if not _are_developer_tools_enabled():
		return

	_poll_shell_actions()
	_poll_gameplay_actions()


func _poll_shell_actions() -> void:
	if _shell == null:
		return

	var now_ms := Time.get_ticks_msec()
	if (
		now_ms >= _toggle_blocked_until_ms
		and Input.is_action_just_pressed(InputActions.TOGGLE_DEVELOPER_MODE)
	):
		_toggle_blocked_until_ms = now_ms + TOGGLE_COOLDOWN_MS
		if _shell.has_method("toggle_developer_mode"):
			_shell.toggle_developer_mode()

	if _reload_gameplay_enabled and Input.is_action_just_pressed(InputActions.RELOAD_GAMEPLAY):
		if _shell.has_method("reload_gameplay_from_debug"):
			_shell.reload_gameplay_from_debug()


func _poll_gameplay_actions() -> void:
	if _gameplay == null:
		return

	if _gameplay.telegraph != null and Input.is_action_just_pressed(InputActions.COMBAT_RANGE_OVERLAY):
		if _gameplay.telegraph.has_method("toggle_debug_ranges"):
			_gameplay.telegraph.toggle_debug_ranges()

	if _gameplay.dragon != null and Input.is_action_just_pressed(InputActions.DRAGON_NAVIGATION):
		if _gameplay.dragon.has_method("toggle_navigation_debug"):
			_gameplay.dragon.toggle_navigation_debug()

	if _gameplay.melee_attack != null:
		if Input.is_action_just_pressed(InputActions.WEAPON_DAGGER):
			_try_set_weapon_profile(WeaponProfiles.Id.DAGGER)
		elif Input.is_action_just_pressed(InputActions.WEAPON_SWORD):
			_try_set_weapon_profile(WeaponProfiles.Id.SWORD)
		elif Input.is_action_just_pressed(InputActions.WEAPON_POLEARM):
			_try_set_weapon_profile(WeaponProfiles.Id.POLEARM)

	if Input.is_action_just_pressed(InputActions.BOND_STRENGTH_UP):
		BondSystem.adjust_bond_strength(BOND_ADJUST_STEP)
	elif Input.is_action_just_pressed(InputActions.BOND_STRENGTH_DOWN):
		BondSystem.adjust_bond_strength(-BOND_ADJUST_STEP)
	elif Input.is_action_just_pressed(InputActions.BOND_SYNC_UP):
		BondSystem.adjust_sync(BOND_ADJUST_STEP)
	elif Input.is_action_just_pressed(InputActions.BOND_SYNC_DOWN):
		BondSystem.adjust_sync(-BOND_ADJUST_STEP)
	elif Input.is_action_just_pressed(InputActions.BOND_INSTABILITY_UP):
		BondSystem.adjust_instability(BOND_ADJUST_STEP)
	elif Input.is_action_just_pressed(InputActions.BOND_INSTABILITY_DOWN):
		BondSystem.adjust_instability(-BOND_ADJUST_STEP)

	if _gameplay.health_debug != null:
		if Input.is_action_just_pressed(InputActions.HEALTH_HEAL):
			if _gameplay.health_debug.has_method("apply_heal_step"):
				_gameplay.health_debug.apply_heal_step()
		elif Input.is_action_just_pressed(InputActions.HEALTH_MAX_UP):
			if _gameplay.health_debug.has_method("apply_max_health_up"):
				_gameplay.health_debug.apply_max_health_up()
		elif Input.is_action_just_pressed(InputActions.HEALTH_MAX_DOWN):
			if _gameplay.health_debug.has_method("apply_max_health_down"):
				_gameplay.health_debug.apply_max_health_down()
		# Shift variants first with exact_match so they do not also fire the unshifted action.
		elif Input.is_action_just_pressed(InputActions.DRAGON_HEAL, true):
			if _gameplay.health_debug.has_method("apply_dragon_heal_step"):
				_gameplay.health_debug.apply_dragon_heal_step()
		elif Input.is_action_just_pressed(InputActions.DRAGON_DAMAGE, true):
			if _gameplay.health_debug.has_method("apply_dragon_damage_step"):
				_gameplay.health_debug.apply_dragon_damage_step()
		elif Input.is_action_just_pressed(InputActions.DRAGON_FORCE_REVIVE, true):
			if _gameplay.health_debug.has_method("force_dragon_revive"):
				_gameplay.health_debug.force_dragon_revive()
		elif Input.is_action_just_pressed(InputActions.DRAGON_FORCE_KO, true):
			if _gameplay.health_debug.has_method("force_dragon_knockout"):
				_gameplay.health_debug.force_dragon_knockout()

	if _gameplay.spawn_debug != null:
		# Pack first + exact_match so Shift+F1 does not also fire the single-spawn action.
		if Input.is_action_just_pressed(InputActions.SPAWN_ENEMY_PACK, true):
			if _gameplay.spawn_debug.has_method("spawn_random_pack"):
				_gameplay.spawn_debug.spawn_random_pack()
		elif Input.is_action_just_pressed(InputActions.SPAWN_ENEMY, true):
			if _gameplay.spawn_debug.has_method("spawn_random_enemy"):
				_gameplay.spawn_debug.spawn_random_enemy()

	if (
		_gameplay.slice_level != null
		and Input.is_action_just_pressed(InputActions.RESTART_SLICE)
	):
		if _gameplay.slice_level.has_method("restart_slice"):
			_gameplay.slice_level.restart_slice()


func _try_set_weapon_profile(profile_id: WeaponProfiles.Id) -> void:
	if _gameplay == null or _gameplay.melee_attack == null:
		return
	if _gameplay.melee_attack.has_method("try_set_weapon_profile_from_debug"):
		_gameplay.melee_attack.try_set_weapon_profile_from_debug(profile_id)


func _are_developer_tools_enabled() -> bool:
	var value = ProjectSettings.get_setting(SETTING_DEVELOPER_TOOLS, null)
	if value != null:
		return bool(value)
	return OS.has_feature("editor")

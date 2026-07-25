extends Node
class_name PlayerCombatAnimation
## Minimal idle / walk / attack presentation synced to live MeleeAttack timings.
## Presentation only — does not alter hit frames, damage, or movement authority.


const _WeaponVisualStyle := preload("res://scripts/player/player_weapon_visual_style.gd")
const STRIKE_SNAP_DURATION := 0.04


@export var visual_pivot_path: NodePath = ^"../VisualPivot"
@export var spin_layer_path: NodePath = ^"../VisualPivot/SpinLayer"
@export var body_visual_path: NodePath = ^"../VisualPivot/SpinLayer/Visual"
@export var weapon_pivot_path: NodePath = ^"../VisualPivot/SpinLayer/WeaponPivot"
@export var weapon_blade_path: NodePath = ^"../VisualPivot/SpinLayer/WeaponPivot/WeaponBlade"
@export var melee_attack_path: NodePath = ^"../MeleeAttack"

var _player: CharacterBody2D
var _visual_pivot: Node2D
var _spin_layer: Node2D
var _body_visual: Polygon2D
var _weapon_pivot: Node2D
var _weapon_blade: Polygon2D
var _melee: Node2D

var _style: Dictionary = {}
var _walk_phase: float = 0.0
var _idle_phase: float = 0.0
var _attack_active: bool = false
var _attack_tween: Tween
var _base_body_scale := Vector2.ONE
var _base_blade_scale := Vector2.ONE
var _focused_swing_from_left := true


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	_visual_pivot = get_node_or_null(visual_pivot_path) as Node2D
	_spin_layer = get_node_or_null(spin_layer_path) as Node2D
	_body_visual = get_node_or_null(body_visual_path) as Polygon2D
	_weapon_pivot = get_node_or_null(weapon_pivot_path) as Node2D
	_weapon_blade = get_node_or_null(weapon_blade_path) as Polygon2D
	_melee = get_node_or_null(melee_attack_path) as Node2D

	if _body_visual != null:
		_base_body_scale = _body_visual.scale
	if _weapon_blade != null:
		_weapon_blade.z_index = 2
		_base_blade_scale = _weapon_blade.scale

	call_deferred("_bind_signals")
	call_deferred("_apply_weapon_style")


func _bind_signals() -> void:
	if _melee == null:
		return
	if _melee.has_signal("attack_swing_started") and not _melee.attack_swing_started.is_connected(_on_attack_swing_started):
		_melee.attack_swing_started.connect(_on_attack_swing_started)
	if _melee.has_signal("attack_swing_finished") and not _melee.attack_swing_finished.is_connected(_on_attack_swing_finished):
		_melee.attack_swing_finished.connect(_on_attack_swing_finished)
	if _melee.has_signal("weapon_profile_changed") and not _melee.weapon_profile_changed.is_connected(_on_weapon_profile_changed):
		_melee.weapon_profile_changed.connect(_on_weapon_profile_changed)
	if _player != null and _player.has_signal("movement_state_changed"):
		if not _player.movement_state_changed.is_connected(_on_movement_state_changed):
			_player.movement_state_changed.connect(_on_movement_state_changed)


func _process(delta: float) -> void:
	if _attack_active or _visual_pivot == null:
		return
	if _player == null:
		return

	_idle_phase += delta

	if _player.get_movement_state() == _player.MovementState.STAGGERED:
		_visual_pivot.position = Vector2.ZERO
		_apply_rest_pose()
		return

	var speed := _player.velocity.length()
	if speed > 16.0 and _player.get_movement_state() != _player.MovementState.ATTACKING:
		_apply_walk_motion(delta, speed)
	else:
		_apply_idle_motion()

	_apply_rest_pose()


func _apply_idle_motion() -> void:
	var breathe_speed := float(_style.get("idle_breathe", 0.45))
	var bob := sin(_idle_phase * 2.4) * breathe_speed
	_visual_pivot.position = Vector2(0.0, bob)


func _apply_walk_motion(delta: float, speed: float) -> void:
	var cycle_speed := float(_style.get("walk_cycle_speed", 7.5))
	var speed_factor := clampf(speed / 220.0, 0.65, 1.35)
	_walk_phase += delta * cycle_speed * speed_factor

	var bob_amount := float(_style.get("walk_bob", 1.5))
	var sway_amount := float(_style.get("walk_sway", 0.6))
	var bob := sin(_walk_phase) * bob_amount
	var sway := cos(_walk_phase * 0.5) * sway_amount
	_visual_pivot.position = Vector2(sway, bob)


func _get_weapon_profile_id() -> WeaponProfilePrototype.Id:
	if _melee == null:
		return WeaponProfilePrototype.Id.DAGGER
	return _melee.weapon_profile as WeaponProfilePrototype.Id


func _apply_weapon_style() -> void:
	if _melee == null or _weapon_blade == null:
		return

	var profile_id := _get_weapon_profile_id()
	_style = _WeaponVisualStyle.get_style(profile_id)
	_weapon_blade.visible = true
	_weapon_blade.modulate = Color.WHITE
	_weapon_blade.polygon = _style.get("blade_polygon", PackedVector2Array())
	_weapon_blade.color = _style.get("blade_color", Color.WHITE)
	_weapon_blade.scale = _style.get("blade_scale", Vector2.ONE)
	if _weapon_pivot != null:
		_weapon_pivot.visible = true
	_reset_attack_pose()


func _on_weapon_profile_changed(_summary: String) -> void:
	_apply_weapon_style()


func _on_movement_state_changed(_state_name: String) -> void:
	if _player.get_movement_state() == _player.MovementState.STAGGERED:
		_reset_attack_pose()


func _on_attack_swing_started(is_crowd_control: bool) -> void:
	_attack_active = true
	_cancel_attack_tween()
	if is_crowd_control:
		await _play_crowd_control_animation()
	else:
		await _play_focused_animation()
	if is_instance_valid(self):
		_attack_active = false
		_reset_attack_pose()


func _on_attack_swing_finished(_is_crowd_control: bool, _did_hit: bool) -> void:
	_attack_active = false
	_reset_attack_pose()


func _play_focused_animation() -> void:
	if _melee == null:
		return

	var windup: float = _melee.focused_windup
	var recovery: float = _melee.focused_recovery
	var bring_ratio := float(_style.get("focused_bring_forward_ratio", 0.32))
	var windup_mag := absf(float(_style.get("focused_windup_deg", -38.0)))
	var strike_mag := absf(float(_style.get("focused_strike_deg", 52.0)))
	var body_lean := float(_style.get("focused_body_lean", 0.12))

	var windup_deg := -windup_mag if _focused_swing_from_left else windup_mag
	var strike_deg := strike_mag if _focused_swing_from_left else -strike_mag
	_focused_swing_from_left = not _focused_swing_from_left

	var rest := _rest_pose()
	var front := _front_pose()

	# 1. Rest (right-side anchor, forward)
	_apply_pose(rest["offset"], rest["angle_deg"], body_lean * 0.2)

	# 2. Bring weapon to center/front
	var bring_time := windup * bring_ratio
	_attack_tween = _tween_pose(rest, front, bring_time, Tween.EASE_OUT, body_lean * 0.45)
	await _attack_tween.finished

	# 3. Windup to one side of arc
	var windup_pose := front.duplicate()
	windup_pose["angle_deg"] = front["angle_deg"] + windup_deg
	var windup_time := maxf(windup - bring_time, 0.001)
	_attack_tween = _tween_pose(front, windup_pose, windup_time, Tween.EASE_OUT, body_lean)
	await _attack_tween.finished

	# 4. Strike sweep to opposite side
	var strike_pose := front.duplicate()
	strike_pose["angle_deg"] = front["angle_deg"] + strike_deg
	_attack_tween = _tween_pose(windup_pose, strike_pose, STRIKE_SNAP_DURATION, Tween.EASE_OUT, body_lean)
	await _attack_tween.finished

	# 5. Recovery: strike -> front -> rest
	var recovery_to_front := recovery * 0.38
	_attack_tween = _tween_pose(strike_pose, front, recovery_to_front, Tween.EASE_IN, body_lean * 0.55)
	await _attack_tween.finished

	var recovery_to_rest := recovery - recovery_to_front
	_attack_tween = _tween_pose(front, rest, recovery_to_rest, Tween.EASE_IN_OUT, body_lean * 0.25)
	await _attack_tween.finished


func _play_crowd_control_animation() -> void:
	if _melee == null:
		return

	var windup: float = _melee.crowd_control_windup
	var impact: float = _melee.crowd_control_impact_duration
	var recovery: float = _melee.crowd_control_recovery
	var body_lean := float(_style.get("cc_body_lean", 0.14))

	var rest := _rest_pose()
	var front := _front_pose()

	_set_spin_rotation(0.0)
	_apply_pose(rest["offset"], rest["angle_deg"], body_lean * 0.2)

	# Pull weapon forward before spin
	var prep_time := windup * 0.25
	_attack_tween = _tween_pose(rest, front, prep_time, Tween.EASE_OUT, body_lean * 0.35)
	await _attack_tween.finished

	# Full 360 spin on SpinLayer — weapon stays forward relative to spinning body
	_apply_pose(front["offset"], front["angle_deg"], body_lean)
	var spin_time := maxf(windup - prep_time, 0.001) + impact
	_attack_tween = _tween_spin(0.0, TAU, spin_time, Tween.EASE_IN_OUT)
	await _attack_tween.finished
	_set_spin_rotation(0.0)

	# Recovery to rest while spin layer is reset
	_apply_pose(front["offset"], front["angle_deg"], body_lean * 0.35)
	_attack_tween = _tween_pose(front, rest, recovery, Tween.EASE_IN_OUT, body_lean * 0.2)
	await _attack_tween.finished


func _rest_pose() -> Dictionary:
	return {
		"offset": _style.get("rest_offset", Vector2(13.0, 11.0)),
		"angle_deg": float(_style.get("rest_angle_deg", 52.0)),
	}


func _front_pose() -> Dictionary:
	return {
		"offset": _style.get("front_offset", Vector2(0.0, -11.0)),
		"angle_deg": float(_style.get("front_angle_deg", 0.0)),
	}


func _apply_rest_pose() -> void:
	var rest := _rest_pose()
	_apply_pose(rest["offset"], rest["angle_deg"], 0.0)


func _apply_pose(offset: Vector2, angle_deg: float, body_lean: float) -> void:
	if _weapon_pivot != null:
		_weapon_pivot.position = offset
		_weapon_pivot.rotation = deg_to_rad(angle_deg)
	if _body_visual != null:
		var lean_amount := body_lean * clampf(absf(angle_deg) / 70.0, 0.0, 1.0)
		_body_visual.scale = Vector2(
			_base_body_scale.x * (1.0 + lean_amount * 0.3),
			_base_body_scale.y * (1.0 - lean_amount * 0.1)
		)


func _tween_pose(
	from_pose: Dictionary,
	to_pose: Dictionary,
	duration: float,
	ease_type: Tween.EaseType,
	body_lean: float
) -> Tween:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(ease_type)
	tween.tween_method(
		func(t: float) -> void:
			var offset: Vector2 = from_pose["offset"].lerp(to_pose["offset"], t)
			var angle_deg: float = lerpf(from_pose["angle_deg"], to_pose["angle_deg"], t)
			_apply_pose(offset, angle_deg, body_lean),
		0.0,
		1.0,
		duration
	)
	return tween


func _tween_spin(from_rad: float, to_rad: float, duration: float, ease_type: Tween.EaseType) -> Tween:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(ease_type)
	tween.tween_method(
		func(t: float) -> void:
			_set_spin_rotation(lerpf(from_rad, to_rad, t)),
		0.0,
		1.0,
		duration
	)
	return tween


func _set_spin_rotation(angle_rad: float) -> void:
	if _spin_layer != null:
		_spin_layer.rotation = angle_rad


func _reset_attack_pose() -> void:
	_cancel_attack_tween()
	_set_spin_rotation(0.0)
	if _weapon_blade != null:
		_weapon_blade.scale = _style.get("blade_scale", _base_blade_scale)
	if _body_visual != null:
		_body_visual.scale = _base_body_scale
	_apply_rest_pose()


func _cancel_attack_tween() -> void:
	if _attack_tween != null and _attack_tween.is_valid():
		_attack_tween.kill()
	_attack_tween = null

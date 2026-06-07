extends Node
class_name DragonStrikeBehavior
## Shared strike lifecycle for defensive protection and cooperative assist.
## ASSIST is temporary: timeouts, stuck detection, and cancel_assist() always end it.


signal strike_started(enemy: Node2D, kind: StrikeKind)
signal strike_hit(enemy: Node2D, kind: StrikeKind)
signal strike_finished(kind: StrikeKind)


enum StrikeKind { PROTECTION, ASSIST }
enum Phase { IDLE, APPROACH, LUNGE, RETURN }


@export var strike_damage: float = 22.0
@export var strike_range: float = 130.0
@export var protection_cooldown: float = 4.5
@export var assist_cooldown: float = 2.75
@export var lunge_speed: float = 340.0
@export var hit_distance: float = 30.0
@export var return_speed: float = 220.0
@export var return_arrive_distance: float = 18.0
@export var approach_speed: float = 280.0
@export var approach_arrive_distance: float = 22.0
@export var approach_timeout: float = 1.0
@export var flank_offset: float = 38.0
@export var player_clearance: float = 28.0
@export var wait_protection_radius: float = 72.0

@export_group("Assist Failsafe")
@export var max_assist_duration: float = 1.35
@export var max_protection_duration: float = 2.5
@export var stuck_move_threshold: float = 4.0
@export var stuck_time_threshold: float = 0.4
@export var rider_block_radius: float = 32.0
@export var rider_avoid_strength: float = 1.15

@export_group("Sync Assist Cooldown")
@export var sync_cooldown_enabled: bool = true
@export var sync_low_max: float = 35.0
@export var sync_mid_max: float = 85.0
@export var sync_low_cooldown: float = 6.5
@export var sync_mid_cooldown: float = 4.0
@export var sync_high_cooldown: float = 1.5
@export var assist_cooldown_min: float = 0.75
@export var assist_cooldown_max: float = 7.5

var _assist_cooldown_remaining: float = 0.0
var _protection_cooldown_remaining: float = 0.0
var _phase: Phase = Phase.IDLE
var _kind: StrikeKind = StrikeKind.PROTECTION
var _active_strike_kind: StrikeKind = StrikeKind.PROTECTION
var _target: Node2D
var _return_point: Vector2 = Vector2.ZERO
var _return_label: String = "PLAYER"
var _approach_point: Vector2 = Vector2.ZERO
var _rider_position: Vector2 = Vector2.ZERO
var _approach_time_remaining: float = 0.0
var _strike_time_remaining: float = 0.0
var _hit_applied: bool = false
var _last_wait_protection_target_id: int = -1
var _last_delta: float = 0.0
var _stuck_sample_position: Vector2 = Vector2.ZERO
var _stuck_timer: float = 0.0


func _ready() -> void:
	_assist_cooldown_remaining = get_effective_assist_cooldown() * 0.5


func update_cooldown(delta: float) -> void:
	_last_delta = delta
	_assist_cooldown_remaining = maxf(_assist_cooldown_remaining - delta, 0.0)
	_protection_cooldown_remaining = maxf(_protection_cooldown_remaining - delta, 0.0)


func update_strike(delta: float, dragon_position: Vector2, rider_position: Vector2) -> void:
	if _phase == Phase.IDLE:
		return

	_rider_position = rider_position
	_strike_time_remaining -= delta
	if _strike_time_remaining <= 0.0:
		_cancel_strike("max_duration")
		return

	if _phase == Phase.APPROACH or _phase == Phase.LUNGE:
		_update_stuck_detection(delta, dragon_position)
		_validate_active_target(dragon_position)


func get_strike_kind() -> StrikeKind:
	return _kind


func is_busy() -> bool:
	return _phase != Phase.IDLE


func is_returning() -> bool:
	return _phase == Phase.RETURN


func is_on_assist_cooldown() -> bool:
	return _assist_cooldown_remaining > 0.0


func can_begin_protection() -> bool:
	return not is_busy() and _protection_cooldown_remaining <= 0.0


func can_begin_assist() -> bool:
	return not is_busy() and not is_on_assist_cooldown()


func get_target() -> Node2D:
	if EnemyValidation.is_usable(_target):
		return _target
	return null


func clear_enemy_reference(enemy) -> void:
	var enemy_id: int = EnemyValidation.resolve_instance_id(enemy)
	if enemy_id == -1:
		return
	if _target == null or not is_instance_valid(_target):
		_target = null
		return
	if _target.get_instance_id() != enemy_id:
		return
	if _phase == Phase.LUNGE and _hit_applied:
		return
	if _phase != Phase.IDLE:
		_cancel_strike("target_died")
	else:
		_clear_target("target_died")


func get_return_point() -> Vector2:
	return _return_point


func find_wait_protection_target(
	dragon_position: Vector2,
	exclude_instance_id: int = -1
) -> Node2D:
	return _find_nearest_enemy(dragon_position, wait_protection_radius, exclude_instance_id)


func is_target_within_strike_range(enemy: Node2D) -> bool:
	return _is_target_within_strike_range(enemy)


func get_wait_protection_exclude_id() -> int:
	return _last_wait_protection_target_id


func clear_wait_protection_block_if_target_gone(origin: Vector2) -> void:
	if _last_wait_protection_target_id == -1:
		return

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		if node.get_instance_id() != _last_wait_protection_target_id:
			continue
		if not EnemyValidation.is_usable(node):
			_last_wait_protection_target_id = -1
			return
		if origin.distance_to((node as Node2D).global_position) <= wait_protection_radius:
			return

	_last_wait_protection_target_id = -1


func try_begin_protection(
	enemy: Node2D,
	return_point: Vector2,
	rider_position: Vector2,
	return_label: String = "PLAYER"
) -> bool:
	if not can_begin_protection():
		return false
	return _try_begin_strike(StrikeKind.PROTECTION, enemy, return_point, rider_position, return_label)


func try_begin_wait_protection(enemy: Node2D, return_point: Vector2, rider_position: Vector2) -> bool:
	if not try_begin_protection(enemy, return_point, rider_position, "WAIT_POSITION"):
		return false
	_last_wait_protection_target_id = enemy.get_instance_id()
	return true


func try_begin_assist(enemy: Node2D, return_point: Vector2, rider_position: Vector2) -> bool:
	if not can_begin_assist():
		return false
	return _try_begin_strike(StrikeKind.ASSIST, enemy, return_point, rider_position, "PLAYER")


func get_movement_velocity(dragon_position: Vector2) -> Vector2:
	match _phase:
		Phase.APPROACH:
			return _get_approach_velocity(dragon_position)
		Phase.LUNGE:
			return _get_lunge_velocity(dragon_position)
		Phase.RETURN:
			return _get_return_velocity(dragon_position)
		_:
			return Vector2.ZERO


## Cooperative assist only — clears target, timers, and movement; dragon.gd resolves follow/alert/wait.
func cancel_assist(reason: String) -> void:
	if _kind != StrikeKind.ASSIST or _phase == Phase.IDLE:
		return
	cancel_strike(true, reason)


func cancel_strike(emit_finished_signal: bool = true, reason: String = "cancel") -> void:
	if _phase == Phase.IDLE:
		return

	var finished_kind := _kind
	print("CANCEL STRIKE | reason=", reason, " | kind=", finished_kind)
	_reset_strike_state()
	if emit_finished_signal:
		strike_finished.emit(finished_kind)


func get_effective_assist_cooldown() -> float:
	var cooldown := assist_cooldown
	if sync_cooldown_enabled:
		var sync_value := BondSystem.get_profile().sync
		if sync_value <= sync_low_max:
			cooldown = sync_low_cooldown
		elif sync_value <= sync_mid_max:
			cooldown = sync_mid_cooldown
		else:
			cooldown = sync_high_cooldown
	return clampf(cooldown, assist_cooldown_min, assist_cooldown_max)


func _try_begin_strike(
	kind: StrikeKind,
	enemy: Node2D,
	return_point: Vector2,
	rider_position: Vector2,
	return_label: String
) -> bool:
	if not EnemyValidation.is_usable(enemy):
		return false
	if is_busy():
		return false
	if not _is_target_within_strike_range(enemy):
		return false

	var dragon := get_parent() as Node2D
	if dragon == null:
		return false

	_kind = kind
	_active_strike_kind = kind
	_target = enemy
	_return_point = return_point
	_return_label = return_label
	_rider_position = rider_position
	_hit_applied = false

	var dragon_position := dragon.global_position
	_approach_point = DragonCombatApproach.compute_approach_point(
		dragon_position,
		enemy.global_position,
		rider_position,
		flank_offset,
		player_clearance
	)
	_approach_time_remaining = minf(approach_timeout, _get_max_duration_for_kind())
	_begin_strike_tracking(dragon_position)

	if _should_approach_first(dragon_position):
		_phase = Phase.APPROACH
	else:
		_phase = Phase.LUNGE

	if kind == StrikeKind.PROTECTION:
		_protection_cooldown_remaining = protection_cooldown
	else:
		_assist_cooldown_remaining = get_effective_assist_cooldown()

	var kind_name := "PROTECTION" if kind == StrikeKind.PROTECTION else "ASSIST"
	print("ENTER ", kind_name, " | target=", enemy.name, " | RETURN TARGET=", _return_label)
	strike_started.emit(enemy, kind)
	return true


func _begin_strike_tracking(dragon_position: Vector2) -> void:
	_strike_time_remaining = _get_max_duration_for_kind()
	_stuck_sample_position = dragon_position
	_stuck_timer = 0.0


func _get_max_duration_for_kind() -> float:
	if _kind == StrikeKind.ASSIST:
		return max_assist_duration
	return max_protection_duration


func _update_stuck_detection(delta: float, dragon_position: Vector2) -> void:
	var moved := dragon_position.distance_to(_stuck_sample_position)
	if moved < stuck_move_threshold:
		_stuck_timer += delta
		if _stuck_timer >= stuck_time_threshold:
			_cancel_strike("stuck")
			return
	else:
		_stuck_timer = 0.0
		_stuck_sample_position = dragon_position


func _validate_active_target(_dragon_position: Vector2) -> void:
	if not EnemyValidation.is_usable(_target):
		if _phase == Phase.LUNGE or _phase == Phase.APPROACH:
			_start_return("invalid_target")
		else:
			_cancel_strike("invalid_target")
		return

	if not _is_target_within_strike_range(_target):
		_cancel_strike("target_out_of_range")


func _is_target_within_strike_range(enemy: Node2D) -> bool:
	var dragon := get_parent() as Node2D
	if dragon == null:
		return false
	return dragon.global_position.distance_to(enemy.global_position) <= strike_range


func _should_approach_first(dragon_position: Vector2) -> bool:
	if not EnemyValidation.is_usable(_target):
		return false
	if DragonCombatApproach.segment_passes_near_point(
		dragon_position,
		_target.global_position,
		_rider_position,
		player_clearance
	):
		return true
	return dragon_position.distance_to(_approach_point) > approach_arrive_distance


func _get_approach_velocity(dragon_position: Vector2) -> Vector2:
	_approach_time_remaining -= _last_delta
	if _approach_time_remaining <= 0.0:
		_cancel_strike("approach_timeout")
		return Vector2.ZERO

	if not EnemyValidation.is_usable(_target):
		_cancel_strike("invalid_approach_target")
		return Vector2.ZERO

	_approach_point = DragonCombatApproach.compute_approach_point(
		dragon_position,
		_target.global_position,
		_rider_position,
		flank_offset,
		player_clearance
	)

	var offset := _approach_point - dragon_position
	if offset.length() <= approach_arrive_distance:
		_phase = Phase.LUNGE
		return _get_lunge_velocity(dragon_position)

	var desired := offset.normalized() * approach_speed
	return _apply_rider_avoidance(desired, dragon_position)


func _get_lunge_velocity(dragon_position: Vector2) -> Vector2:
	if not EnemyValidation.is_usable(_target):
		_clear_target("invalid_lunge_target")
		_start_return("invalid_lunge_target")
		return _get_return_velocity(dragon_position)

	var offset := _target.global_position - dragon_position
	if offset.length() <= hit_distance:
		if not _hit_applied:
			_hit_applied = true
			_apply_damage()
		_clear_target("hit")
		_start_return("hit")
		return _get_return_velocity(dragon_position)

	var desired := offset.normalized() * lunge_speed
	return _apply_rider_avoidance(desired, dragon_position)


func _apply_rider_avoidance(desired_velocity: Vector2, dragon_position: Vector2) -> Vector2:
	var rider_offset := dragon_position - _rider_position
	var distance_to_rider := rider_offset.length()
	if distance_to_rider > rider_block_radius:
		return desired_velocity

	if distance_to_rider < 0.001:
		rider_offset = Vector2.RIGHT
	else:
		rider_offset = rider_offset.normalized()

	var perpendicular := Vector2(-rider_offset.y, rider_offset.x)
	if perpendicular.dot(desired_velocity) < 0.0:
		perpendicular = -perpendicular

	var blended := desired_velocity.normalized() + perpendicular * rider_avoid_strength
	if blended.length_squared() < 0.001:
		return perpendicular * lunge_speed
	return blended.normalized() * desired_velocity.length()


func _get_return_velocity(dragon_position: Vector2) -> Vector2:
	var offset := _return_point - dragon_position
	if offset.length() <= return_arrive_distance:
		_finish_strike()
		return Vector2.ZERO
	return offset.normalized() * return_speed


func _cancel_strike(reason: String) -> void:
	cancel_strike(true, reason)


func _apply_damage() -> void:
	if not EnemyValidation.is_usable(_target):
		return
	var health := _target.get_node_or_null("Health") as Health
	if health != null and health.is_alive():
		health.take_damage(strike_damage)
		strike_hit.emit(_target, _active_strike_kind)


func _start_return(reason: String) -> void:
	if _phase == Phase.RETURN:
		return
	_phase = Phase.RETURN
	_stuck_timer = 0.0
	print("EXIT STRIKE (begin return) | reason=", reason, " | kind=", _kind)


func _finish_strike() -> void:
	var finished_kind := _kind
	if finished_kind == StrikeKind.ASSIST:
		print("EXIT ASSIST | strike_complete")
	else:
		print("EXIT STRIKE (complete) | kind=", finished_kind)
	_reset_strike_state()
	strike_finished.emit(finished_kind)


func _reset_strike_state() -> void:
	_clear_target("reset")
	_phase = Phase.IDLE
	_hit_applied = false
	_approach_time_remaining = 0.0
	_strike_time_remaining = 0.0
	_stuck_timer = 0.0


func _clear_target(reason: String) -> void:
	if _target != null:
		print("CLEAR STRIKE TARGET | reason=", reason)
		_target = null


func _find_nearest_enemy(origin: Vector2, max_range: float, exclude_instance_id: int = -1) -> Node2D:
	var closest: Node2D = null
	var closest_distance := max_range

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not EnemyValidation.is_usable(enemy):
			continue
		if enemy.get_instance_id() == exclude_instance_id:
			continue

		var distance := origin.distance_to(enemy.global_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest = enemy

	return closest

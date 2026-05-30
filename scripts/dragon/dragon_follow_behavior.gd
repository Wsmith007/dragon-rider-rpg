extends Node
class_name DragonFollowBehavior
## Movement-only follow logic. Modes are set by dragon.gd based on DragonState.
## ALERT: movement anchor is always the rider (FollowAnchor). Threat is look-only.


enum Mode { FOLLOW, REPOSITION, ALERT, WAIT }


@export var ideal_distance: float = 110.0
@export var min_distance: float = 75.0
@export var max_distance: float = 155.0
@export var max_lag_distance: float = 195.0
@export var follow_speed: float = 180.0
@export var catch_up_speed: float = 260.0
@export var reposition_speed: float = 120.0
@export var reposition_arrive_distance: float = 14.0
@export var reposition_min_distance_from_body: float = 45.0
@export var alert_distance: float = 55.0
@export var alert_speed: float = 200.0
@export var wait_hold_speed: float = 140.0
@export var wait_arrive_distance: float = 10.0
@export var enemy_avoid_radius: float = 54.0
@export var enemy_separation_strength: float = 230.0
@export var enemy_steer_strength: float = 170.0
@export var enemy_block_radius: float = 36.0

var mode: Mode = Mode.FOLLOW

var _body: CharacterBody2D
var _target: Node2D
var _reposition_point: Vector2 = Vector2.ZERO
var _has_reposition_target: bool = false
var _look_at_threat: Node2D
var _wait_position: Vector2 = Vector2.ZERO


func setup(body: CharacterBody2D) -> void:
	_body = body


func set_follow_target(target: Node2D) -> void:
	_target = target


func can_idle_reposition() -> bool:
	return mode == Mode.FOLLOW and not _has_reposition_target


func start_reposition() -> void:
	if _target == null or _body == null:
		return
	if mode == Mode.WAIT or mode == Mode.ALERT:
		return
	if _has_reposition_target:
		return

	var anchor := _follow_anchor_global()
	var body_pos := _body.global_position

	for _attempt in range(8):
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(ideal_distance * 0.55, ideal_distance * 0.95)
		var candidate := anchor + Vector2.from_angle(angle) * distance
		if body_pos.distance_to(candidate) >= reposition_min_distance_from_body:
			_reposition_point = candidate
			_has_reposition_target = true
			mode = Mode.REPOSITION
			return

	_reposition_point = anchor + Vector2.from_angle(randf_range(0.0, TAU)) * ideal_distance * 0.75
	_has_reposition_target = true
	mode = Mode.REPOSITION


func finish_reposition() -> void:
	_has_reposition_target = false
	_reposition_point = Vector2.ZERO
	if mode == Mode.REPOSITION:
		mode = Mode.FOLLOW


func enter_waiting(position: Vector2) -> void:
	finish_reposition()
	mode = Mode.WAIT
	_wait_position = position


func exit_waiting() -> void:
	if mode == Mode.WAIT:
		mode = Mode.FOLLOW


func enter_alert(threat: Node2D) -> void:
	if mode == Mode.WAIT:
		return
	if threat == null or not is_instance_valid(threat):
		exit_alert()
		return

	finish_reposition()
	var entering := mode != Mode.ALERT
	mode = Mode.ALERT
	_look_at_threat = threat

	if entering:
		_debug_alert("enter_alert")


func exit_alert() -> void:
	if mode == Mode.ALERT:
		mode = Mode.FOLLOW
	_look_at_threat = null


func get_alert_threat() -> Node2D:
	if _look_at_threat != null and is_instance_valid(_look_at_threat):
		return _look_at_threat
	_look_at_threat = null
	return null


func get_alert_movement_anchor() -> Vector2:
	return _follow_anchor_global()


func get_alert_look_target() -> Vector2:
	var threat := get_alert_threat()
	if threat != null:
		return threat.global_position
	if _target != null:
		return _target.global_position
	return _body.global_position if _body else Vector2.ZERO


func is_at_alert_position() -> bool:
	if mode != Mode.ALERT or _body == null or _target == null:
		return false
	return _body.global_position.distance_to(_follow_anchor_global()) <= alert_distance


func get_mode_name() -> String:
	match mode:
		Mode.REPOSITION:
			return "reposition"
		Mode.ALERT:
			return "alert"
		Mode.WAIT:
			return "wait"
		_:
			return "follow"


func get_desired_velocity() -> Vector2:
	if _body == null:
		return Vector2.ZERO

	var base_velocity := Vector2.ZERO
	var goal := _body.global_position
	var max_speed := follow_speed

	match mode:
		Mode.REPOSITION:
			if not _has_reposition_target:
				mode = Mode.FOLLOW
				base_velocity = _velocity_for_follow()
				goal = _follow_anchor_global()
				max_speed = maxf(follow_speed, catch_up_speed)
			else:
				base_velocity = _velocity_toward(
					_reposition_point, reposition_speed, reposition_arrive_distance, true
				)
				goal = _reposition_point
				max_speed = reposition_speed
		Mode.ALERT:
			base_velocity = _velocity_for_alert()
			goal = _follow_anchor_global()
			max_speed = alert_speed
		Mode.WAIT:
			base_velocity = _velocity_for_wait()
			goal = _wait_position
			max_speed = wait_hold_speed
		_:
			if _target == null:
				return Vector2.ZERO
			base_velocity = _velocity_for_follow()
			goal = _follow_anchor_global()
			max_speed = maxf(follow_speed, catch_up_speed)

	return _apply_enemy_avoidance(base_velocity, goal, max_speed)


func apply_lag_leash() -> void:
	pass


func _apply_enemy_avoidance(desired_velocity: Vector2, goal: Vector2, max_speed: float) -> Vector2:
	return DragonEnemyAvoidance.adjust_velocity(
		_body,
		desired_velocity,
		goal,
		enemy_avoid_radius,
		enemy_separation_strength,
		enemy_steer_strength,
		enemy_block_radius,
		max_speed
	)


func _velocity_for_follow() -> Vector2:
	var anchor := _follow_anchor_global()
	var offset := anchor - _body.global_position
	var distance := offset.length()

	if distance >= max_lag_distance:
		return offset.normalized() * catch_up_speed
	if distance < min_distance:
		return -offset.normalized() * follow_speed * 0.75
	if distance > max_distance:
		return offset.normalized() * follow_speed
	if distance > ideal_distance * 1.12:
		return offset.normalized() * follow_speed * 0.55

	return Vector2.ZERO


func _velocity_for_alert() -> Vector2:
	if _target == null:
		return Vector2.ZERO

	var anchor := _follow_anchor_global()
	var offset := anchor - _body.global_position
	var distance := offset.length()

	if distance > alert_distance:
		return offset.normalized() * alert_speed

	return Vector2.ZERO


func _velocity_for_wait() -> Vector2:
	var offset := _wait_position - _body.global_position
	if offset.length() <= wait_arrive_distance:
		return Vector2.ZERO
	return offset.normalized() * wait_hold_speed


func _velocity_toward(point: Vector2, speed: float, arrive_radius: float, finish_on_arrival: bool) -> Vector2:
	var offset := point - _body.global_position
	if offset.length() <= arrive_radius:
		if finish_on_arrival:
			finish_reposition()
		return Vector2.ZERO
	return offset.normalized() * speed


func _follow_anchor_global() -> Vector2:
	if _target == null:
		return Vector2.ZERO
	var anchor := _target.get_node_or_null("FollowAnchor") as Node2D
	if anchor:
		return anchor.global_position
	return _target.global_position + Vector2(0.0, ideal_distance * 0.35)


func _debug_alert(context: String) -> void:
	print(
		"ENTER ALERT (", context, ") | movement_target=rider_anchor",
		" | look_target=", "enemy" if get_alert_threat() != null else "none"
	)

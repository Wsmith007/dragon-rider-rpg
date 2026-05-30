extends Node
class_name DragonFollowBehavior
## Movement-only follow logic. Dragon.gd owns timing and mode changes; bond/combat layers plug in later.


enum Mode { FOLLOW, REPOSITION, ALERT }


@export var ideal_distance: float = 110.0
@export var min_distance: float = 75.0
@export var max_distance: float = 155.0
## Hard cap on how far the dragon may trail the follow anchor before forced catch-up.
@export var max_lag_distance: float = 195.0
@export var follow_speed: float = 180.0
## Used when at or beyond max_lag_distance (should exceed player move_speed).
@export var catch_up_speed: float = 260.0
@export var reposition_speed: float = 120.0
@export var alert_distance: float = 55.0
@export var alert_speed: float = 200.0

var mode: Mode = Mode.FOLLOW

var _body: CharacterBody2D
var _target: Node2D
var _reposition_point: Vector2 = Vector2.ZERO
var _alert_threat: Node2D


func setup(body: CharacterBody2D) -> void:
	_body = body


func set_follow_target(target: Node2D) -> void:
	_target = target


func start_reposition() -> void:
	if _target == null:
		return
	mode = Mode.REPOSITION
	var angle := randf_range(0.0, TAU)
	var distance := randf_range(ideal_distance * 0.65, ideal_distance * 1.05)
	_reposition_point = _target.global_position + Vector2.from_angle(angle) * distance


func finish_reposition() -> void:
	if mode == Mode.REPOSITION:
		mode = Mode.FOLLOW


func enter_alert(threat: Node2D) -> void:
	mode = Mode.ALERT
	_alert_threat = threat


func exit_alert() -> void:
	if mode == Mode.ALERT:
		mode = Mode.FOLLOW
	_alert_threat = null


func get_alert_threat() -> Node2D:
	return _alert_threat


func get_mode_name() -> String:
	match mode:
		Mode.REPOSITION:
			return "reposition"
		Mode.ALERT:
			return "alert"
		_:
			return "follow"


func get_desired_velocity() -> Vector2:
	if _body == null or _target == null:
		return Vector2.ZERO

	if mode == Mode.REPOSITION:
		if _distance_to_anchor() > max_lag_distance:
			finish_reposition()
			return _velocity_for_follow()
		return _velocity_toward(_reposition_point, reposition_speed, 14.0, true)

	if mode == Mode.ALERT:
		return _velocity_for_alert()

	return _velocity_for_follow()


## Pulls the dragon inward if physics still left it beyond the lag cap (safety net).
func apply_lag_leash() -> void:
	if _body == null or _target == null:
		return
	var anchor := _follow_anchor_global()
	var offset := anchor - _body.global_position
	var distance := offset.length()
	if distance <= max_lag_distance:
		return
	_body.global_position = anchor - offset.normalized() * max_lag_distance


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

	var anchor := _target.global_position
	var offset := anchor - _body.global_position
	var distance := offset.length()

	if distance > alert_distance:
		return offset.normalized() * alert_speed

	return Vector2.ZERO


func _distance_to_anchor() -> float:
	if _body == null or _target == null:
		return 0.0
	return _body.global_position.distance_to(_follow_anchor_global())


func _velocity_toward(point: Vector2, speed: float, arrive_radius: float, finish_on_arrival: bool) -> Vector2:
	var offset := point - _body.global_position
	if offset.length() <= arrive_radius:
		if finish_on_arrival:
			finish_reposition()
		return Vector2.ZERO
	return offset.normalized() * speed


func _follow_anchor_global() -> Vector2:
	var anchor := _target.get_node_or_null("FollowAnchor") as Node2D
	if anchor:
		return anchor.global_position
	return _target.global_position + Vector2(0.0, ideal_distance * 0.35)

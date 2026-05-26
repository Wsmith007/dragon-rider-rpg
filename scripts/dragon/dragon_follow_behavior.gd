extends Node
class_name DragonFollowBehavior
## Movement-only follow logic. Dragon.gd owns timing and mode changes; bond/combat layers plug in later.


enum Mode { FOLLOW, REPOSITION }


@export var ideal_distance: float = 90.0
@export var min_distance: float = 55.0
@export var max_distance: float = 130.0
@export var follow_speed: float = 180.0
@export var reposition_speed: float = 120.0

var mode: Mode = Mode.FOLLOW

var _body: CharacterBody2D
var _target: Node2D
var _reposition_point: Vector2 = Vector2.ZERO


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
	mode = Mode.FOLLOW


func get_mode_name() -> String:
	return "reposition" if mode == Mode.REPOSITION else "follow"


func get_desired_velocity() -> Vector2:
	if _body == null or _target == null:
		return Vector2.ZERO

	if mode == Mode.REPOSITION:
		return _velocity_toward(_reposition_point, reposition_speed, 14.0, true)

	return _velocity_for_follow()


func _velocity_for_follow() -> Vector2:
	var anchor := _follow_anchor_global()
	var offset := anchor - _body.global_position
	var distance := offset.length()

	if distance < min_distance:
		return -offset.normalized() * follow_speed * 0.75
	if distance > max_distance:
		return offset.normalized() * follow_speed
	if distance > ideal_distance * 1.12:
		return offset.normalized() * follow_speed * 0.55

	return Vector2.ZERO


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

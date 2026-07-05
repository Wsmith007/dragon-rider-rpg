extends RefCounted
class_name DragonNavigationRecovery
## Direct follow + rare catch-up / teleport when far and stuck. No breadcrumbs or pathfinding.


enum RecoveryMode { NORMAL, CATCH_UP }

const WALL_COLLISION_MASK := 1
const STUCK_MOVE_EPS := 2.75
const CLOSE_RANGE_NO_RECOVERY := 88.0
const CATCH_UP_MIN_DISTANCE := 95.0
const STUCK_TIME_CATCHUP := 1.25
const STUCK_TIME_TELEPORT := 2.75
const RECOVERY_COOLDOWN := 4.0
const TELEPORT_COOLDOWN := 6.0
const CATCH_UP_SPEED := 265.0
const DRAGON_BODY_RADIUS := 16.0
const TELEPORT_BODY_MARGIN := 2.0
const TELEPORT_RAY_MARGIN := 5.0
const TELEPORT_OFFSETS: Array[Vector2] = [
	Vector2(0.0, 42.0),
	Vector2(0.0, -42.0),
	Vector2(-42.0, 0.0),
	Vector2(42.0, 0.0),
	Vector2(30.0, 30.0),
	Vector2(-30.0, 30.0),
	Vector2(0.0, 62.0),
	Vector2(0.0, -62.0),
	Vector2(-62.0, 0.0),
	Vector2(62.0, 0.0),
]
const NEAR_RIDER_OFFSETS: Array[Vector2] = [
	Vector2(0.0, 38.0),
	Vector2(0.0, 52.0),
	Vector2(-34.0, 38.0),
	Vector2(34.0, 38.0),
]
const DEBUG_LOG := false

var _recovery_enabled: bool = true
var _recovery_mode: RecoveryMode = RecoveryMode.NORMAL
var _stuck_timer: float = 0.0
var _recovery_cooldown: float = 0.0
var _teleport_cooldown: float = 0.0


func reset() -> void:
	_recovery_mode = RecoveryMode.NORMAL
	_stuck_timer = 0.0
	_recovery_cooldown = 0.0


func set_recovery_enabled(enabled: bool) -> void:
	if _recovery_enabled == enabled:
		return
	_recovery_enabled = enabled
	if not enabled:
		reset()


func get_recovery_mode_name() -> String:
	match _recovery_mode:
		RecoveryMode.CATCH_UP:
			return "catch_up"
		_:
			return "normal"


func adjust_velocity(
	body: CharacterBody2D,
	desired_velocity: Vector2,
	goal_position: Vector2,
	_max_speed: float,
	_delta: float,
) -> Vector2:
	if not _recovery_enabled or body == null:
		return desired_velocity

	if body.global_position.distance_to(goal_position) < CLOSE_RANGE_NO_RECOVERY:
		return desired_velocity

	if _recovery_mode == RecoveryMode.CATCH_UP:
		var to_goal := goal_position - body.global_position
		if to_goal.length_squared() < 400.0:
			_exit_recovery()
			_recovery_cooldown = RECOVERY_COOLDOWN
			return desired_velocity
		return to_goal.normalized() * CATCH_UP_SPEED

	return desired_velocity


func after_move(
	body: CharacterBody2D,
	pre_position: Vector2,
	post_position: Vector2,
	desired_velocity: Vector2,
	goal_position: Vector2,
	reference_position: Vector2,
	_max_speed: float,
	delta: float,
) -> void:
	if not _recovery_enabled or body == null:
		_stuck_timer = 0.0
		return

	_recovery_cooldown = maxf(_recovery_cooldown - delta, 0.0)
	_teleport_cooldown = maxf(_teleport_cooldown - delta, 0.0)

	var distance_to_goal := post_position.distance_to(goal_position)
	if distance_to_goal < CLOSE_RANGE_NO_RECOVERY:
		_stuck_timer = 0.0
		if _recovery_mode != RecoveryMode.NORMAL:
			_exit_recovery()
		return

	var intent := desired_velocity.length()
	var moved := post_position.distance_to(pre_position)

	if _recovery_mode == RecoveryMode.CATCH_UP:
		if moved >= STUCK_MOVE_EPS * 1.5 or distance_to_goal < CATCH_UP_MIN_DISTANCE * 0.9:
			_exit_recovery()
			_recovery_cooldown = RECOVERY_COOLDOWN
			_stuck_timer = 0.0
			return
		if _stuck_timer >= STUCK_TIME_TELEPORT and _teleport_cooldown <= 0.0:
			if _try_teleport_near_goal(body, goal_position, reference_position):
				return
		if moved < STUCK_MOVE_EPS and intent > 40.0:
			_stuck_timer += delta
		return

	if intent < 50.0:
		_stuck_timer = maxf(_stuck_timer - delta * 2.5, 0.0)
		return

	if moved < STUCK_MOVE_EPS:
		_stuck_timer += delta
	else:
		_stuck_timer = maxf(_stuck_timer - delta * 2.0, 0.0)

	if _recovery_cooldown > 0.0:
		return
	if distance_to_goal < CATCH_UP_MIN_DISTANCE:
		return

	if _stuck_timer >= STUCK_TIME_TELEPORT and _teleport_cooldown <= 0.0:
		if _try_teleport_near_goal(body, goal_position, reference_position):
			return

	if _stuck_timer >= STUCK_TIME_CATCHUP:
		_begin_catch_up(distance_to_goal)


func get_debug_summary(body: CharacterBody2D, direct_goal: Vector2) -> String:
	if body == null:
		return "mode=normal"
	var dist := body.global_position.distance_to(direct_goal)
	return "mode=%s | dist=%.0f | stuck=%.2f | close=%s" % [
		get_recovery_mode_name(),
		dist,
		_stuck_timer,
		str(dist < CLOSE_RANGE_NO_RECOVERY),
	]


func _begin_catch_up(distance_to_goal: float) -> void:
	if _recovery_mode != RecoveryMode.NORMAL:
		return
	_recovery_mode = RecoveryMode.CATCH_UP
	if DEBUG_LOG:
		print("DRAGON NAV | catch_up | dist=", snapped(distance_to_goal, 1.0))


func _try_teleport_near_goal(
	body: CharacterBody2D,
	goal_position: Vector2,
	reference_position: Vector2,
) -> bool:
	for candidate: Vector2 in _collect_teleport_candidates(goal_position, reference_position):
		if not _is_teleport_valid(body, candidate, reference_position):
			continue
		body.global_position = candidate
		body.velocity = Vector2.ZERO
		_exit_recovery()
		_recovery_cooldown = RECOVERY_COOLDOWN
		_teleport_cooldown = TELEPORT_COOLDOWN
		_stuck_timer = 0.0
		if DEBUG_LOG:
			print(
				"DRAGON NAV | teleport | pos=",
				snapped(candidate.x, 1),
				",",
				snapped(candidate.y, 1)
			)
		return true
	return false


func _collect_teleport_candidates(goal_position: Vector2, reference_position: Vector2) -> Array[Vector2]:
	var candidates: Array[Vector2] = []
	var seen: Dictionary = {}

	var add_candidate := func(position: Vector2) -> void:
		var key := "%d_%d" % [int(snapped(position.x, 1.0)), int(snapped(position.y, 1.0))]
		if seen.has(key):
			return
		seen[key] = true
		candidates.append(position)

	add_candidate.call(goal_position)
	for blend in [0.85, 0.65, 0.45]:
		add_candidate.call(reference_position.lerp(goal_position, blend))
	for offset: Vector2 in TELEPORT_OFFSETS:
		add_candidate.call(goal_position + offset)
	for offset: Vector2 in NEAR_RIDER_OFFSETS:
		add_candidate.call(reference_position + offset)
	return candidates


func _is_teleport_valid(
	body: CharacterBody2D,
	world_position: Vector2,
	reference_position: Vector2,
) -> bool:
	if not _has_body_clearance(body, world_position):
		return false
	if not _has_line_of_sight(body, reference_position, world_position):
		return false
	return true


func _has_body_clearance(body: CharacterBody2D, world_position: Vector2) -> bool:
	var space := body.get_world_2d().direct_space_state
	if space == null:
		return false

	var shape := CircleShape2D.new()
	shape.radius = DRAGON_BODY_RADIUS + TELEPORT_BODY_MARGIN

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, world_position)
	params.collision_mask = WALL_COLLISION_MASK
	params.exclude = _get_physics_exclude(body)
	return space.intersect_shape(params, 1).is_empty()


func _has_line_of_sight(body: CharacterBody2D, from_position: Vector2, to_position: Vector2) -> bool:
	if from_position.distance_squared_to(to_position) < 64.0:
		return true

	var space := body.get_world_2d().direct_space_state
	if space == null:
		return false

	var to_target := to_position - from_position
	var distance := to_target.length()
	if distance < 0.01:
		return true

	var params := PhysicsRayQueryParameters2D.create(
		from_position,
		to_position - to_target.normalized() * TELEPORT_RAY_MARGIN
	)
	params.collision_mask = WALL_COLLISION_MASK
	params.exclude = _get_physics_exclude(body)
	var hit := space.intersect_ray(params)
	return hit.is_empty()


func _get_physics_exclude(body: CharacterBody2D) -> Array[RID]:
	var exclude: Array[RID] = [body.get_rid()]
	var tree := body.get_tree()
	if tree == null:
		return exclude
	var player := tree.get_first_node_in_group("player")
	if player is CollisionObject2D:
		exclude.append((player as CollisionObject2D).get_rid())
	return exclude


func _exit_recovery() -> void:
	_recovery_mode = RecoveryMode.NORMAL

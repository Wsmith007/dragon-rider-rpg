extends RefCounted
class_name EnemyCombatSteering
## Lightweight chase / engage steering: slot spread + peer separation. No pathfinding.


const DEFAULT_SLOT_COUNT := 8
const DEFAULT_SEPARATION_RADIUS := 34.0
const DEFAULT_SEPARATION_STRENGTH := 140.0
const ENGAGE_HOLD_DISTANCE := 14.0
const SLOT_REPOSITION_MIN_DISTANCE := 12.0


static func compute_chase_velocity(
	body: CharacterBody2D,
	player_position: Vector2,
	chase_speed: float,
	slot_standoff: float = 34.0,
	slot_count: int = DEFAULT_SLOT_COUNT
) -> Vector2:
	if body == null:
		return Vector2.ZERO

	var nearby := count_nearby_enemies(body)
	var slot_target := _get_slot_position(body, player_position, slot_standoff, slot_count)
	var to_slot := body.global_position.direction_to(slot_target)
	var velocity := to_slot * chase_speed

	if nearby > 1:
		velocity += _compute_separation(body, DEFAULT_SEPARATION_RADIUS, DEFAULT_SEPARATION_STRENGTH * 0.9)
	else:
		velocity = body.global_position.direction_to(player_position) * chase_speed

	if velocity.length_squared() < 1.0:
		velocity = body.global_position.direction_to(player_position) * chase_speed

	return velocity.limit_length(chase_speed * 1.08)


static func compute_engage_velocity(
	body: CharacterBody2D,
	player_position: Vector2,
	attack_range: float,
	reposition_speed: float = 48.0,
	slot_standoff: float = 34.0,
	slot_count: int = DEFAULT_SLOT_COUNT
) -> Vector2:
	if body == null:
		return Vector2.ZERO

	var nearby := count_nearby_enemies(body)
	var distance := body.global_position.distance_to(player_position)
	var in_attack_range := distance <= attack_range
	var clear_line := has_clear_attack_line(body, player_position)

	var separation := _compute_separation(
		body,
		DEFAULT_SEPARATION_RADIUS,
		DEFAULT_SEPARATION_STRENGTH * 0.55
	)

	if nearby <= 1 and in_attack_range and clear_line:
		if separation.length_squared() > 25.0:
			return separation.limit_length(reposition_speed * 0.35)
		return Vector2.ZERO

	if separation.length_squared() > 36.0:
		return separation.limit_length(reposition_speed * 0.5)

	if not in_attack_range:
		var close_in := body.global_position.direction_to(player_position) * reposition_speed * 0.45
		return (close_in + separation * 0.2).limit_length(reposition_speed * 0.55)

	if clear_line and distance <= ENGAGE_HOLD_DISTANCE + attack_range * 0.15:
		if separation.length_squared() > 16.0:
			return separation.limit_length(reposition_speed * 0.3)
		return Vector2.ZERO

	if nearby <= 1:
		return separation.limit_length(reposition_speed * 0.25)

	var slot_target := _get_slot_position(body, player_position, slot_standoff, slot_count)
	var slot_distance := body.global_position.distance_to(slot_target)
	if slot_distance <= SLOT_REPOSITION_MIN_DISTANCE:
		return separation.limit_length(reposition_speed * 0.25)

	var to_slot := body.global_position.direction_to(slot_target)
	return (to_slot * reposition_speed * 0.22 + separation * 0.2).limit_length(reposition_speed * 0.45)


static func count_nearby_enemies(body: CharacterBody2D, radius: float = 120.0) -> int:
	if body == null:
		return 0

	var count := 0
	for node in body.get_tree().get_nodes_in_group("enemy"):
		if node == body or not node is Node2D:
			continue
		var other := node as Node2D
		if not _is_enemy_active(other):
			continue
		if body.global_position.distance_to(other.global_position) <= radius:
			count += 1
	return count


static func has_clear_attack_line(
	body: CharacterBody2D,
	player_position: Vector2,
	block_radius: float = 16.0
) -> bool:
	if body == null:
		return true

	for node in body.get_tree().get_nodes_in_group("enemy"):
		if node == body or not node is Node2D:
			continue
		var other := node as Node2D
		if not _is_enemy_active(other):
			continue
		if _blocks_path(body.global_position, player_position, other.global_position, block_radius):
			return false
	return true


static func _get_slot_position(
	body: CharacterBody2D,
	player_position: Vector2,
	standoff: float,
	slot_count: int
) -> Vector2:
	var slot_index := absi(body.get_instance_id()) % maxi(slot_count, 1)
	var slot_angle := (TAU / float(slot_count)) * float(slot_index)
	var offset := body.global_position - player_position
	if offset.length_squared() > 64.0:
		slot_angle = lerp_angle(slot_angle, offset.angle(), 0.25)
	return player_position + Vector2.from_angle(slot_angle) * standoff


static func _compute_separation(
	body: CharacterBody2D,
	radius: float,
	strength: float
) -> Vector2:
	var push := Vector2.ZERO

	for node in body.get_tree().get_nodes_in_group("enemy"):
		if node == body or not node is Node2D:
			continue
		var other := node as Node2D
		if not _is_enemy_active(other):
			continue

		var away := body.global_position - other.global_position
		var distance := away.length()
		if distance < 0.001:
			away = Vector2.from_angle(float(absi(body.get_instance_id()) % 628) * 0.01)
			distance = 0.001

		if distance < radius:
			var weight := (radius - distance) / radius
			push += away.normalized() * strength * weight

	return push


static func _blocks_path(from: Vector2, to: Vector2, obstacle: Vector2, radius: float) -> bool:
	var segment := to - from
	var length_sq := segment.length_squared()
	if length_sq < 0.01:
		return from.distance_to(obstacle) <= radius

	var t := clampf((obstacle - from).dot(segment) / length_sq, 0.0, 1.0)
	var closest := from + segment * t
	return closest.distance_to(obstacle) <= radius


static func _is_enemy_active(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if enemy.is_queued_for_deletion():
		return false
	if enemy.has_method("is_dead") and enemy.is_dead:
		return false
	var health := enemy.get_node_or_null("Health") as Health
	return health == null or health.is_alive()

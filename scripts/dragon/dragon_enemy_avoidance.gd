extends RefCounted
class_name DragonEnemyAvoidance
## Simple separation + sidestep steering. No pathfinding — used for FOLLOW/ALERT/WAIT only.


static func adjust_velocity(
	body: CharacterBody2D,
	desired_velocity: Vector2,
	goal_position: Vector2,
	avoid_radius: float,
	separation_strength: float,
	steer_strength: float,
	block_radius: float,
	max_speed: float
) -> Vector2:
	if body == null:
		return desired_velocity

	var body_pos := body.global_position
	var adjusted := desired_velocity

	for node in body.get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_enemy_valid(enemy):
			continue

		var enemy_pos := enemy.global_position
		var away := body_pos - enemy_pos
		var distance := away.length()
		if distance < 0.001:
			away = Vector2.LEFT
			distance = 0.001

		if distance < avoid_radius:
			var push_strength := (avoid_radius - distance) / avoid_radius
			adjusted += away.normalized() * separation_strength * push_strength

		if desired_velocity.length_squared() > 1.0 and distance < avoid_radius * 1.35:
			if _blocks_path(body_pos, goal_position, enemy_pos, block_radius):
				var forward := desired_velocity.normalized()
				var tangent := Vector2(-forward.y, forward.x)
				var side := signf(tangent.dot(goal_position - body_pos))
				if side == 0.0:
					side = 1.0
				adjusted += tangent * side * steer_strength

	if adjusted.length_squared() < 0.01:
		return adjusted

	if max_speed > 0.0:
		return adjusted.limit_length(max_speed)
	return adjusted


static func _blocks_path(from: Vector2, to: Vector2, obstacle: Vector2, radius: float) -> bool:
	var segment := to - from
	var length_sq := segment.length_squared()
	if length_sq < 0.01:
		return from.distance_to(obstacle) <= radius

	var t := clampf((obstacle - from).dot(segment) / length_sq, 0.0, 1.0)
	var closest := from + segment * t
	return closest.distance_to(obstacle) <= radius


static func _is_enemy_valid(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if enemy.is_queued_for_deletion():
		return false
	var health := enemy.get_node_or_null("Health") as Health
	return health == null or health.is_alive()

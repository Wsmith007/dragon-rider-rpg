extends Node
class_name DragonProtectionBehavior
## Finds enemies that threaten the rider for automatic defensive strikes (not cooperation).


@export var protection_range: float = 170.0
@export var close_to_rider_radius: float = 88.0


func find_protection_target(
	rider: Node2D,
	dragon_position: Vector2,
	threat: Node2D,
	exclude_instance_id: int = -1
) -> Node2D:
	if rider == null:
		return null

	var rider_position := rider.global_position
	var best: Node2D = null
	var best_priority := -1
	var best_distance := INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_valid_enemy(enemy):
			continue
		if enemy.get_instance_id() == exclude_instance_id:
			continue

		var distance_to_rider := rider_position.distance_to(enemy.global_position)
		if distance_to_rider > protection_range:
			continue
		if dragon_position.distance_to(enemy.global_position) > protection_range:
			continue

		var priority := _get_threat_priority(enemy, rider_position, distance_to_rider, threat)
		if priority < 0:
			continue

		if priority > best_priority or (priority == best_priority and distance_to_rider < best_distance):
			best_priority = priority
			best_distance = distance_to_rider
			best = enemy

	return best


func _get_threat_priority(
	enemy: Node2D,
	rider_position: Vector2,
	distance_to_rider: float,
	threat: Node2D
) -> int:
	if enemy.has_method("is_engaging_player") and enemy.is_engaging_player():
		return 3
	if enemy.has_method("is_chasing_player") and enemy.is_chasing_player():
		return 2
	if distance_to_rider <= close_to_rider_radius:
		return 1
	if threat != null and enemy == threat:
		return 1
	return -1


func _is_valid_enemy(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if enemy.is_queued_for_deletion():
		return false
	var health := enemy.get_node_or_null("Health") as Health
	return health == null or health.is_alive()

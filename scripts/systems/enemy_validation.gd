extends RefCounted
class_name EnemyValidation
## Safe checks for enemy node references that may be freed or queued.


static func is_usable(enemy) -> bool:
	if enemy == null:
		return false
	if not is_instance_valid(enemy):
		return false
	if not enemy is Node2D:
		return false
	var node: Node2D = enemy as Node2D
	if node.is_queued_for_deletion():
		return false
	var health: Health = node.get_node_or_null("Health") as Health
	return health == null or health.is_alive()


static func resolve_instance_id(enemy) -> int:
	if enemy == null or not is_instance_valid(enemy):
		return -1
	if not enemy is Object:
		return -1
	return (enemy as Object).get_instance_id()

extends Node
class_name PlayerEngagement
## Tracks when the rider is intentionally fighting an enemy (for cooperative assist only).


@export var recent_attack_window: float = 1.25
@export var facing_range: float = 150.0
@export var facing_half_angle_deg: float = 55.0

var _player: CharacterBody2D
var _visual: Polygon2D
var _last_attack_enemy: Node2D
var _last_attack_time: float = -999.0


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	_visual = _player.get_node_or_null("Visual") as Polygon2D
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee != null and melee.has_signal("attack_hit"):
		melee.attack_hit.connect(_on_attack_hit)


func get_assist_target() -> Node2D:
	var recent := _get_recent_attack_target()
	if recent != null:
		return recent
	return _find_facing_target()


func has_engagement_target() -> bool:
	return get_assist_target() != null


func _on_attack_hit(enemy: Node2D) -> void:
	if not _is_valid_enemy(enemy):
		return
	_last_attack_enemy = enemy
	_last_attack_time = Time.get_ticks_msec() / 1000.0


func _get_recent_attack_target() -> Node2D:
	if _last_attack_enemy == null:
		return null
	if Time.get_ticks_msec() / 1000.0 - _last_attack_time > recent_attack_window:
		return null
	if not _is_valid_enemy(_last_attack_enemy):
		_last_attack_enemy = null
		return null
	return _last_attack_enemy


func _find_facing_target() -> Node2D:
	var facing := _get_facing_direction()
	if facing.length_squared() < 0.01:
		return null

	var origin := _player.global_position
	var half_angle := deg_to_rad(facing_half_angle_deg)
	var closest: Node2D = null
	var closest_distance := facing_range

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_valid_enemy(enemy):
			continue

		var offset := enemy.global_position - origin
		var distance := offset.length()
		if distance > facing_range or distance < 0.001:
			continue
		if facing.angle_to(offset) > half_angle:
			continue

		if distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest


func _get_facing_direction() -> Vector2:
	if _player.velocity.length_squared() > 16.0:
		return _player.velocity.normalized()
	if _visual != null:
		return Vector2.from_angle(_visual.rotation - PI * 0.5)
	return Vector2.DOWN


func _is_valid_enemy(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if enemy.is_queued_for_deletion():
		return false
	var health := enemy.get_node_or_null("Health") as Health
	return health == null or health.is_alive()

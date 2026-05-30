extends Node
class_name DragonThreatBehavior
## Scans for enemies threatening the rider. Feeds ALERT state on the dragon.

signal alert_started(threat: Node2D)
signal alert_ended


@export var threat_radius: float = 240.0

var _follow_target: Node2D
var _current_threat: Node2D
var _is_alert: bool = false


func set_follow_target(target: Node2D) -> void:
	_follow_target = target


func get_current_threat() -> Node2D:
	return get_valid_threat()


func get_valid_threat() -> Node2D:
	if EnemyValidation.is_usable(_current_threat):
		return _current_threat
	_current_threat = null
	return null


func is_alert() -> bool:
	return _is_alert and get_valid_threat() != null


func clear_enemy_reference(enemy) -> void:
	var enemy_id: int = EnemyValidation.resolve_instance_id(enemy)
	if enemy_id == -1:
		return
	if not EnemyValidation.is_usable(_current_threat):
		_current_threat = null
		if _is_alert:
			_is_alert = false
			alert_ended.emit()
		return
	if _current_threat.get_instance_id() == enemy_id:
		_current_threat = null
		if _is_alert:
			_is_alert = false
			alert_ended.emit()


func evaluate() -> void:
	_clear_invalid_threat()

	var threat := _find_nearest_threat_to_rider()
	var should_alert := threat != null

	if should_alert and not _is_alert:
		_is_alert = true
		_current_threat = threat
		alert_started.emit(threat)
	elif should_alert and _is_alert:
		_current_threat = threat
	elif not should_alert and _is_alert:
		_is_alert = false
		_current_threat = null
		alert_ended.emit()
	elif not should_alert:
		_current_threat = null


func _clear_invalid_threat() -> void:
	if _current_threat != null and not EnemyValidation.is_usable(_current_threat):
		_current_threat = null
		if _is_alert:
			_is_alert = false
			alert_ended.emit()


func _find_nearest_threat_to_rider() -> Node2D:
	if _follow_target == null:
		return null

	var rider_pos := _follow_target.global_position
	var closest: Node2D = null
	var closest_distance := threat_radius

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not EnemyValidation.is_usable(enemy):
			continue

		var distance := rider_pos.distance_to(enemy.global_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest = enemy

	return closest

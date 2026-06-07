extends Node
class_name DragonThreatBehavior
## Scans for enemies threatening the rider. Feeds ALERT state on the dragon.
## Alert range scales with Bond Strength tier via BondResilience.


signal alert_started(threat: Node2D)
signal alert_ended


@export var debug_alert_detection: bool = true

var _follow_target: Node2D
var _current_threat: Node2D
var _is_alert: bool = false
var _cached_bond_tier: int = -1
var _cached_alert_radius: float = 230.0
var _nearest_enemy_distance: float = -1.0


func _ready() -> void:
	_update_bond_tuning()


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


func get_alert_range() -> float:
	return _cached_alert_radius


func get_nearest_enemy_distance() -> float:
	return _nearest_enemy_distance


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
	_update_bond_tuning()
	_clear_invalid_threat()

	var threat := _find_nearest_threat_to_rider()
	var should_alert := threat != null

	if should_alert and not _is_alert:
		_is_alert = true
		_current_threat = threat
		_log_alert_trigger("started", threat)
		alert_started.emit(threat)
	elif should_alert and _is_alert:
		_current_threat = threat
	elif not should_alert and _is_alert:
		_is_alert = false
		_log_alert_trigger("ended", _current_threat)
		_current_threat = null
		alert_ended.emit()
	elif not should_alert:
		_current_threat = null


func _update_bond_tuning() -> void:
	var bond_strength: float = BondSystem.get_profile().bond_strength
	var bond_tier: int = BondResilience.get_bond_tier(bond_strength)
	if bond_tier == _cached_bond_tier:
		return

	_cached_bond_tier = bond_tier
	_cached_alert_radius = BondResilience.get_alert_range(bond_strength)

	if debug_alert_detection:
		print(
			"ALERT TUNING | bond=", int(bond_strength),
			" | tier=", bond_tier,
			" | alert_range=", _cached_alert_radius,
			" | prot_radius=", BondResilience.get_protection_radius(bond_strength)
		)


func _clear_invalid_threat() -> void:
	if _current_threat != null and not EnemyValidation.is_usable(_current_threat):
		_current_threat = null
		if _is_alert:
			_is_alert = false
			alert_ended.emit()


func _find_nearest_threat_to_rider() -> Node2D:
	_nearest_enemy_distance = -1.0
	if _follow_target == null:
		return null

	var rider_pos := _follow_target.global_position
	var closest: Node2D = null
	var closest_in_alert_range := _cached_alert_radius
	var nearest_any := INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not EnemyValidation.is_usable(enemy):
			continue

		var distance := rider_pos.distance_to(enemy.global_position)
		nearest_any = minf(nearest_any, distance)
		if distance <= closest_in_alert_range:
			closest_in_alert_range = distance
			closest = enemy

	if nearest_any != INF:
		_nearest_enemy_distance = nearest_any

	return closest


func _log_alert_trigger(event: String, threat: Node2D) -> void:
	if not debug_alert_detection:
		return

	var bond_strength: float = BondSystem.get_profile().bond_strength
	var enemy_distance: float = -1.0
	if _follow_target != null and EnemyValidation.is_usable(threat):
		enemy_distance = _follow_target.global_position.distance_to(threat.global_position)

	print(
		"ALERT ", event.to_upper(),
		" | bond=", int(bond_strength),
		" | tier=", BondResilience.get_bond_tier(bond_strength),
		" | alert_range=", _cached_alert_radius,
		" | prot_radius=", BondResilience.get_protection_radius(bond_strength),
		" | enemy_distance=", snapped(enemy_distance, 0.1)
	)

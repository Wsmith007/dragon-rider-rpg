extends Node
class_name DragonProtectionBehavior
## Finds enemies that threaten the rider for automatic defensive strikes (not cooperation).
## Bond Strength tunes detection radius, response delay, and alert persistence.


@export_group("Bond Strength — Protection Radius")
@export var radius_tier_low: float = 100.0
@export var radius_tier_mid: float = 150.0
@export var radius_tier_high: float = 200.0
@export var radius_tier_max: float = 250.0

@export_group("Bond Strength — Response Delay")
@export var delay_tier_low: float = 0.75
@export var delay_tier_mid: float = 0.50
@export var delay_tier_high: float = 0.25
@export var delay_tier_max: float = 0.0

@export_group("Bond Strength — Persistence")
@export var persistence_tier_low: float = 1.0
@export var persistence_tier_mid: float = 2.0
@export var persistence_tier_high: float = 3.0
@export var persistence_tier_max: float = 5.0

@export var close_to_rider_radius: float = 88.0
@export var debug_protection: bool = false

var _tracked_target: Node2D
var _tracked_target_id: int = -1
var _response_delay_remaining: float = 0.0
var _persistence_remaining: float = 0.0
var _target_in_range: bool = false
var _protection_interest_active: bool = false
var _cached_bond_tier: int = -1
var _cached_bond_radius: float = 150.0
var _cached_bond_delay: float = 0.5
var _cached_bond_persistence: float = 2.0


func _ready() -> void:
	_update_bond_tuning()


func tick_protection(
	delta: float,
	rider: Node2D,
	dragon_position: Vector2,
	threat: Node2D,
	exclude_instance_id: int = -1
) -> void:
	_sanitize_tracked_target()
	_update_bond_tuning()

	var in_range_target: Node2D = _find_protection_target(
		rider,
		dragon_position,
		threat,
		exclude_instance_id,
		_cached_bond_radius
	)
	_target_in_range = in_range_target != null

	if _target_in_range:
		if _tracked_target_id != EnemyValidation.resolve_instance_id(in_range_target):
			_tracked_target = in_range_target
			_tracked_target_id = EnemyValidation.resolve_instance_id(in_range_target)
			_response_delay_remaining = _cached_bond_delay
			_persistence_remaining = _cached_bond_persistence
			_protection_interest_active = true
		elif not _protection_interest_active:
			_tracked_target = in_range_target
			_tracked_target_id = EnemyValidation.resolve_instance_id(in_range_target)
			_persistence_remaining = _cached_bond_persistence
			_protection_interest_active = true
	elif _protection_interest_active:
		_persistence_remaining = maxf(_persistence_remaining - delta, 0.0)
		if _persistence_remaining <= 0.0:
			_end_protection_interest()

	if _has_protection_interest() and EnemyValidation.is_usable(_tracked_target):
		_response_delay_remaining = maxf(_response_delay_remaining - delta, 0.0)
	elif not _protection_interest_active:
		_clear_tracked_target()


func get_ready_protection_target() -> Node2D:
	if not _has_protection_interest():
		return null
	if _response_delay_remaining > 0.0:
		return null
	if not EnemyValidation.is_usable(_tracked_target):
		_clear_tracked_target()
		return null
	return _tracked_target


func notify_protection_triggered(target: Node2D) -> void:
	if not debug_protection:
		return
	var target_name: String = "unknown"
	if EnemyValidation.is_usable(target):
		target_name = str(target.name)
	print("PROTECTION TRIGGERED | target=", target_name)


func clear_enemy_reference(enemy) -> void:
	if enemy == null:
		return
	if EnemyValidation.resolve_instance_id(enemy) == _tracked_target_id:
		_end_protection_interest()


func get_protection_radius(bond_strength: float) -> float:
	match _tier_for_bond(bond_strength):
		0:
			return radius_tier_low
		1:
			return radius_tier_mid
		2:
			return radius_tier_high
		_:
			return radius_tier_max


func get_response_delay(bond_strength: float) -> float:
	match _tier_for_bond(bond_strength):
		0:
			return delay_tier_low
		1:
			return delay_tier_mid
		2:
			return delay_tier_high
		_:
			return delay_tier_max


func get_persistence_duration(bond_strength: float) -> float:
	match _tier_for_bond(bond_strength):
		0:
			return persistence_tier_low
		1:
			return persistence_tier_mid
		2:
			return persistence_tier_high
		_:
			return persistence_tier_max


func _update_bond_tuning() -> void:
	var bond_strength: float = BondSystem.get_profile().bond_strength
	var bond_tier: int = _tier_for_bond(bond_strength)
	if bond_tier == _cached_bond_tier:
		return

	_cached_bond_tier = bond_tier
	_cached_bond_radius = get_protection_radius(bond_strength)
	_cached_bond_delay = get_response_delay(bond_strength)
	_cached_bond_persistence = get_persistence_duration(bond_strength)

	if debug_protection:
		print("BOND STRENGTH | ", int(bond_strength))
		print("PROTECTION RADIUS | ", _cached_bond_radius)
		print("PROTECTION RESPONSE DELAY | ", _cached_bond_delay)
		print("PROTECTION PERSISTENCE | ", _cached_bond_persistence)


func _has_protection_interest() -> bool:
	return _protection_interest_active and (
		_target_in_range or _persistence_remaining > 0.0
	)


func _end_protection_interest() -> void:
	if not _protection_interest_active:
		_clear_tracked_target()
		return
	if debug_protection:
		print("PROTECTION ENDED")
	_protection_interest_active = false
	_target_in_range = false
	_clear_tracked_target()


func _clear_tracked_target() -> void:
	_tracked_target = null
	_tracked_target_id = -1
	_response_delay_remaining = 0.0


func _sanitize_tracked_target() -> void:
	if _tracked_target == null:
		return
	if not EnemyValidation.is_usable(_tracked_target):
		_tracked_target = null
		_tracked_target_id = -1
		if _protection_interest_active and _persistence_remaining <= 0.0:
			_end_protection_interest()


static func _tier_for_bond(bond_strength: float) -> int:
	if bond_strength <= 25.0:
		return 0
	if bond_strength <= 50.0:
		return 1
	if bond_strength <= 75.0:
		return 2
	return 3


func _find_protection_target(
	rider: Node2D,
	dragon_position: Vector2,
	threat: Node2D,
	exclude_instance_id: int,
	protection_radius: float
) -> Node2D:
	if rider == null:
		return null

	if EnemyValidation.is_usable(_tracked_target):
		var rider_position: Vector2 = rider.global_position
		var distance_to_rider: float = rider_position.distance_to(_tracked_target.global_position)
		if distance_to_rider <= protection_radius \
				and dragon_position.distance_to(_tracked_target.global_position) <= protection_radius:
			var priority: int = _get_threat_priority(
				_tracked_target,
				rider_position,
				distance_to_rider,
				threat
			)
			if priority >= 0:
				return _tracked_target

	var rider_position: Vector2 = rider.global_position
	var best: Node2D = null
	var best_priority: int = -1
	var best_distance: float = INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		if not EnemyValidation.is_usable(node):
			continue
		var enemy := node as Node2D
		if enemy.get_instance_id() == exclude_instance_id:
			continue

		var distance_to_rider: float = rider_position.distance_to(enemy.global_position)
		if distance_to_rider > protection_radius:
			continue
		if dragon_position.distance_to(enemy.global_position) > protection_radius:
			continue

		var priority: int = _get_threat_priority(enemy, rider_position, distance_to_rider, threat)
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
	if not EnemyValidation.is_usable(enemy):
		return -1
	if enemy.has_method("is_engaging_player") and enemy.is_engaging_player():
		return 3
	if enemy.has_method("is_chasing_player") and enemy.is_chasing_player():
		return 2
	if distance_to_rider <= close_to_rider_radius:
		return 1
	if EnemyValidation.is_usable(threat) and enemy == threat:
		return 1
	return -1

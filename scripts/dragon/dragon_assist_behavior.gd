extends Node
class_name DragonAssistBehavior
## Assist attack logic. Only invoked by dragon.gd during ALERT or wait self-defense.


signal assist_started(enemy: Node2D)
signal assist_hit(enemy: Node2D)
signal assist_finished


enum Phase { IDLE, LUNGE, RETURN }


@export var assist_range: float = 130.0
@export var assist_damage: float = 22.0
@export var assist_cooldown: float = 2.75
@export var defense_cooldown: float = 4.5
@export var lunge_speed: float = 340.0
@export var hit_distance: float = 30.0
@export var return_speed: float = 220.0
@export var return_arrive_distance: float = 18.0
@export var defense_radius: float = 72.0

var _cooldown_remaining: float = 0.0
var _defense_cooldown_remaining: float = 0.0
var _phase: Phase = Phase.IDLE
var _target: Node2D
var _return_point: Vector2 = Vector2.ZERO
var _return_label: String = "PLAYER"
var _hit_applied: bool = false
var _last_defense_target_id: int = -1


func _ready() -> void:
	_cooldown_remaining = assist_cooldown * 0.5


func update_cooldown(delta: float) -> void:
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
	_defense_cooldown_remaining = maxf(_defense_cooldown_remaining - delta, 0.0)


func is_on_cooldown() -> bool:
	return _cooldown_remaining > 0.0


func is_busy() -> bool:
	return _phase != Phase.IDLE


func is_returning() -> bool:
	return _phase == Phase.RETURN


func get_target() -> Node2D:
	if _is_enemy_alive(_target):
		return _target
	return null


func get_return_point() -> Vector2:
	return _return_point


func find_nearest_enemy(origin: Vector2, max_range: float, exclude_instance_id: int = -1) -> Node2D:
	var closest: Node2D = null
	var closest_distance := max_range

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_enemy_alive(enemy):
			continue
		if enemy.get_instance_id() == exclude_instance_id:
			continue

		var distance := origin.distance_to(enemy.global_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest = enemy

	return closest


func find_assist_target(dragon_position: Vector2) -> Node2D:
	return find_nearest_enemy(dragon_position, assist_range)


func find_defense_target(dragon_position: Vector2) -> Node2D:
	return find_nearest_enemy(dragon_position, defense_radius, _last_defense_target_id)


func can_begin_defense() -> bool:
	return not is_busy() and _defense_cooldown_remaining <= 0.0 and not is_on_cooldown()


func try_begin_alert_assist(enemy: Node2D, return_point: Vector2) -> bool:
	return _try_begin_assist(enemy, return_point, "PLAYER")


func try_begin_defense_assist(enemy: Node2D, return_point: Vector2) -> bool:
	if not can_begin_defense():
		return false
	if not _is_enemy_alive(enemy):
		return false

	if not _try_begin_assist(enemy, return_point, "WAIT_POSITION"):
		return false

	_defense_cooldown_remaining = defense_cooldown
	_last_defense_target_id = enemy.get_instance_id()
	return true


func get_lunge_velocity(dragon_position: Vector2) -> Vector2:
	if _phase != Phase.LUNGE:
		return Vector2.ZERO

	if not _is_enemy_alive(_target):
		_clear_assist_target("invalid_lunge_target")
		_start_return("invalid_lunge_target")
		return get_return_velocity(dragon_position)

	var offset := _target.global_position - dragon_position
	if offset.length() <= hit_distance:
		if not _hit_applied:
			_hit_applied = true
			print("HIT ATTEMPT | target=", _target.name)
			_apply_damage()
		_clear_assist_target("hit")
		_start_return("hit")
		return get_return_velocity(dragon_position)

	return offset.normalized() * lunge_speed


func get_return_velocity(dragon_position: Vector2) -> Vector2:
	if _phase != Phase.RETURN:
		return Vector2.ZERO

	var offset := _return_point - dragon_position
	if offset.length() <= return_arrive_distance:
		_finish_assist()
		return Vector2.ZERO
	return offset.normalized() * return_speed


func cancel_assist(emit_finished_signal: bool = true) -> void:
	if _phase == Phase.IDLE:
		return
	_clear_assist_target("cancel")
	_phase = Phase.IDLE
	_hit_applied = false
	if emit_finished_signal:
		assist_finished.emit()


func clear_defense_block_if_target_gone(origin: Vector2) -> void:
	if _last_defense_target_id == -1:
		return

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		if node.get_instance_id() != _last_defense_target_id:
			continue
		if not _is_enemy_alive(node as Node2D):
			_last_defense_target_id = -1
			return
		if origin.distance_to((node as Node2D).global_position) <= defense_radius:
			return

	_last_defense_target_id = -1


func _try_begin_assist(enemy: Node2D, return_point: Vector2, return_label: String) -> bool:
	if not _is_enemy_alive(enemy):
		return false
	if is_busy():
		return false
	if is_on_cooldown():
		return false

	_target = enemy
	_return_point = return_point
	_return_label = return_label
	_hit_applied = false
	_phase = Phase.LUNGE
	_cooldown_remaining = assist_cooldown
	print("ENTER ASSIST | target=", enemy.name, " | RETURN TARGET=", _return_label)
	assist_started.emit(enemy)
	return true


func _apply_damage() -> void:
	if not _is_enemy_alive(_target):
		return
	var health := _target.get_node_or_null("Health") as Health
	if health != null and health.is_alive():
		health.take_damage(assist_damage)
		assist_hit.emit(_target)


func _start_return(reason: String) -> void:
	if _phase == Phase.RETURN:
		return
	_phase = Phase.RETURN
	print("EXIT ASSIST (begin return) | reason=", reason, " | RETURN TARGET=", _return_label)


func _finish_assist() -> void:
	print("EXIT ASSIST (complete) | RETURN TARGET=", _return_label)
	_clear_assist_target("finish")
	_phase = Phase.IDLE
	_hit_applied = false
	assist_finished.emit()


func _clear_assist_target(reason: String) -> void:
	if _target != null:
		print("CLEAR ASSIST TARGET | reason=", reason)
	_target = null


func _is_enemy_alive(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if enemy.is_queued_for_deletion():
		return false
	var health := enemy.get_node_or_null("Health") as Health
	return health == null or health.is_alive()

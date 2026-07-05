extends Node
class_name PlayerTargetFocus
## Ocarina-style target focus: maintain facing toward a chosen enemy. Not lock-on combat.

signal focus_changed(active: bool, target: Node2D)

const FOCUS_RANGE := 320.0
const FRONT_HALF_ANGLE_DEG := 75.0
const DEBUG_LOG := false

var _player: CharacterBody2D
var _focused_enemy: Node2D
var _focus_enabled: bool = false


func setup(player: CharacterBody2D) -> void:
	_player = player
	set_physics_process(true)


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	if event.is_action_pressed("target_focus_toggle"):
		_toggle_focus()
		get_viewport().set_input_as_handled()
		return

	if not is_focus_active():
		return

	if event.is_action_pressed("target_focus_next"):
		_cycle_focus(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("target_focus_prev"):
		_cycle_focus(-1)
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	_validate_focus()


func is_focus_active() -> bool:
	return _focus_enabled and _is_enemy_valid(_focused_enemy)


func get_focused_enemy() -> Node2D:
	if _is_enemy_valid(_focused_enemy):
		return _focused_enemy
	return null


func get_focus_facing() -> Vector2:
	if _player == null or not is_focus_active():
		return Vector2.ZERO

	var offset := _focused_enemy.global_position - _player.global_position
	if offset.length_squared() < 0.01:
		return Vector2.ZERO
	return offset.normalized()


func get_focus_label() -> String:
	if not is_focus_active():
		return "None"
	return "%s (#%d)" % [_focused_enemy.name, _focused_enemy.get_instance_id()]


func clear_focus() -> void:
	_focus_enabled = false
	_drop_focused_enemy()
	focus_changed.emit(false, null)


func _toggle_focus() -> void:
	if _focus_enabled:
		clear_focus()
		return

	_focus_enabled = true
	var acquired := _acquire_best_target()
	if acquired == null:
		_focus_enabled = false
		if DEBUG_LOG:
			print("[TARGET FOCUS] No valid enemy in range")
		return

	_set_focus(acquired)


func _drop_focused_enemy() -> void:
	if _focused_enemy != null:
		_disconnect_enemy_died(_focused_enemy)
	_focused_enemy = null


func _try_retarget_or_clear() -> void:
	if not _focus_enabled:
		_drop_focused_enemy()
		focus_changed.emit(false, null)
		return

	var nearest := _acquire_nearest_target()
	if nearest != null:
		_set_focus(nearest)
		if DEBUG_LOG:
			print("[TARGET FOCUS] Retargeted to ", nearest.name)
		return

	_focus_enabled = false
	_drop_focused_enemy()
	focus_changed.emit(false, null)
	if DEBUG_LOG:
		print("[TARGET FOCUS] No retarget — focus cleared")


func _set_focus(enemy: Node2D) -> void:
	if _focused_enemy == enemy:
		return
	if _focused_enemy != null:
		_disconnect_enemy_died(_focused_enemy)
	_focused_enemy = enemy
	_connect_enemy_died(enemy)
	focus_changed.emit(true, enemy)
	if DEBUG_LOG:
		print("[TARGET FOCUS] Locked ", enemy.name)


func _acquire_nearest_target(exclude: Node2D = null) -> Node2D:
	if _player == null:
		return null

	var origin := _player.global_position
	var best: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if enemy == exclude:
			continue
		if not _is_enemy_valid(enemy):
			continue

		var distance := origin.distance_to(enemy.global_position)
		if distance > FOCUS_RANGE:
			continue
		if distance < best_distance:
			best_distance = distance
			best = enemy

	return best


func _acquire_best_target() -> Node2D:
	if _player == null:
		return null

	var origin := _player.global_position
	var facing := _get_acquire_facing()
	var best: Node2D = null
	var best_score := INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_enemy_valid(enemy):
			continue

		var score := _score_acquire_candidate(enemy, origin, facing)
		if score < 0.0:
			continue
		if score < best_score:
			best_score = score
			best = enemy

	return best


func _score_acquire_candidate(enemy: Node2D, origin: Vector2, facing: Vector2) -> float:
	var offset := enemy.global_position - origin
	var distance := offset.length()
	if distance > FOCUS_RANGE or distance < 0.001:
		return -1.0

	var angle := absf(facing.angle_to(offset))
	var front_half := deg_to_rad(FRONT_HALF_ANGLE_DEG)
	var angle_score := angle / front_half
	if angle > front_half:
		angle_score += 2.0
	return angle_score * 1.5 + distance / FOCUS_RANGE


func _cycle_focus(direction: int) -> void:
	var ordered := _gather_targets_sorted_by_angle()
	if ordered.is_empty():
		_try_retarget_or_clear()
		return
	if ordered.size() == 1:
		_set_focus(ordered[0])
		return

	var current_index := ordered.find(_focused_enemy)
	if current_index < 0:
		_set_focus(ordered[0])
		return

	var next_index := posmod(current_index + direction, ordered.size())
	_set_focus(ordered[next_index])


func _gather_targets_sorted_by_angle() -> Array[Node2D]:
	if _player == null:
		return []

	var origin := _player.global_position
	var targets: Array[Node2D] = []

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_enemy_valid(enemy):
			continue
		if origin.distance_to(enemy.global_position) > FOCUS_RANGE:
			continue
		targets.append(enemy)

	targets.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		var angle_a := (a.global_position - origin).angle()
		var angle_b := (b.global_position - origin).angle()
		return angle_a < angle_b
	)
	return targets


func _validate_focus() -> void:
	if not _focus_enabled:
		return
	if _player == null:
		clear_focus()
		return
	if _focused_enemy == null:
		_try_retarget_or_clear()
		return
	if not _is_enemy_valid(_focused_enemy):
		_drop_focused_enemy()
		_try_retarget_or_clear()
		return
	if _player.global_position.distance_to(_focused_enemy.global_position) > FOCUS_RANGE:
		_drop_focused_enemy()
		_try_retarget_or_clear()


func _get_acquire_facing() -> Vector2:
	if _player == null:
		return Vector2.DOWN
	if _player.has_method("get_facing_direction"):
		var facing: Vector2 = _player.get_facing_direction()
		if facing.length_squared() > 0.01:
			return facing.normalized()
	return Vector2.DOWN


func _is_enemy_valid(enemy: Node2D) -> bool:
	if enemy == null or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
		return false
	if not enemy.is_in_group("enemy"):
		return false
	if enemy.get("is_dead") == true:
		return false
	var health := enemy.get_node_or_null("Health") as Health
	if health != null and not health.is_alive():
		return false
	return true


func _connect_enemy_died(enemy: Node) -> void:
	if not enemy.has_signal("enemy_died"):
		return
	if not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)


func _disconnect_enemy_died(enemy: Node) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if enemy.has_signal("enemy_died") and enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.disconnect(_on_enemy_died)


func _on_enemy_died(enemy: Node) -> void:
	if enemy != _focused_enemy:
		return
	_drop_focused_enemy()
	_try_retarget_or_clear()

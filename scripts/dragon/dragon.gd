extends CharacterBody2D
## Dragon actor: follow, wait, alert, defensive protection, and cooperative assist.


signal behavior_changed(mode_name: String)
signal state_changed(state: DragonState.State)
signal dragon_assisted(enemy: Node2D)

enum MovementOwner { NORMAL, HESITATION, STRIKE }

@onready var follow_behavior: DragonFollowBehavior = $FollowBehavior
@onready var threat_behavior: DragonThreatBehavior = $ThreatBehavior
@onready var command_behavior: DragonCommandBehavior = $CommandBehavior
@onready var protection_behavior: DragonProtectionBehavior = $ProtectionBehavior
@onready var strike_behavior: DragonStrikeBehavior = $StrikeBehavior
@onready var cooperation_behavior: DragonCooperationBehavior = $CooperationBehavior
@onready var _visual: Polygon2D = $Visual
@onready var _attack_flash: Polygon2D = $AttackFlash

@export var reposition_interval_min: float = 2.5
@export var reposition_interval_max: float = 6.0
@export var reposition_chance: float = 0.5
@export var reposition_only_when_rider_slow: bool = true
@export var rider_slow_speed_threshold: float = 40.0

var state: DragonState.State = DragonState.State.FOLLOWING
var _movement_owner: MovementOwner = MovementOwner.NORMAL

var _follow_target: Node2D
var _player_engagement: PlayerEngagement
var _reposition_cooldown: float = 0.0
var _last_reported_state: DragonState.State = DragonState.State.FOLLOWING
var _base_modulate: Color = Color.WHITE


func _ready() -> void:
	add_to_group("dragon")
	_base_modulate = _visual.modulate
	follow_behavior.setup(self)
	_schedule_next_reposition_check()
	threat_behavior.alert_started.connect(_on_rider_alert_started)
	threat_behavior.alert_ended.connect(_on_rider_alert_ended)
	strike_behavior.strike_hit.connect(_on_strike_hit)
	strike_behavior.strike_finished.connect(_on_strike_finished)
	command_behavior.wait_position_set.connect(_on_command_wait_applied)
	command_behavior.recalled.connect(_on_command_recall_applied)
	_attack_flash.visible = false
	call_deferred("_connect_enemy_death_signals")


func _connect_enemy_death_signals() -> void:
	var tree := get_tree()
	if tree == null:
		return
	if not tree.node_added.is_connected(_on_enemy_node_added):
		tree.node_added.connect(_on_enemy_node_added)
	for node in tree.get_nodes_in_group("enemy"):
		_connect_enemy_death(node)


func _on_enemy_node_added(node: Node) -> void:
	if node.is_in_group("enemy"):
		_connect_enemy_death(node)


func _connect_enemy_death(enemy: Node) -> void:
	if not enemy.has_signal("enemy_died"):
		return
	if not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(enemy: Node) -> void:
	protection_behavior.clear_enemy_reference(enemy)
	cooperation_behavior.clear_enemy_reference(enemy)
	threat_behavior.clear_enemy_reference(enemy)
	strike_behavior.clear_enemy_reference(enemy)
	if _player_engagement != null:
		_player_engagement.clear_enemy_reference(enemy)


func set_follow_target(target: Node2D) -> void:
	_follow_target = target
	follow_behavior.set_follow_target(target)
	threat_behavior.set_follow_target(target)
	_player_engagement = target.get_node_or_null("Engagement") as PlayerEngagement
	call_deferred("_connect_enemy_death_signals")


func handle_command_toggle() -> void:
	command_behavior.request_toggle(global_position)


func _on_command_wait_applied(_wait_pos: Vector2) -> void:
	state = DragonState.State.WAITING
	follow_behavior.enter_waiting(command_behavior.wait_position)
	_emit_state_if_changed()


func _on_command_recall_applied() -> void:
	strike_behavior.cancel_strike(false)
	cooperation_behavior.cancel_cooperative_assist("command_recall")
	follow_behavior.exit_waiting()
	follow_behavior.exit_alert()
	threat_behavior.evaluate()
	_set_following_state()
	_emit_state_if_changed()


func _physics_process(delta: float) -> void:
	if _follow_target == null:
		return

	strike_behavior.update_cooldown(delta)
	command_behavior.tick(delta, global_position)
	cooperation_behavior.tick(delta)
	_tick_protection_behavior(delta)
	_handle_hesitation_completion()
	_movement_owner = _determine_movement_owner()

	match _movement_owner:
		MovementOwner.STRIKE:
			_process_strike_frame(delta)
		MovementOwner.HESITATION:
			_process_hesitation_frame(delta)
		_:
			_process_normal_frame(delta)

	_reset_hesitation_visuals_if_idle()
	move_and_slide()

	if _movement_owner == MovementOwner.NORMAL:
		_apply_post_move_separation()

	_update_facing()
	_update_visual_modulate()
	_emit_state_if_changed()


func _determine_movement_owner() -> MovementOwner:
	if strike_behavior.is_busy():
		return MovementOwner.STRIKE
	if cooperation_behavior.is_hesitating():
		return MovementOwner.HESITATION
	return MovementOwner.NORMAL


func _process_strike_frame(delta: float) -> void:
	strike_behavior.update_strike(delta, global_position, _get_rider_position())
	_set_combat_state_from_strike()
	velocity = strike_behavior.get_movement_velocity(global_position)


func _process_hesitation_frame(_delta: float) -> void:
	_update_non_combat_state_without_assist(_delta)
	state = DragonState.State.HESITATING
	velocity = follow_behavior.get_desired_velocity()


func _handle_hesitation_completion() -> void:
	var outcome := cooperation_behavior.consume_hesitation_outcome()
	if outcome == DragonCooperationBehavior.HesitationOutcome.NONE:
		return

	if outcome == DragonCooperationBehavior.HesitationOutcome.CANCELED:
		_transition_to_contextual_state("hesitation_canceled")
		return

	var target := cooperation_behavior.take_approved_assist_target()
	if target == null:
		return

	_execute_cooperative_assist(target)


func _update_non_combat_state_without_assist(_delta: float) -> void:
	if command_behavior.is_waiting:
		state = DragonState.State.WAITING
		follow_behavior.enter_waiting(command_behavior.wait_position)
		return

	threat_behavior.evaluate()

	if threat_behavior.is_alert():
		var threat := threat_behavior.get_valid_threat()
		follow_behavior.enter_alert(threat)
		if not cooperation_behavior.is_hesitating():
			state = DragonState.State.ALERT
	else:
		if not cooperation_behavior.is_hesitating():
			_set_following_state()

	if not cooperation_behavior.is_hesitating() and not strike_behavior.is_busy():
		_try_defensive_protection()


func _process_normal_frame(delta: float) -> void:
	_update_non_combat_state(delta)
	velocity = follow_behavior.get_desired_velocity()


func _update_non_combat_state(delta: float) -> void:
	if command_behavior.is_waiting:
		_process_waiting_state()
		return

	threat_behavior.evaluate()

	if threat_behavior.is_alert():
		var threat := threat_behavior.get_valid_threat()
		follow_behavior.enter_alert(threat)
		if not cooperation_behavior.is_hesitating():
			var entering_alert := state != DragonState.State.ALERT
			state = DragonState.State.ALERT
			if entering_alert:
				_log_alert_debug("state_enter")
		_try_cooperative_assist()
		if not strike_behavior.is_busy():
			_try_defensive_protection()
	else:
		if not cooperation_behavior.is_hesitating():
			_set_following_state()
		_try_cooperative_assist()
		_update_reposition_timer(delta)


func _process_waiting_state() -> void:
	state = DragonState.State.WAITING
	follow_behavior.enter_waiting(command_behavior.wait_position)

	if strike_behavior.is_busy() or not strike_behavior.can_begin_protection():
		return

	var defense_target := strike_behavior.find_wait_protection_target(
		global_position,
		strike_behavior.get_wait_protection_exclude_id()
	)
	if defense_target == null:
		strike_behavior.clear_wait_protection_block_if_target_gone(global_position)
		return

	var rider_position := _get_rider_position()
	if strike_behavior.try_begin_wait_protection(
		defense_target,
		command_behavior.wait_position,
		rider_position
	):
		state = DragonState.State.PROTECTING
		follow_behavior.exit_waiting()
		dragon_assisted.emit(defense_target)


## Cooperative assist only — never affects protection.
func _try_cooperative_assist() -> void:
	if cooperation_behavior.is_hesitating():
		return
	if cooperation_behavior.has_pending_hesitation_outcome():
		return
	if not cooperation_behavior.can_attempt_cooperative_assist():
		return
	if strike_behavior.is_busy() or not strike_behavior.can_begin_assist():
		return
	if _player_engagement == null:
		return

	var target := _player_engagement.get_assist_target()
	if target == null:
		return
	if not strike_behavior.is_target_within_strike_range(target):
		return

	match cooperation_behavior.request_cooperative_assist(target):
		DragonCooperationBehavior.AssistStartResult.HESITATING:
			state = DragonState.State.HESITATING
			return
		DragonCooperationBehavior.AssistStartResult.CANCELED:
			_transition_to_contextual_state("assist_canceled")
			return
		DragonCooperationBehavior.AssistStartResult.APPROVED:
			_execute_cooperative_assist(target)
		_:
			return


func _execute_cooperative_assist(target: Node2D) -> void:
	if not is_instance_valid(target) or strike_behavior.is_busy():
		return
	if not strike_behavior.can_begin_assist():
		return

	follow_behavior.finish_reposition()
	var return_point := follow_behavior.get_alert_movement_anchor()
	if strike_behavior.try_begin_assist(target, return_point, _get_rider_position()):
		state = DragonState.State.ASSISTING
		follow_behavior.exit_alert()
		dragon_assisted.emit(target)


func _tick_protection_behavior(delta: float) -> void:
	if _follow_target == null:
		return
	protection_behavior.tick_protection(
		delta,
		_follow_target,
		global_position,
		threat_behavior.get_valid_threat(),
		_get_engaged_enemy_instance_id()
	)


## Defensive protection: automatic when enemies chase, crowd, or threaten the rider.
func _try_defensive_protection() -> void:
	if strike_behavior.is_busy() or not strike_behavior.can_begin_protection():
		return
	if not follow_behavior.is_at_alert_position():
		return

	var target := protection_behavior.get_ready_protection_target()
	if target == null:
		return

	follow_behavior.finish_reposition()
	var return_point := follow_behavior.get_alert_movement_anchor()
	if strike_behavior.try_begin_protection(target, return_point, _get_rider_position()):
		protection_behavior.notify_protection_triggered(target)
		state = DragonState.State.PROTECTING
		follow_behavior.exit_alert()
		dragon_assisted.emit(target)


func _get_engaged_enemy_instance_id() -> int:
	if _player_engagement == null:
		return -1
	var engaged := _player_engagement.get_assist_target()
	if engaged == null:
		return -1
	return engaged.get_instance_id()


func _set_combat_state_from_strike() -> void:
	if strike_behavior.get_strike_kind() == DragonStrikeBehavior.StrikeKind.ASSIST:
		state = DragonState.State.ASSISTING
	else:
		state = DragonState.State.PROTECTING


func _transition_to_contextual_state(reason: String) -> void:
	follow_behavior.finish_reposition()
	follow_behavior.exit_alert()
	cooperation_behavior.clear_pending_assist_target()
	_reset_hesitation_visuals_if_idle()

	if command_behavior.is_waiting:
		state = DragonState.State.WAITING
		follow_behavior.enter_waiting(command_behavior.wait_position)
		print("RETURN STATE | WAITING | reason=", reason)
		return

	threat_behavior.evaluate()
	var threat := threat_behavior.get_valid_threat()
	if threat != null:
		state = DragonState.State.ALERT
		follow_behavior.enter_alert(threat)
		print("RETURN STATE | ALERT | reason=", reason)
	else:
		_set_following_state()
		print("RETURN STATE | FOLLOWING | reason=", reason)


func _set_following_state() -> void:
	state = DragonState.State.FOLLOWING
	follow_behavior.exit_alert()


func _get_rider_position() -> Vector2:
	if _follow_target:
		return _follow_target.global_position
	return global_position


func _update_facing() -> void:
	var look_target: Vector2

	if _movement_owner == MovementOwner.STRIKE and strike_behavior.is_returning():
		if _follow_target:
			look_target = follow_behavior.get_alert_movement_anchor()
		else:
			return
	elif _movement_owner == MovementOwner.STRIKE:
		var strike_target := strike_behavior.get_target()
		if strike_target != null and is_instance_valid(strike_target):
			look_target = strike_target.global_position
		else:
			return
	elif state == DragonState.State.ALERT:
		look_target = follow_behavior.get_alert_look_target()
	elif velocity.length_squared() > 1.0:
		look_target = global_position + velocity
	else:
		return

	var direction := global_position.direction_to(look_target)
	_visual.rotation = direction.angle() + PI * 0.5


func _update_visual_modulate() -> void:
	var base := _base_modulate
	match state:
		DragonState.State.ASSISTING:
			base = Color(1.0, 0.55, 0.35, 1.0)
		DragonState.State.PROTECTING:
			base = Color(1.0, 0.45, 0.4, 1.0)
		DragonState.State.ALERT:
			base = Color(1.0, 0.85, 0.55, 1.0)
		DragonState.State.WAITING:
			base = Color(0.75, 0.85, 1.0, 1.0)
		DragonState.State.HESITATING:
			base = Color(0.82, 0.78, 1.0, 1.0)

	if cooperation_behavior.is_hesitating():
		_visual.modulate = cooperation_behavior.get_shudder_modulate(base)
	else:
		_visual.modulate = base


func _reset_hesitation_visuals_if_idle() -> void:
	if cooperation_behavior.is_hesitating():
		_visual.position = cooperation_behavior.get_shudder_visual_offset()
	else:
		_visual.position = Vector2.ZERO


func _update_reposition_timer(delta: float) -> void:
	if _movement_owner != MovementOwner.NORMAL:
		return
	if state != DragonState.State.FOLLOWING:
		return
	if threat_behavior.is_alert():
		return
	if not follow_behavior.can_idle_reposition():
		return

	_reposition_cooldown -= delta
	if _reposition_cooldown > 0.0:
		return

	_schedule_next_reposition_check()

	if randf() >= reposition_chance:
		return

	if reposition_only_when_rider_slow:
		if not _follow_target is CharacterBody2D:
			return
		var rider := _follow_target as CharacterBody2D
		if rider.velocity.length() > rider_slow_speed_threshold:
			return

	follow_behavior.start_reposition()


func _on_rider_alert_started(_threat: Node2D) -> void:
	if command_behavior.is_waiting:
		return
	_emit_state_if_changed()


func _on_rider_alert_ended() -> void:
	if command_behavior.is_waiting:
		return
	if state == DragonState.State.ALERT:
		_set_following_state()
	_emit_state_if_changed()


func _on_strike_hit(enemy: Node2D, _kind: DragonStrikeBehavior.StrikeKind) -> void:
	_flash_attack()
	dragon_assisted.emit(enemy)


func _on_strike_finished(kind: DragonStrikeBehavior.StrikeKind) -> void:
	if kind == DragonStrikeBehavior.StrikeKind.ASSIST:
		print("EXIT ASSIST")
	_transition_to_contextual_state("strike_finished_signal")
	_emit_state_if_changed()


func _flash_attack() -> void:
	_attack_flash.visible = true
	_attack_flash.modulate = Color(1.0, 0.9, 0.4, 0.85)
	var tween := create_tween()
	tween.tween_property(_attack_flash, "modulate:a", 0.0, 0.22)
	tween.tween_callback(func(): _attack_flash.visible = false)


func _emit_state_if_changed() -> void:
	if state == _last_reported_state:
		return

	_last_reported_state = state
	var state_name := DragonState.state_name(state)
	state_changed.emit(state)
	behavior_changed.emit(state_name)


func _log_alert_debug(context: String) -> void:
	var movement_type := "rider_anchor"
	var look_type := "enemy" if follow_behavior.get_alert_threat() != null else "rider"
	print(
		"ENTER ALERT | context=", context,
		" | movement_target=", movement_type,
		" | look_target=", look_type,
		" | state=", DragonState.state_name(state)
	)


func _schedule_next_reposition_check() -> void:
	_reposition_cooldown = randf_range(reposition_interval_min, reposition_interval_max)


func _apply_post_move_separation() -> void:
	const SEPARATION_RADIUS := 40.0
	const NUDGE := 6.0

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue

		var offset := global_position - enemy.global_position
		var distance := offset.length()
		if distance < SEPARATION_RADIUS and distance > 0.001:
			global_position += offset.normalized() * NUDGE

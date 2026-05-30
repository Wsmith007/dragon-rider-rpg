extends CharacterBody2D
## Dragon actor: state machine orchestrating follow, wait, alert, and assist layers.


signal behavior_changed(mode_name: String)
signal state_changed(state: DragonState.State)
signal dragon_assisted(enemy: Node2D)

@onready var follow_behavior: DragonFollowBehavior = $FollowBehavior
@onready var threat_behavior: DragonThreatBehavior = $ThreatBehavior
@onready var command_behavior: DragonCommandBehavior = $CommandBehavior
@onready var assist_behavior: DragonAssistBehavior = $AssistBehavior
@onready var _visual: Polygon2D = $Visual
@onready var _attack_flash: Polygon2D = $AttackFlash

@export var reposition_interval_min: float = 2.5
@export var reposition_interval_max: float = 6.0
@export var reposition_chance: float = 0.5
@export var reposition_only_when_rider_slow: bool = true
@export var rider_slow_speed_threshold: float = 40.0

var state: DragonState.State = DragonState.State.FOLLOWING

var _follow_target: Node2D
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
	assist_behavior.assist_hit.connect(_on_assist_hit)
	assist_behavior.assist_finished.connect(_on_assist_finished)
	_attack_flash.visible = false


func set_follow_target(target: Node2D) -> void:
	_follow_target = target
	follow_behavior.set_follow_target(target)
	threat_behavior.set_follow_target(target)


func handle_command_toggle() -> void:
	if command_behavior.is_waiting:
		command_behavior.recall()
		assist_behavior.cancel_assist(false)
		follow_behavior.exit_waiting()
		follow_behavior.exit_alert()
		threat_behavior.evaluate()
		_set_following_state()
	else:
		command_behavior.set_wait(global_position)
		state = DragonState.State.WAITING
		follow_behavior.enter_waiting(command_behavior.wait_position)

	_emit_state_if_changed()


func _physics_process(delta: float) -> void:
	if _follow_target == null:
		return

	assist_behavior.update_cooldown(delta)

	if state == DragonState.State.ASSISTING or assist_behavior.is_busy():
		state = DragonState.State.ASSISTING
		if not assist_behavior.is_busy():
			_resolve_post_assist_state()
	else:
		_update_non_assisting_state(delta)

	velocity = _get_movement_velocity()
	move_and_slide()

	# If still overlapping an enemy after movement, nudge away (not during assist lunge).
	if not assist_behavior.is_busy() or assist_behavior.is_returning():
		_apply_post_move_separation()

	_update_facing()
	_update_visual_modulate()
	_emit_state_if_changed()


func _update_non_assisting_state(delta: float) -> void:
	if command_behavior.is_waiting:
		_process_waiting_state()
		return

	threat_behavior.evaluate()

	if threat_behavior.is_alert():
		var entering_alert := state != DragonState.State.ALERT
		state = DragonState.State.ALERT
		follow_behavior.enter_alert(threat_behavior.get_valid_threat())
		if entering_alert:
			_log_alert_debug("state_enter")
		_try_alert_assist()
	else:
		_set_following_state()
		_update_reposition_timer(delta)


func _process_waiting_state() -> void:
	state = DragonState.State.WAITING
	follow_behavior.enter_waiting(command_behavior.wait_position)

	if assist_behavior.is_busy() or not assist_behavior.can_begin_defense():
		return

	var defense_target := assist_behavior.find_defense_target(global_position)
	if defense_target == null:
		assist_behavior.clear_defense_block_if_target_gone(global_position)
		return

	if assist_behavior.try_begin_defense_assist(defense_target, command_behavior.wait_position):
		state = DragonState.State.ASSISTING
		follow_behavior.exit_waiting()
		dragon_assisted.emit(defense_target)


func _try_alert_assist() -> void:
	if assist_behavior.is_busy() or assist_behavior.is_on_cooldown():
		return
	if not follow_behavior.is_at_alert_position():
		return

	var target := assist_behavior.find_assist_target(global_position)
	if target == null:
		return

	var return_point := follow_behavior.get_alert_movement_anchor()
	if assist_behavior.try_begin_alert_assist(target, return_point):
		state = DragonState.State.ASSISTING
		follow_behavior.exit_alert()
		dragon_assisted.emit(target)


func _get_movement_velocity() -> Vector2:
	if assist_behavior.is_busy():
		if assist_behavior.is_returning():
			return assist_behavior.get_return_velocity(global_position)
		return assist_behavior.get_lunge_velocity(global_position)

	return follow_behavior.get_desired_velocity()


func _resolve_post_assist_state() -> void:
	follow_behavior.exit_alert()

	if command_behavior.is_waiting:
		state = DragonState.State.WAITING
		follow_behavior.enter_waiting(command_behavior.wait_position)
		return

	threat_behavior.evaluate()
	var threat := threat_behavior.get_valid_threat()
	if threat != null:
		state = DragonState.State.ALERT
		follow_behavior.enter_alert(threat)
	else:
		_set_following_state()


func _set_following_state() -> void:
	state = DragonState.State.FOLLOWING
	follow_behavior.exit_alert()


func _update_facing() -> void:
	var look_target: Vector2

	if assist_behavior.is_busy() and assist_behavior.is_returning():
		if _follow_target:
			look_target = follow_behavior.get_alert_movement_anchor()
		else:
			return
	elif assist_behavior.is_busy():
		var assist_target := assist_behavior.get_target()
		if assist_target != null and is_instance_valid(assist_target):
			look_target = assist_target.global_position
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
	match state:
		DragonState.State.ASSISTING:
			_visual.modulate = Color(1.0, 0.55, 0.35, 1.0)
		DragonState.State.ALERT:
			_visual.modulate = Color(1.0, 0.85, 0.55, 1.0)
		DragonState.State.WAITING:
			_visual.modulate = Color(0.75, 0.85, 1.0, 1.0)
		_:
			_visual.modulate = _base_modulate


func _update_reposition_timer(delta: float) -> void:
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


func _on_assist_hit(_enemy: Node2D) -> void:
	_flash_attack()


func _on_assist_finished() -> void:
	_resolve_post_assist_state()
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
	if assist_behavior.is_busy() and not assist_behavior.is_returning():
		return

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

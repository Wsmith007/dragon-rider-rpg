extends CharacterBody2D
## Top-down rider movement, health, and combat signals.

signal moved(velocity: Vector2)
signal player_damaged(current_health: float, maximum_health: float)
signal player_died
signal movement_state_changed(state_name: String)


enum MovementState { RUNNING, COMBAT_STANCE, TARGET_FOCUS, ATTACKING, STAGGERED, DEAD }

@export var move_speed: float = 220.0
@export var max_health: float = 1000.0
@export var visual_facing_lerp_speed: float = 14.0

const PLAYER_BODY_RADIUS := 14.0
const MOVE_INPUT_DEADZONE := 0.01

@onready var _health: Health = $Health
@onready var _visual_pivot: Node2D = $VisualPivot
@onready var _visual: Polygon2D = $VisualPivot/SpinLayer/Visual
@onready var _target_focus: PlayerTargetFocus = $TargetFocus

var _is_dead: bool = false
var _facing_direction: Vector2 = Vector2.DOWN
var _visual_facing: Vector2 = Vector2.DOWN
var _weapon_move_multiplier: float = 1.0
var _attack_phase_multiplier: float = 1.0
var _combat_stagger_remaining: float = 0.0
var _combat_safe_zone: bool = false
var _relationship_last_health: float = 0.0
var _relationship_was_critical: bool = false

var _combat_stance_active: bool = false
var _stance_facing: Vector2 = Vector2.DOWN
var _attack_facing_locked: bool = false
var _attack_facing: Vector2 = Vector2.DOWN
var _movement_state: MovementState = MovementState.RUNNING

const RELATIONSHIP_CRITICAL_HP_RATIO := 0.25


func _ready() -> void:
	add_to_group("player")
	_health.max_health = max_health
	_health.current_health = max_health
	_relationship_last_health = max_health
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_visual_facing = _facing_direction
	_apply_visual_rotation(_visual_facing)
	_target_focus.setup(self)
	_target_focus.focus_changed.connect(_on_target_focus_changed)


func _physics_process(delta: float) -> void:
	if _is_dead:
		_set_movement_state(MovementState.DEAD)
		velocity = Vector2.ZERO
		return

	if _combat_stagger_remaining > 0.0:
		_process_stagger_frame(delta)
	else:
		_process_movement_frame(delta)

	_update_visual_facing(delta)
	_emit_move_if_moving()


func _process_stagger_frame(delta: float) -> void:
	_set_movement_state(MovementState.STAGGERED)
	_combat_stagger_remaining = maxf(_combat_stagger_remaining - delta, 0.0)
	velocity = Vector2.ZERO
	move_and_slide()
	if _combat_stagger_remaining <= 0.0:
		reset_attack_move_speed_multiplier()
		_visual.modulate = Color.WHITE


func _process_movement_frame(_delta: float) -> void:
	_update_combat_stance()
	_update_movement_state()

	var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := _resolve_move_direction(move_input)
	var speed := move_speed * _weapon_move_multiplier * _attack_phase_multiplier
	velocity = direction * speed
	move_and_slide()
	_resolve_enemy_body_overlap()

	if not _combat_stance_active and not _attack_facing_locked and not _target_focus.is_focus_active():
		if velocity.length_squared() > 256.0:
			_facing_direction = velocity.normalized()
	elif _target_focus.is_focus_active():
		var focus_facing := _target_focus.get_focus_facing()
		if focus_facing.length_squared() > 0.01:
			_facing_direction = focus_facing


func _update_combat_stance() -> void:
	var wants_stance := Input.is_action_pressed("combat_stance")
	if wants_stance and not _combat_stance_active:
		_stance_facing = _get_free_facing_direction()
		_facing_direction = _stance_facing
	elif not wants_stance and _combat_stance_active:
		if velocity.length_squared() > 256.0:
			_facing_direction = velocity.normalized()
		else:
			_facing_direction = _stance_facing
	_combat_stance_active = wants_stance


func _update_movement_state() -> void:
	if _attack_facing_locked:
		_set_movement_state(MovementState.ATTACKING)
	elif _target_focus.is_focus_active():
		_set_movement_state(MovementState.TARGET_FOCUS)
	elif _combat_stance_active:
		_set_movement_state(MovementState.COMBAT_STANCE)
	else:
		_set_movement_state(MovementState.RUNNING)


func _resolve_move_direction(move_input: Vector2) -> Vector2:
	if move_input.length_squared() <= MOVE_INPUT_DEADZONE * MOVE_INPUT_DEADZONE:
		return Vector2.ZERO
	return move_input.normalized()


func _update_visual_facing(delta: float) -> void:
	var target := _get_visual_target_facing()
	if target.length_squared() < 0.01:
		return

	if _visual_facing.length_squared() < 0.01:
		_visual_facing = target
	else:
		var current_angle := _visual_facing.angle()
		var target_angle := target.angle()
		var blended_angle := lerp_angle(current_angle, target_angle, clampf(visual_facing_lerp_speed * delta, 0.0, 1.0))
		_visual_facing = Vector2.from_angle(blended_angle)

	_apply_visual_rotation(_visual_facing)


func _get_visual_target_facing() -> Vector2:
	if _attack_facing_locked:
		return _attack_facing
	if _target_focus.is_focus_active():
		var focus_facing := _target_focus.get_focus_facing()
		if focus_facing.length_squared() > 0.01:
			return focus_facing
	if _combat_stance_active:
		return _stance_facing
	if velocity.length_squared() > 256.0:
		return velocity.normalized()
	return _facing_direction


func _apply_visual_rotation(facing: Vector2) -> void:
	if facing.length_squared() < 0.01:
		return
	_visual_pivot.rotation = facing.angle() + PI * 0.5


func _get_free_facing_direction() -> Vector2:
	if _visual_facing.length_squared() > 0.01:
		return _visual_facing.normalized()
	if _facing_direction.length_squared() > 0.01:
		return _facing_direction.normalized()
	return Vector2.DOWN


func get_facing_direction() -> Vector2:
	if _attack_facing_locked and _attack_facing.length_squared() > 0.01:
		return _attack_facing.normalized()
	if _target_focus.is_focus_active():
		var focus_facing := _target_focus.get_focus_facing()
		if focus_facing.length_squared() > 0.01:
			return focus_facing.normalized()
	if _combat_stance_active and _stance_facing.length_squared() > 0.01:
		return _stance_facing.normalized()
	if velocity.length_squared() > 256.0 and not _combat_stance_active:
		return velocity.normalized()
	if _facing_direction.length_squared() > 0.01:
		return _facing_direction.normalized()
	if _visual_facing.length_squared() > 0.01:
		return _visual_facing.normalized()
	return Vector2.from_angle(_visual_pivot.rotation - PI * 0.5).normalized()


func get_facing_label() -> String:
	var facing := get_facing_direction()
	if facing.length_squared() < 0.01:
		return "—"
	var angle_deg := rad_to_deg(facing.angle())
	if angle_deg < 0.0:
		angle_deg += 360.0
	if angle_deg >= 337.5 or angle_deg < 22.5:
		return "E"
	if angle_deg < 67.5:
		return "SE"
	if angle_deg < 112.5:
		return "S"
	if angle_deg < 157.5:
		return "SW"
	if angle_deg < 202.5:
		return "W"
	if angle_deg < 247.5:
		return "NW"
	if angle_deg < 292.5:
		return "N"
	return "NE"


func get_movement_state() -> MovementState:
	return _movement_state


func get_movement_state_label() -> String:
	match _movement_state:
		MovementState.COMBAT_STANCE:
			return "Combat Stance"
		MovementState.TARGET_FOCUS:
			return "Target Focus"
		MovementState.ATTACKING:
			return "Attacking"
		MovementState.STAGGERED:
			return "Staggered"
		MovementState.DEAD:
			return "Dead"
		_:
			return "Running"


func is_combat_stance_active() -> bool:
	return _combat_stance_active


func is_target_focus_active() -> bool:
	return _target_focus.is_focus_active()


func get_target_focus_label() -> String:
	return _target_focus.get_focus_label()


func get_weapon_move_multiplier() -> float:
	return _weapon_move_multiplier


func get_attack_phase_move_multiplier() -> float:
	return _attack_phase_multiplier


func get_total_move_speed_multiplier() -> float:
	return _weapon_move_multiplier * _attack_phase_multiplier


func get_effective_move_speed() -> float:
	return move_speed * get_total_move_speed_multiplier()


func set_weapon_move_multiplier(multiplier: float) -> void:
	_weapon_move_multiplier = maxf(multiplier, 0.0)


func lock_attack_facing(direction: Vector2 = Vector2.ZERO) -> void:
	if direction.length_squared() > 0.01:
		_attack_facing = direction.normalized()
	else:
		_attack_facing = get_facing_direction()
	_attack_facing_locked = true
	_facing_direction = _attack_facing


func unlock_attack_facing() -> void:
	_attack_facing_locked = false
	if _target_focus.is_focus_active():
		var focus_facing := _target_focus.get_focus_facing()
		if focus_facing.length_squared() > 0.01:
			_facing_direction = focus_facing
	elif _combat_stance_active:
		_facing_direction = _stance_facing
	elif velocity.length_squared() > 256.0:
		_facing_direction = velocity.normalized()


func set_attack_move_speed_multiplier(multiplier: float) -> void:
	_attack_phase_multiplier = clampf(multiplier, 0.0, 1.0)


func reset_attack_move_speed_multiplier() -> void:
	_attack_phase_multiplier = 1.0


func set_combat_safe_zone(active: bool) -> void:
	_combat_safe_zone = active


func is_in_combat_safe_zone() -> bool:
	return _combat_safe_zone


func apply_combat_hit_reaction(
	from_world_position: Vector2,
	knockback_distance: float,
	stagger_duration: float,
) -> void:
	if _is_dead:
		return

	unlock_attack_facing()

	var direction := global_position - from_world_position
	if direction.length_squared() < 0.01:
		direction = -get_facing_direction()
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT
	direction = direction.normalized()

	if knockback_distance > 0.0:
		_apply_collision_aware_knockback(direction, knockback_distance)

	if stagger_duration > 0.0:
		_combat_stagger_remaining = maxf(_combat_stagger_remaining, stagger_duration)
		set_attack_move_speed_multiplier(0.0)
		_visual.modulate = Color(0.85, 0.75, 0.75, 1.0)


func _apply_collision_aware_knockback(direction: Vector2, distance: float) -> void:
	CharacterWallRecovery.nudge_with_collision(self, direction, distance)


func _resolve_enemy_body_overlap() -> void:
	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is CharacterBody2D:
			continue
		var enemy := node as CharacterBody2D
		if not is_instance_valid(enemy):
			continue

		var offset := global_position - enemy.global_position
		var distance := offset.length()
		var enemy_radius := _get_enemy_body_radius(enemy)
		var min_sep := PLAYER_BODY_RADIUS + enemy_radius - 1.0
		if distance >= min_sep:
			continue

		var push_dir := offset
		if push_dir.length_squared() < 0.01:
			push_dir = -get_facing_direction()
		if push_dir.length_squared() < 0.01:
			push_dir = Vector2.UP
		push_dir = push_dir.normalized()

		var separation := min_sep - distance
		var is_brute := _is_brute_enemy(enemy)
		var push_scale := 1.0 if is_brute else 0.88
		CharacterWallRecovery.nudge_with_collision(self, push_dir, separation * push_scale)


func _is_brute_enemy(enemy: CharacterBody2D) -> bool:
	if not enemy.has_meta("slice_archetype"):
		return false
	return int(enemy.get_meta("slice_archetype")) == VerticalSliceArchetypePresets.Archetype.BRUTE


func _get_enemy_body_radius(enemy: CharacterBody2D) -> float:
	if enemy.has_method("_get_body_radius"):
		return enemy._get_body_radius()
	var shape_node := enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node != null and shape_node.shape is CircleShape2D:
		var circle := shape_node.shape as CircleShape2D
		return circle.radius * maxf(enemy.scale.x, enemy.scale.y)
	return PLAYER_BODY_RADIUS


func _emit_move_if_moving() -> void:
	if velocity.length_squared() > 0.0:
		moved.emit(velocity)


func _set_movement_state(state: MovementState) -> void:
	if _movement_state == state:
		return
	_movement_state = state
	movement_state_changed.emit(get_movement_state_label())


func _on_health_changed(current: float, maximum: float) -> void:
	_relationship_last_health = current

	if maximum > 0.0 and current > 0.0:
		var ratio := current / maximum
		var is_critical := ratio <= RELATIONSHIP_CRITICAL_HP_RATIO
		if is_critical and not _relationship_was_critical:
			_relationship_was_critical = true
			RelationshipSystem.record_event(RelationshipEvent.COMBAT_PLAYER_CRITICAL_HP, {
				"current": current,
				"maximum": maximum,
				"ratio": ratio,
			})
		elif not is_critical:
			_relationship_was_critical = false

	player_damaged.emit(current, maximum)


func _on_died() -> void:
	_is_dead = true
	_target_focus.clear_focus()
	velocity = Vector2.ZERO
	set_physics_process(false)
	$MeleeAttack.set_physics_process(false)
	RelationshipSystem.record_event(RelationshipEvent.COMBAT_PLAYER_DEATH)
	player_died.emit()
	_visual.modulate = Color(0.6, 0.6, 0.6, 0.75)
	_set_movement_state(MovementState.DEAD)


func _on_target_focus_changed(_active: bool, _target: Node2D) -> void:
	_update_movement_state()
	movement_state_changed.emit(get_movement_state_label())

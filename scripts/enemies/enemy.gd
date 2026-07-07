extends CharacterBody2D
## Enemy AI with slice archetype behaviors: Scout (skirmish), Raider (baseline), Brute (control check).

signal player_detected
signal player_lost
signal attacked_player
signal enemy_died(enemy: Node)


enum State { IDLE, CHASE, ENGAGE, DISENGAGE, RECOVER }
enum AttackPhase { NONE, WINDUP, LUNGE }


@export var max_health: float = 150.0
@export var detection_radius: float = 220.0
@export var lose_radius: float = 320.0
@export var chase_speed: float = 100.0
@export var attack_range: float = 36.0
@export var attack_damage: float = 12.0
@export var attack_cooldown: float = 1.0
@export var engage_windup: float = 0.45
@export var engage_reposition_speed: float = 48.0
@export var slot_standoff: float = 34.0
@export var knockback_resistance: float = 1.0
@export var attack_lunge_distance: float = 20.0
@export var attack_lunge_duration: float = 0.11
@export var player_hit_knockback: float = 0.0
@export var player_hit_stagger: float = 0.0
@export var steer_smoothing: float = 10.0
@export var facing_smoothing: float = 14.0

## Scout — probe / disengage after each strike.
@export var disengage_duration: float = 0.0
@export var disengage_speed: float = 0.0
@export var circle_bias: float = 0.0

## Brute — committed strike recovery after each attack.
@export var post_attack_recovery: float = 0.0
@export var post_attack_cooldown_bonus: float = 0.0

## Pass 1B — wind-up progress (0–1) after which the current swing cannot be cancelled.
@export var attack_commit_ratio: float = 0.45
## Pass 1B — multiplier applied to incoming hit stagger (Scout > 1, Brute < 1).
@export var hit_stagger_multiplier: float = 1.0

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _state: State = State.IDLE
var _player: Node2D
var _attack_cooldown_remaining: float = 0.0
var _stagger_remaining: float = 0.0
var _disengage_remaining: float = 0.0
var _recover_remaining: float = 0.0
var _smoothed_velocity: Vector2 = Vector2.ZERO
var _attack_phase: AttackPhase = AttackPhase.NONE
var _attack_phase_remaining: float = 0.0
var _attack_lunge_dir: Vector2 = Vector2.RIGHT
var _attack_lunge_traveled: float = 0.0
var _attack_resolved: bool = false
var _base_visual_color: Color = Color.WHITE
var is_dead: bool = false

# Scout probe — short bursts while searching for openings.
var _scout_probe_burst_remaining: float = 0.0
var _scout_probe_burst_dir: Vector2 = Vector2.RIGHT
var _scout_time_since_attack: float = 0.0
var _knockback_immunity_remaining: float = 0.0
var _wall_stuck_timer: float = 0.0

const BODY_RADIUS := 14.0
const PLAYER_BODY_RADIUS := 14.0
const KNOCKBACK_IMMUNITY_DURATION := 0.20


func _ready() -> void:
	add_to_group("enemy")
	collision_mask = 1
	_health.max_health = max_health
	_health.current_health = max_health
	_health.died.connect(_on_died)
	_base_visual_color = _visual.color
	_find_player()


func _physics_process(delta: float) -> void:
	if is_dead or not _health.is_alive():
		return

	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)
	_disengage_remaining = maxf(_disengage_remaining - delta, 0.0)
	_recover_remaining = maxf(_recover_remaining - delta, 0.0)
	_knockback_immunity_remaining = maxf(_knockback_immunity_remaining - delta, 0.0)

	if _get_archetype() == VerticalSliceArchetypePresets.Archetype.SCOUT:
		if _attack_phase == AttackPhase.NONE and _state != State.DISENGAGE:
			_scout_time_since_attack += delta
		_scout_probe_burst_remaining = maxf(_scout_probe_burst_remaining - delta, 0.0)

	if _stagger_remaining > 0.0 and not _is_attack_committed():
		_stagger_remaining = maxf(_stagger_remaining - delta, 0.0)
		_smoothed_velocity = Vector2.ZERO
		velocity = Vector2.ZERO
		_wall_stuck_timer = CharacterWallRecovery.move_with_recovery(self, Vector2.ZERO, _wall_stuck_timer, delta)
		_update_facing(delta)
		return

	if _stagger_remaining > 0.0:
		_stagger_remaining = maxf(_stagger_remaining - delta, 0.0)

	if _attack_phase != AttackPhase.NONE:
		_process_attack_phase(delta)
		_update_facing(delta)
		return

	if _player == null or not is_instance_valid(_player):
		_find_player()

	_update_state()
	_apply_movement(delta)
	_update_facing(delta)


func scale_incoming_player_hit(knockback: float, stagger: float) -> Vector2:
	var kb := knockback
	var archetype := _get_archetype()
	var committed := _is_attack_committed()

	match archetype:
		VerticalSliceArchetypePresets.Archetype.RAIDER:
			if committed:
				kb *= 0.12
			else:
				kb *= 0.78
				if _knockback_immunity_remaining > 0.0:
					kb *= 0.38
		VerticalSliceArchetypePresets.Archetype.BRUTE:
			kb = _compute_brute_knockback(kb)
			if committed:
				kb *= 0.08

	return Vector2(kb, stagger)


func apply_hit_reaction(direction: Vector2, knockback_distance: float, stagger_duration: float) -> void:
	if is_dead:
		return
	if knockback_distance <= 0.0 and stagger_duration <= 0.0:
		return

	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT

	var archetype := _get_archetype()
	var committed := _is_attack_committed()
	var applied_stagger := stagger_duration * hit_stagger_multiplier

	var effective_knockback := knockback_distance
	if archetype == VerticalSliceArchetypePresets.Archetype.BRUTE:
		effective_knockback = _compute_brute_knockback(knockback_distance)
		if committed:
			effective_knockback *= 0.12

	if not committed or archetype == VerticalSliceArchetypePresets.Archetype.SCOUT:
		var applied_knockback := effective_knockback / maxf(knockback_resistance, 0.01)
		if applied_knockback > 0.0:
			_apply_collision_aware_knockback(direction, applied_knockback)
			if (
				not committed
				and archetype == VerticalSliceArchetypePresets.Archetype.RAIDER
				and applied_knockback > 2.0
			):
				_knockback_immunity_remaining = KNOCKBACK_IMMUNITY_DURATION

	if committed and archetype != VerticalSliceArchetypePresets.Archetype.SCOUT:
		if archetype == VerticalSliceArchetypePresets.Archetype.RAIDER:
			_stagger_remaining = maxf(_stagger_remaining, applied_stagger * 0.18)
		return

	if (
		archetype == VerticalSliceArchetypePresets.Archetype.BRUTE
		and _attack_phase != AttackPhase.NONE
		and _get_player_combat_distance() <= _get_body_radius() + PLAYER_BODY_RADIUS + 6.0
	):
		_stagger_remaining = maxf(_stagger_remaining, applied_stagger * 0.22)
		return

	_cancel_attack()
	_stagger_remaining = maxf(_stagger_remaining, applied_stagger)
	_smoothed_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	if _state == State.DISENGAGE or _state == State.RECOVER:
		_set_state(State.ENGAGE if _is_in_attack_range() else State.CHASE)


func is_staggered() -> bool:
	return _stagger_remaining > 0.0 and not _is_attack_committed()


func _is_attack_committed() -> bool:
	if _attack_phase == AttackPhase.NONE:
		return false
	if _get_archetype() == VerticalSliceArchetypePresets.Archetype.SCOUT:
		return false
	if _attack_phase == AttackPhase.LUNGE:
		return true
	if _attack_phase == AttackPhase.WINDUP:
		var progress := 1.0 - (_attack_phase_remaining / maxf(engage_windup, 0.001))
		return progress >= attack_commit_ratio
	return false


func _compute_brute_knockback(knockback_distance: float) -> float:
	if knockback_distance <= 26.0:
		return 0.0
	return knockback_distance * 0.35


func _apply_collision_aware_knockback(direction: Vector2, distance: float) -> void:
	CharacterWallRecovery.nudge_with_collision(self, direction, distance)


func _get_body_radius() -> float:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or shape_node.shape == null:
		return BODY_RADIUS
	if shape_node.shape is CircleShape2D:
		return (shape_node.shape as CircleShape2D).radius * maxf(scale.x, scale.y)
	return BODY_RADIUS


func _direction_to_player() -> Vector2:
	if _player == null:
		return Vector2.RIGHT
	var offset := _player.global_position - global_position
	if offset.length_squared() >= 1.0:
		return offset.normalized()
	return Vector2.from_angle(_visual.rotation - PI * 0.5).normalized()


func _get_player_combat_distance() -> float:
	if _player == null:
		return INF
	return global_position.distance_to(_player.global_position)


func _is_player_in_attack_range() -> bool:
	var distance := _get_player_combat_distance()
	var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
	return distance <= attack_range * 1.35 or distance <= overlap_reach


func _resolve_player_body_overlap() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var offset := global_position - _player.global_position
	var distance := offset.length()
	var min_sep := _get_body_radius() + PLAYER_BODY_RADIUS - 1.0
	if distance >= min_sep:
		return

	var push_dir := offset.normalized() if distance > 0.01 else _direction_to_player() * -1.0
	if push_dir.length_squared() < 0.01:
		push_dir = Vector2.UP
	var push := push_dir * (min_sep - distance)

	if _attack_phase != AttackPhase.NONE:
		if _get_archetype() == VerticalSliceArchetypePresets.Archetype.BRUTE:
			CharacterWallRecovery.nudge_with_collision(self, push_dir, push.length() * 0.18)
		return

	if _get_archetype() == VerticalSliceArchetypePresets.Archetype.BRUTE:
		CharacterWallRecovery.nudge_with_collision(self, push_dir, push.length() * 0.28)
	else:
		CharacterWallRecovery.nudge_with_collision(self, push_dir, push.length() * 0.55)


func _process_attack_phase(delta: float) -> void:
	_attack_phase_remaining = maxf(_attack_phase_remaining - delta, 0.0)

	match _attack_phase:
		AttackPhase.WINDUP:
			velocity = Vector2.ZERO
			_smoothed_velocity = Vector2.ZERO
			move_and_slide()
			var windup_ratio := 1.0 - (_attack_phase_remaining / maxf(engage_windup, 0.001))
			var flash := 1.0 + sin(windup_ratio * PI * 4.0) * 0.18
			_visual.modulate = Color(flash, flash * 0.85, flash * 0.75, 1.0)
			if _attack_phase_remaining <= 0.0:
				_begin_attack_lunge()
		AttackPhase.LUNGE:
			var step := attack_lunge_distance / maxf(attack_lunge_duration, 0.001) * delta
			var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
			if _get_player_combat_distance() > overlap_reach * 0.92:
				var move := _attack_lunge_dir * step
				var collision := move_and_collide(move)
				if collision:
					var slide := move.slide(collision.get_normal())
					if slide.length_squared() > 0.25:
						move_and_collide(slide)
				_attack_lunge_traveled += step
			else:
				_attack_lunge_traveled += step
			velocity = _attack_lunge_dir * (step / maxf(delta, 0.0001))
			move_and_slide()
			_visual.modulate = Color(1.25, 0.55, 0.45, 1.0)
			if _attack_phase_remaining <= 0.0 or _attack_lunge_traveled >= attack_lunge_distance:
				_resolve_attack_hit()


func _begin_attack_windup() -> void:
	if _player == null:
		return
	_attack_phase = AttackPhase.WINDUP
	_attack_phase_remaining = engage_windup
	_attack_resolved = false
	_attack_lunge_traveled = 0.0
	_attack_lunge_dir = _direction_to_player()
	if _attack_lunge_dir.length_squared() < 0.01:
		_attack_lunge_dir = Vector2.RIGHT


func _begin_attack_lunge() -> void:
	_attack_phase = AttackPhase.LUNGE
	_attack_phase_remaining = attack_lunge_duration
	_attack_lunge_dir = _direction_to_player()


func _resolve_attack_hit() -> void:
	if _attack_resolved:
		_finish_attack()
		return
	_attack_resolved = true

	if _player != null and is_instance_valid(_player):
		if _is_player_in_attack_range() and not _is_player_untargetable():
			var player_health := _player.get_node_or_null("Health") as Health
			if player_health != null and player_health.is_alive():
				player_health.take_damage(attack_damage)
				if _player.has_method("apply_combat_hit_reaction"):
					_player.apply_combat_hit_reaction(
						global_position,
						player_hit_knockback,
						player_hit_stagger
					)
				attacked_player.emit()

	_visual.modulate = Color(1.4, 0.35, 0.3, 1.0)
	_finish_attack()


func _finish_attack() -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_attack_cooldown_remaining = attack_cooldown
	_smoothed_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	_visual.modulate = Color.WHITE

	match _get_archetype():
		VerticalSliceArchetypePresets.Archetype.SCOUT:
			_scout_time_since_attack = 0.0
			if disengage_duration > 0.0:
				_disengage_remaining = disengage_duration
				_set_state(State.DISENGAGE)
		VerticalSliceArchetypePresets.Archetype.BRUTE:
			_attack_cooldown_remaining += post_attack_cooldown_bonus
			if post_attack_recovery > 0.0:
				_recover_remaining = post_attack_recovery
				_set_state(State.RECOVER)


func _cancel_attack() -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_attack_resolved = false
	_visual.modulate = Color.WHITE


func _update_state() -> void:
	if _player == null:
		_set_state(State.IDLE)
		return

	if _is_player_untargetable():
		if _attack_phase != AttackPhase.NONE:
			_cancel_attack()
		_set_state(State.IDLE)
		return

	if _state == State.DISENGAGE:
		if _disengage_remaining <= 0.0:
			if _get_archetype() == VerticalSliceArchetypePresets.Archetype.SCOUT:
				_scout_probe_burst_remaining = 0.0
			_set_state(State.CHASE if not _is_in_attack_range() else State.ENGAGE)
		return

	if _state == State.RECOVER:
		if _recover_remaining <= 0.0:
			pass
		else:
			return

	var distance := global_position.distance_to(_player.global_position)

	match _state:
		State.IDLE:
			if distance <= detection_radius:
				_set_state(State.CHASE)
		State.CHASE, State.ENGAGE, State.RECOVER:
			if distance > lose_radius:
				_set_state(State.IDLE)
			elif _is_in_attack_range():
				_set_state(State.ENGAGE)
			else:
				_set_state(State.CHASE)


func _apply_movement(delta: float) -> void:
	if _is_player_untargetable():
		_smoothed_velocity = Vector2.ZERO
		velocity = Vector2.ZERO
		_wall_stuck_timer = CharacterWallRecovery.move_with_recovery(self, Vector2.ZERO, _wall_stuck_timer, delta)
		return

	var target_velocity := Vector2.ZERO
	var archetype := _get_archetype()

	match _state:
		State.IDLE:
			target_velocity = Vector2.ZERO
		State.DISENGAGE:
			if _player:
				target_velocity = EnemyCombatSteering.compute_scout_disengage_velocity(
					self, _player.global_position, disengage_speed
				)
		State.RECOVER:
			target_velocity = Vector2.ZERO
		State.CHASE:
			if _player:
				target_velocity = _compute_chase_velocity(archetype)
		State.ENGAGE:
			_try_begin_attack()
			if _player:
				target_velocity = _compute_engage_velocity(archetype)

	var blend := 1.0 - exp(-steer_smoothing * delta)
	if archetype == VerticalSliceArchetypePresets.Archetype.SCOUT:
		blend = 1.0 - exp(-steer_smoothing * 2.6 * delta)
	_smoothed_velocity = _smoothed_velocity.lerp(target_velocity, blend)
	velocity = _smoothed_velocity
	_wall_stuck_timer = CharacterWallRecovery.move_with_recovery(
		self, _smoothed_velocity, _wall_stuck_timer, delta
	)
	_resolve_player_body_overlap()


func _compute_chase_velocity(archetype: VerticalSliceArchetypePresets.Archetype) -> Vector2:
	if archetype == VerticalSliceArchetypePresets.Archetype.SCOUT:
		return _compute_scout_probe_velocity()
	return EnemyCombatSteering.compute_chase_velocity(
		self,
		_player.global_position,
		chase_speed,
		slot_standoff,
	)


func _compute_engage_velocity(archetype: VerticalSliceArchetypePresets.Archetype) -> Vector2:
	if _state == State.RECOVER:
		return Vector2.ZERO
	if archetype == VerticalSliceArchetypePresets.Archetype.SCOUT:
		return _compute_scout_probe_velocity()
	return EnemyCombatSteering.compute_engage_velocity(
		self,
		_player.global_position,
		attack_range,
		engage_reposition_speed,
		slot_standoff,
	)


func _compute_scout_probe_velocity() -> Vector2:
	var probe_speed := chase_speed
	if _state == State.ENGAGE:
		probe_speed = maxf(chase_speed, engage_reposition_speed * 1.08)
	var result := EnemyCombatSteering.compute_scout_probe_velocity(
		self,
		_player.global_position,
		attack_range,
		probe_speed,
		_scout_probe_burst_remaining,
		_scout_probe_burst_dir,
		_scout_time_since_attack,
	)
	_scout_probe_burst_dir = result.get("burst_dir", _scout_probe_burst_dir)
	_scout_probe_burst_remaining = result.get("burst_remaining", 0.0)
	return result.get("velocity", Vector2.ZERO)


func _try_begin_attack() -> void:
	if _attack_phase != AttackPhase.NONE:
		return
	if _stagger_remaining > 0.0 or _player == null:
		return
	if _state == State.DISENGAGE or _state == State.RECOVER:
		return

	var archetype := _get_archetype()
	var cooldown_ok := _attack_cooldown_remaining <= 0.0
	var range_limit := attack_range

	if archetype == VerticalSliceArchetypePresets.Archetype.SCOUT:
		var pressure := clampf(_scout_time_since_attack / 2.0, 0.0, 1.0)
		range_limit = attack_range * (1.0 + pressure * 0.16)
		if _scout_time_since_attack > 1.4:
			cooldown_ok = _attack_cooldown_remaining <= attack_cooldown * 0.35
		if _scout_time_since_attack > 2.2:
			cooldown_ok = true

	if not cooldown_ok:
		return

	if global_position.distance_to(_player.global_position) > range_limit:
		var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
		if _get_player_combat_distance() > overlap_reach:
			return

	if not EnemyCombatSteering.has_clear_attack_line(self, _player.global_position):
		var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
		if _get_player_combat_distance() > overlap_reach:
			return

	var player_health := _player.get_node_or_null("Health") as Health
	if player_health == null or not player_health.is_alive():
		return

	_begin_attack_windup()


func _set_state(new_state: State) -> void:
	if _state == new_state:
		return

	if new_state == State.ENGAGE and _state != State.ENGAGE:
		_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, engage_windup * 0.35)

	if _state == State.IDLE and new_state == State.CHASE:
		player_detected.emit()
		if _get_archetype() == VerticalSliceArchetypePresets.Archetype.SCOUT:
			_scout_time_since_attack = 0.0
			_scout_probe_burst_remaining = 0.0
	elif new_state == State.IDLE:
		player_lost.emit()

	_state = new_state


func _update_facing(delta: float) -> void:
	var face_dir := Vector2.ZERO

	if _player != null:
		if _attack_phase != AttackPhase.NONE or _state == State.ENGAGE or _stagger_remaining > 0.0:
			face_dir = _player.global_position - global_position
		elif _state == State.DISENGAGE:
			face_dir = -(_player.global_position - global_position)
		elif _smoothed_velocity.length_squared() > 16.0:
			face_dir = _smoothed_velocity

	if face_dir.length_squared() < 1.0 and _player != null and _state != State.DISENGAGE:
		face_dir = _player.global_position - global_position

	if face_dir.length_squared() <= 1.0:
		return

	var target_rotation := face_dir.angle() + PI * 0.5
	var turn_blend := 1.0 - exp(-facing_smoothing * delta)
	_visual.rotation = lerp_angle(_visual.rotation, target_rotation, turn_blend)

	var accent := get_node_or_null("ArchetypeAccent") as Polygon2D
	if accent != null:
		accent.rotation = _visual.rotation


func is_chasing_player() -> bool:
	return _state == State.CHASE or _state == State.DISENGAGE


func is_engaging_player() -> bool:
	return _state == State.ENGAGE or _state == State.RECOVER


func _is_in_attack_range() -> bool:
	if _player == null:
		return false
	var distance := _get_player_combat_distance()
	var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
	return distance <= attack_range * 1.05 or distance <= overlap_reach


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_player = null
		return
	_player = players[0] as Node2D


func _is_player_untargetable() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	if _player.has_method("is_in_combat_safe_zone"):
		return _player.is_in_combat_safe_zone()
	return false


func _get_archetype() -> VerticalSliceArchetypePresets.Archetype:
	if has_meta("slice_archetype"):
		return get_meta("slice_archetype") as VerticalSliceArchetypePresets.Archetype
	return VerticalSliceArchetypePresets.Archetype.RAIDER


func get_weapon_identity() -> WeaponIdentity.Id:
	if has_meta("weapon_identity"):
		return get_meta("weapon_identity") as WeaponIdentity.Id
	return WeaponIdentity.from_archetype(_get_archetype())


func _on_died() -> void:
	if is_dead:
		return
	is_dead = true
	_cancel_attack()
	enemy_died.emit(self)

	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	set_physics_process(false)
	_visual.modulate = Color(0.35, 0.35, 0.35, 0.5)

	if is_instance_valid(self) and not is_queued_for_deletion():
		await get_tree().create_timer(0.4).timeout
		if is_instance_valid(self) and not is_queued_for_deletion():
			queue_free()

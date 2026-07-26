extends CharacterBody2D
## Enemy AI with slice archetype behaviors: Scout (skirmish), Raider (baseline), Brute (control check).

const EnemyWeaponStyle := preload("res://scripts/enemies/enemy_weapon_visual_style.gd")

signal player_detected
signal player_lost
signal attacked_player
signal enemy_died(enemy: Node)


enum State { IDLE, CHASE, ENGAGE, DISENGAGE, RECOVER }
enum AttackPhase { NONE, WINDUP, LUNGE, RUSH_WINDUP, RUSH }

const BODY_RADIUS := 14.0
const PLAYER_BODY_RADIUS := 14.0
const KNOCKBACK_IMMUNITY_DURATION := 0.20
const RUSH_COMMIT_RATIO := 0.55


@export var max_health: float = 40.0
@export var detection_radius: float = 220.0
@export var lose_radius: float = 320.0
@export var chase_speed: float = 100.0
@export var attack_range: float = 36.0
@export var attack_damage: float = 10.0
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
## Soft dragon peel — player remains primary; dragon draws pressure when meaningful.
@export var dragon_target_weight: float = 0.75
@export var player_target_weight: float = 1.25
## Score margin required to abandon current target (1.0 = any higher score).
@export var target_switch_hysteresis: float = 1.22
@export var retarget_interval: float = 0.40
## Soft distance falloff scale — avoids "closest body always wins".
@export var distance_softness: float = 70.0
@export var dragon_close_bonus_distance: float = 55.0
@export var dragon_body_radius: float = 22.0
@export var dragon_hit_recent_window: float = 3.5
## Minimum time to keep a chosen target before a score-based switch (invalid targets ignore this).
@export var min_target_commitment: float = 0.55
## Force reassess if current target stays outside useful range this long.
@export var max_stale_out_of_range: float = 2.2
## Force reassess if distance to current target fails to improve for this long.
@export var max_stale_no_progress: float = 1.8
@export var progress_epsilon: float = 8.0

## Scout — probe / disengage after each strike.
@export var disengage_duration: float = 0.0
@export var disengage_speed: float = 0.0
@export var circle_bias: float = 0.0

## Brute — committed strike recovery after each attack.
@export var post_attack_recovery: float = 0.0
@export var post_attack_cooldown_bonus: float = 0.0

## Brute charged rush (Combat Identity Pass 1).
@export var rush_min_distance: float = 88.0
@export var rush_max_distance: float = 195.0
@export var rush_windup_duration: float = 0.78
@export var rush_speed: float = 340.0
@export var rush_max_duration: float = 0.48
@export var rush_cooldown: float = 5.5
@export var rush_damage_multiplier: float = 1.15
@export var rush_knockback: float = 58.0
@export var rush_stagger: float = 0.78
@export var rush_recovery: float = 0.9
@export var rush_turn_rate: float = 1.1

## Pass 1B — wind-up progress (0–1) after which the current swing cannot be cancelled.
@export var attack_commit_ratio: float = 0.45
## Pass 1B — multiplier applied to incoming hit stagger (Scout > 1, Brute < 1).
@export var hit_stagger_multiplier: float = 1.0

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _state: State = State.IDLE
var _player: Node2D
var _dragon: Node2D
var _combat_target: Node2D
var _retarget_remaining: float = 0.0
var _dragon_hit_recent_remaining: float = 0.0
var _target_commitment_remaining: float = 0.0
var _stale_out_of_range_time: float = 0.0
var _stale_no_progress_time: float = 0.0
var _last_focus_distance: float = INF
var _attack_cooldown_remaining: float = 0.0
var _rush_cooldown_remaining: float = 0.0
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
var _base_visual_scale: Vector2 = Vector2.ONE
var is_dead: bool = false
var _weapon_pivot: Node2D
var _weapon_blade: Polygon2D
var _weapon_style: Dictionary = {}
var _weapon_rest_angle: float = 0.0

# Scout probe — short bursts while searching for openings.
var _scout_probe_burst_remaining: float = 0.0
var _scout_probe_burst_dir: Vector2 = Vector2.RIGHT
var _scout_time_since_attack: float = 0.0
var _knockback_immunity_remaining: float = 0.0
var _wall_stuck_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	collision_mask = 1
	_health.max_health = max_health
	_health.current_health = max_health
	_health.died.connect(_on_died)
	_base_visual_color = _visual.color
	_base_visual_scale = _visual.scale
	_find_player()
	_find_dragon()
	_combat_target = _player
	_ensure_weapon_visual()
	_apply_weapon_style_for_archetype(_get_archetype())


func apply_weapon_visual_for_archetype(archetype: VerticalSliceArchetypePresets.Archetype) -> void:
	_ensure_weapon_visual()
	_apply_weapon_style_for_archetype(archetype)
	if _visual != null:
		_base_visual_scale = _visual.scale
		_base_visual_color = _visual.color


func _physics_process(delta: float) -> void:
	if is_dead or not _health.is_alive():
		return

	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)
	_disengage_remaining = maxf(_disengage_remaining - delta, 0.0)
	_recover_remaining = maxf(_recover_remaining - delta, 0.0)
	_knockback_immunity_remaining = maxf(_knockback_immunity_remaining - delta, 0.0)
	_retarget_remaining = maxf(_retarget_remaining - delta, 0.0)
	_dragon_hit_recent_remaining = maxf(_dragon_hit_recent_remaining - delta, 0.0)
	_target_commitment_remaining = maxf(_target_commitment_remaining - delta, 0.0)
	_rush_cooldown_remaining = maxf(_rush_cooldown_remaining - delta, 0.0)
	_tick_target_staleness(delta)

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
	if _dragon == null or not is_instance_valid(_dragon):
		_find_dragon()
	_refresh_combat_target()

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
	if _attack_phase == AttackPhase.LUNGE or _attack_phase == AttackPhase.RUSH:
		return true
	if _attack_phase == AttackPhase.RUSH_WINDUP:
		var rush_progress := 1.0 - (_attack_phase_remaining / maxf(rush_windup_duration, 0.001))
		return rush_progress >= RUSH_COMMIT_RATIO
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
	return _direction_to_focus()


func _direction_to_focus() -> Vector2:
	var focus := _get_focus_target()
	if focus == null:
		return Vector2.RIGHT
	var offset := focus.global_position - global_position
	if offset.length_squared() >= 1.0:
		return offset.normalized()
	return Vector2.from_angle(_visual.rotation - PI * 0.5).normalized()


func _get_focus_target() -> Node2D:
	if _is_valid_combat_target(_combat_target):
		return _combat_target
	if _is_valid_combat_target(_player):
		return _player
	return null


func _get_focus_position() -> Vector2:
	var focus := _get_focus_target()
	if focus != null:
		return focus.global_position
	if _player != null:
		return _player.global_position
	return global_position


func _get_player_combat_distance() -> float:
	if _player == null:
		return INF
	return global_position.distance_to(_player.global_position)


func _get_focus_combat_distance() -> float:
	var focus := _get_focus_target()
	if focus == null:
		return INF
	return global_position.distance_to(focus.global_position)


func _is_player_in_attack_range() -> bool:
	return _is_focus_in_attack_range()


func _is_focus_in_attack_range() -> bool:
	var distance := _get_focus_combat_distance()
	var overlap_reach := _get_body_radius() + _get_focus_body_radius() + 4.0
	return distance <= attack_range * 1.35 or distance <= overlap_reach


func _get_focus_body_radius() -> float:
	var focus := _get_focus_target()
	if focus != null and focus == _dragon:
		return dragon_body_radius
	return PLAYER_BODY_RADIUS


## Called when the dragon successfully damages this enemy — raises temporary peel threat.
func notify_damaged_by_dragon() -> void:
	_dragon_hit_recent_remaining = dragon_hit_recent_window
	# Allow a fresh evaluation soon, but keep a short commitment so we don't thrash.
	_retarget_remaining = minf(_retarget_remaining, 0.12)
	_target_commitment_remaining = minf(_target_commitment_remaining, 0.2)


func _is_valid_combat_target(target: Node2D) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	if target == _player:
		return not _is_player_untargetable()
	if target == _dragon:
		return _dragon != null and _dragon.has_method("is_valid_enemy_target") and _dragon.is_valid_enemy_target()
	return false


func _tick_target_staleness(delta: float) -> void:
	if _attack_phase != AttackPhase.NONE:
		return
	if not _is_valid_combat_target(_combat_target):
		_stale_out_of_range_time = 0.0
		_stale_no_progress_time = 0.0
		_last_focus_distance = INF
		return

	var dist := global_position.distance_to(_combat_target.global_position)
	var useful_range := maxf(attack_range * 1.8, rush_max_distance * 0.55)
	if dist > useful_range:
		_stale_out_of_range_time += delta
	else:
		_stale_out_of_range_time = 0.0

	if _last_focus_distance < INF and dist > _last_focus_distance - progress_epsilon:
		_stale_no_progress_time += delta
	else:
		_stale_no_progress_time = 0.0
	_last_focus_distance = dist

	if _stale_out_of_range_time >= max_stale_out_of_range or _stale_no_progress_time >= max_stale_no_progress:
		_retarget_remaining = 0.0
		_target_commitment_remaining = 0.0
		_stale_out_of_range_time = 0.0
		_stale_no_progress_time = 0.0


func _set_combat_target(next: Node2D) -> void:
	if next == _combat_target:
		return
	_combat_target = next
	_target_commitment_remaining = min_target_commitment
	_stale_out_of_range_time = 0.0
	_stale_no_progress_time = 0.0
	_last_focus_distance = INF if next == null else global_position.distance_to(next.global_position)


func _refresh_combat_target() -> void:
	# Invalid target (KO dragon, safe-zone player, etc.) always clears immediately.
	if not _is_valid_combat_target(_combat_target):
		var fallback: Node2D = _player if _is_valid_combat_target(_player) else null
		if fallback == null and _is_valid_combat_target(_dragon):
			fallback = _dragon
		_set_combat_target(fallback)
		_retarget_remaining = 0.0

	if _retarget_remaining > 0.0:
		return
	_retarget_remaining = retarget_interval

	var player_valid := _is_valid_combat_target(_player)
	var dragon_valid := _is_valid_combat_target(_dragon)
	if not player_valid and not dragon_valid:
		_set_combat_target(null)
		return
	if player_valid and not dragon_valid:
		_set_combat_target(_player)
		return
	if dragon_valid and not player_valid:
		_set_combat_target(_dragon)
		return

	# Player physically intercepting a dragon focus: strong immediate pull (except active rush,
	# which never reaches here because attack phases skip retarget).
	if (
		_combat_target == _dragon
		and player_valid
		and _is_player_intercepting()
	):
		_set_combat_target(_player)
		return

	var player_score := _score_candidate(_player, false)
	var dragon_participating: bool = (
		_dragon != null
		and _dragon.has_method("is_combat_participating")
		and _dragon.is_combat_participating()
	)
	var dragon_score := _score_candidate(_dragon, dragon_participating)

	# Mild sticky bonus — enough to stop jitter, not enough to permanently tunnel.
	if _combat_target == _player:
		player_score *= 1.08
	elif _combat_target == _dragon:
		dragon_score *= 1.08

	var preferred: Node2D = _player if player_score >= dragon_score else _dragon
	if _combat_target == null:
		_set_combat_target(preferred)
		return

	# Hold current target through min commitment unless the challenger is clearly better.
	var current_score := player_score if _combat_target == _player else dragon_score
	var other_score := dragon_score if _combat_target == _player else player_score
	var margin := target_switch_hysteresis
	if _target_commitment_remaining > 0.0:
		margin = maxf(margin, 1.35)
	if other_score > current_score * margin:
		_set_combat_target(preferred)


func _score_candidate(target: Node2D, participating: bool) -> float:
	if target == null or not _is_valid_combat_target(target):
		return -INF

	var distance := maxf(global_position.distance_to(target.global_position), 1.0)
	# Soft falloff: closer helps, but does not dominate like weight/distance.
	var proximity := 1.0 / (1.0 + distance / maxf(distance_softness, 1.0))
	var score := _base_weight_for(target) * (0.55 + 0.45 * proximity)

	var archetype := _get_archetype()

	# Assist/protect participation — meaningful for Raider/Brute, weak for Scout.
	if participating and target == _dragon:
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				score *= 1.12
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				score *= 1.35
			_:
				score *= 1.28

	# Extreme close dragon obstruction only (Scout almost never peels on proximity alone).
	if target == _dragon and distance <= dragon_close_bonus_distance:
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				if distance <= 28.0:
					score *= 1.15
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				score *= 1.28
			_:
				score *= 1.18

	# Mild attack-range bonus for whoever is already in striking distance.
	if distance <= attack_range * 1.35:
		score *= 1.12

	# Dragon clearly much closer than player — Raider/Brute only.
	if target == _dragon and _player != null and archetype != VerticalSliceArchetypePresets.Archetype.SCOUT:
		var player_dist := global_position.distance_to(_player.global_position)
		if distance + 28.0 < player_dist:
			score *= 1.2 if archetype == VerticalSliceArchetypePresets.Archetype.BRUTE else 1.12

	# Recent direct dragon damage — all archetypes, Scout included.
	if target == _dragon and _dragon_hit_recent_remaining > 0.0:
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				score *= 1.55
			_:
				score *= 1.4

	# Dragon blocking the path to the player — Brute/Raider care, Scout barely.
	if target == _dragon and _is_actor_blocking_path(_dragon, _player):
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				score *= 1.08
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				score *= 1.32
			_:
				score *= 1.18

	# Player intercepting a dragon focus / standing in the approach corridor.
	if target == _player and _is_player_intercepting():
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				score *= 1.35
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				score *= 1.75
			_:
				score *= 1.45

	# Immediate attackable player always gets a floor bump.
	if target == _player and distance <= attack_range * 1.25:
		score *= 1.2

	return score


func _base_weight_for(target: Node2D) -> float:
	var archetype := _get_archetype()
	if target == _player:
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				return player_target_weight * 1.45
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				return player_target_weight * 1.05
			_:
				return player_target_weight * 1.15
	if target == _dragon:
		match archetype:
			VerticalSliceArchetypePresets.Archetype.SCOUT:
				return dragon_target_weight * 0.45
			VerticalSliceArchetypePresets.Archetype.BRUTE:
				return dragon_target_weight * 1.05
			_:
				return dragon_target_weight * 0.85
	return 0.0


## True when the player stands in the enemy→dragon approach corridor or is the nearer body in that lane.
func _is_player_intercepting() -> bool:
	if _player == null or _dragon == null:
		return false
	if not _is_valid_combat_target(_player):
		return false
	# Always count as intercept if the player is in immediate melee reach.
	var player_dist := global_position.distance_to(_player.global_position)
	if player_dist <= attack_range * 1.25:
		return true
	if not _is_valid_combat_target(_dragon):
		return false
	return _is_actor_blocking_path(_player, _dragon)


func _is_actor_blocking_path(blocker: Node2D, behind: Node2D) -> bool:
	if blocker == null or behind == null:
		return false
	var to_behind := behind.global_position - global_position
	var behind_dist := to_behind.length()
	if behind_dist < 10.0:
		return false
	var to_blocker := blocker.global_position - global_position
	var blocker_dist := to_blocker.length()
	if blocker_dist < 6.0:
		return true
	# Blocker must be closer than the destination and aligned with the approach.
	if blocker_dist > behind_dist - 4.0:
		return false
	var alignment := to_behind.normalized().dot(to_blocker.normalized())
	if alignment < 0.78:
		return false
	# Lateral distance from the approach ray must be small.
	var lateral := absf(to_blocker.x * to_behind.y - to_blocker.y * to_behind.x) / behind_dist
	return lateral <= 28.0


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
			_update_weapon_attack_pose(windup_ratio, false)
			if _attack_phase_remaining <= 0.0:
				_begin_attack_lunge()
		AttackPhase.LUNGE:
			var step := attack_lunge_distance / maxf(attack_lunge_duration, 0.001) * delta
			var overlap_reach := _get_body_radius() + _get_focus_body_radius() + 4.0
			if _get_focus_combat_distance() > overlap_reach * 0.92:
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
			_update_weapon_attack_pose(1.0, true)
			if _attack_phase_remaining <= 0.0 or _attack_lunge_traveled >= attack_lunge_distance:
				_resolve_attack_hit()
		AttackPhase.RUSH_WINDUP:
			_process_rush_windup(delta)
		AttackPhase.RUSH:
			_process_rush_move(delta)


func _process_rush_windup(_delta: float) -> void:
	velocity = Vector2.ZERO
	_smoothed_velocity = Vector2.ZERO
	move_and_slide()
	var ratio := 1.0 - (_attack_phase_remaining / maxf(rush_windup_duration, 0.001))
	# Crouch / telegraph: darken + slight scale pulse + weapon pull-back.
	var crouch := 1.0 - ratio * 0.08
	_visual.scale = _base_visual_scale * Vector2(crouch, crouch + ratio * 0.06)
	_visual.modulate = Color(0.55 + ratio * 0.2, 0.12, 0.08, 1.0)
	_update_weapon_rush_pose(ratio)
	if _attack_phase_remaining <= 0.0:
		_begin_rush_move()


func _process_rush_move(delta: float) -> void:
	# Limited turn correction toward focus during rush.
	var desired := _direction_to_focus()
	if desired.length_squared() > 0.01:
		_attack_lunge_dir = _attack_lunge_dir.lerp(desired, clampf(rush_turn_rate * delta, 0.0, 1.0)).normalized()

	var move := _attack_lunge_dir * rush_speed * delta
	var collision := move_and_collide(move)
	_attack_lunge_traveled += move.length()
	velocity = _attack_lunge_dir * rush_speed
	_visual.modulate = Color(1.35, 0.4, 0.25, 1.0)
	_visual.scale = _base_visual_scale
	_update_weapon_attack_pose(1.0, true)

	if collision != null:
		_resolve_rush_hit()
		return

	var overlap_reach := _get_body_radius() + _get_focus_body_radius() + 6.0
	if _get_focus_combat_distance() <= overlap_reach:
		_resolve_rush_hit()
		return

	if _attack_phase_remaining <= 0.0 or _attack_lunge_traveled >= rush_speed * rush_max_duration:
		_finish_rush(false)


func _begin_rush_windup() -> void:
	if _get_focus_target() == null:
		return
	_attack_phase = AttackPhase.RUSH_WINDUP
	_attack_phase_remaining = rush_windup_duration
	_attack_resolved = false
	_attack_lunge_traveled = 0.0
	_attack_lunge_dir = _direction_to_focus()
	if _attack_lunge_dir.length_squared() < 0.01:
		_attack_lunge_dir = Vector2.RIGHT
	var audio := get_node_or_null("/root/GameAudio")
	if audio != null and audio.has_method("play"):
		audio.play(GameAudioEvent.Event.BRUTE_HEAVY, global_position)


func _begin_rush_move() -> void:
	_attack_phase = AttackPhase.RUSH
	_attack_phase_remaining = rush_max_duration
	_attack_lunge_dir = _direction_to_focus()
	var audio := get_node_or_null("/root/GameAudio")
	if audio != null and audio.has_method("play"):
		audio.play(GameAudioEvent.Event.PLAYER_SWING, global_position)


func _resolve_rush_hit() -> void:
	if _attack_resolved:
		_finish_rush(true)
		return
	_attack_resolved = true

	var focus := _get_focus_target()
	var damage := attack_damage * rush_damage_multiplier
	if focus != null and _get_focus_combat_distance() <= _get_body_radius() + _get_focus_body_radius() + 10.0:
		if focus == _player and not _is_player_untargetable():
			var player_health := _player.get_node_or_null("Health") as Health
			if player_health != null and player_health.is_alive():
				player_health.take_damage(damage)
				if _player.has_method("apply_combat_hit_reaction"):
					_player.apply_combat_hit_reaction(global_position, rush_knockback, rush_stagger)
				attacked_player.emit()
		elif focus == _dragon and _is_valid_combat_target(_dragon):
			var survivability := _dragon.get_node_or_null("Survivability") as DragonSurvivability
			if survivability != null:
				survivability.receive_damage(damage)

	_visual.modulate = Color(1.5, 0.3, 0.2, 1.0)
	_finish_rush(true)


func _finish_rush(did_hit: bool) -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_rush_cooldown_remaining = rush_cooldown
	_attack_cooldown_remaining = maxf(attack_cooldown, 0.35)
	_smoothed_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	_visual.modulate = Color.WHITE
	_visual.scale = _base_visual_scale
	_reset_weapon_pose()
	_recover_remaining = rush_recovery if did_hit else rush_recovery * 1.15
	_set_state(State.RECOVER)


func _begin_attack_windup() -> void:
	if _get_focus_target() == null:
		return
	_attack_phase = AttackPhase.WINDUP
	_attack_phase_remaining = engage_windup
	_attack_resolved = false
	_attack_lunge_traveled = 0.0
	_attack_lunge_dir = _direction_to_focus()
	if _attack_lunge_dir.length_squared() < 0.01:
		_attack_lunge_dir = Vector2.RIGHT


func _begin_attack_lunge() -> void:
	_attack_phase = AttackPhase.LUNGE
	_attack_phase_remaining = attack_lunge_duration
	_attack_lunge_dir = _direction_to_focus()


func _resolve_attack_hit() -> void:
	if _attack_resolved:
		_finish_attack()
		return
	_attack_resolved = true

	var focus := _get_focus_target()
	if focus != null and _is_focus_in_attack_range():
		if focus == _player and not _is_player_untargetable():
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
		elif focus == _dragon and _is_valid_combat_target(_dragon):
			var survivability := _dragon.get_node_or_null("Survivability") as DragonSurvivability
			if survivability != null:
				survivability.receive_damage(attack_damage)

	_visual.modulate = Color(1.4, 0.35, 0.3, 1.0)
	_finish_attack()


func _finish_attack() -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_attack_cooldown_remaining = attack_cooldown
	_smoothed_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	_visual.modulate = Color.WHITE
	_visual.scale = _base_visual_scale
	_reset_weapon_pose()

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
	_visual.scale = _base_visual_scale
	_reset_weapon_pose()


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
		_get_focus_position(),
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
		_get_focus_position(),
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
		_get_focus_position(),
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
	if _stagger_remaining > 0.0 or _get_focus_target() == null:
		return
	if _state == State.DISENGAGE or _state == State.RECOVER:
		return

	var archetype := _get_archetype()
	var focus_dist := _get_focus_combat_distance()

	# Brute charged rush at medium range before falling back to melee.
	if (
		archetype == VerticalSliceArchetypePresets.Archetype.BRUTE
		and _rush_cooldown_remaining <= 0.0
		and focus_dist >= rush_min_distance
		and focus_dist <= rush_max_distance
	):
		var focus := _get_focus_target()
		if focus == _player:
			var player_health := _player.get_node_or_null("Health") as Health
			if player_health == null or not player_health.is_alive():
				return
		elif focus == _dragon and not _is_valid_combat_target(_dragon):
			return
		if EnemyCombatSteering.has_clear_attack_line(self, _get_focus_position()):
			_begin_rush_windup()
			return

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

	var focus_pos := _get_focus_position()
	if global_position.distance_to(focus_pos) > range_limit:
		var overlap_reach := _get_body_radius() + _get_focus_body_radius() + 4.0
		if _get_focus_combat_distance() > overlap_reach:
			return

	if not EnemyCombatSteering.has_clear_attack_line(self, focus_pos):
		var overlap_reach := _get_body_radius() + _get_focus_body_radius() + 4.0
		if _get_focus_combat_distance() > overlap_reach:
			return

	var focus_target := _get_focus_target()
	if focus_target == _player:
		var player_health2 := _player.get_node_or_null("Health") as Health
		if player_health2 == null or not player_health2.is_alive():
			return
	elif focus_target == _dragon and not _is_valid_combat_target(_dragon):
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
	var focus := _get_focus_target()
	var look_at := focus if focus != null else _player

	if look_at != null:
		if _attack_phase != AttackPhase.NONE or _state == State.ENGAGE or _stagger_remaining > 0.0:
			face_dir = look_at.global_position - global_position
		elif _state == State.DISENGAGE and _player != null:
			face_dir = -(_player.global_position - global_position)
		elif _smoothed_velocity.length_squared() > 16.0:
			face_dir = _smoothed_velocity

	if face_dir.length_squared() < 1.0 and look_at != null and _state != State.DISENGAGE:
		face_dir = look_at.global_position - global_position

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
	var distance := _get_focus_combat_distance()
	if distance == INF:
		return false
	var overlap_reach := _get_body_radius() + PLAYER_BODY_RADIUS + 4.0
	return distance <= attack_range * 1.05 or distance <= overlap_reach


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_player = null
		return
	_player = players[0] as Node2D


func _find_dragon() -> void:
	var dragons := get_tree().get_nodes_in_group("dragon")
	if dragons.is_empty():
		_dragon = null
		return
	_dragon = dragons[0] as Node2D


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


func _ensure_weapon_visual() -> void:
	if _visual == null:
		return
	_weapon_pivot = _visual.get_node_or_null("WeaponPivot") as Node2D
	if _weapon_pivot == null:
		_weapon_pivot = Node2D.new()
		_weapon_pivot.name = "WeaponPivot"
		_visual.add_child(_weapon_pivot)
	_weapon_blade = _weapon_pivot.get_node_or_null("WeaponBlade") as Polygon2D
	if _weapon_blade == null:
		_weapon_blade = Polygon2D.new()
		_weapon_blade.name = "WeaponBlade"
		_weapon_blade.z_index = 1
		_weapon_pivot.add_child(_weapon_blade)


func _apply_weapon_style_for_archetype(archetype: VerticalSliceArchetypePresets.Archetype) -> void:
	_ensure_weapon_visual()
	if _weapon_blade == null or _weapon_pivot == null:
		return
	_weapon_style = EnemyWeaponStyle.style_for_archetype(int(archetype))
	_weapon_blade.polygon = _weapon_style.get("blade_polygon", PackedVector2Array())
	_weapon_blade.color = _weapon_style.get("blade_color", Color.WHITE)
	_weapon_blade.scale = _weapon_style.get("blade_scale", Vector2.ONE)
	_reset_weapon_pose()


func _reset_weapon_pose() -> void:
	if _weapon_pivot == null or _weapon_style.is_empty():
		return
	_weapon_pivot.position = _weapon_style.get("rest_offset", Vector2(12.0, 0.0))
	_weapon_rest_angle = deg_to_rad(float(_weapon_style.get("rest_angle_deg", 0.0)))
	_weapon_pivot.rotation = _weapon_rest_angle


func _update_weapon_attack_pose(ratio: float, striking: bool) -> void:
	if _weapon_pivot == null or _weapon_style.is_empty():
		return
	var windup_deg := float(_weapon_style.get("windup_angle_deg", -40.0))
	var strike_deg := float(_weapon_style.get("strike_angle_deg", 45.0))
	var angle_deg := strike_deg if striking else lerpf(float(_weapon_style.get("rest_angle_deg", 0.0)), windup_deg, ratio)
	_weapon_pivot.rotation = deg_to_rad(angle_deg)


func _update_weapon_rush_pose(ratio: float) -> void:
	if _weapon_pivot == null or _weapon_style.is_empty():
		return
	var pull := float(_weapon_style.get("rush_windup_angle_deg", _weapon_style.get("windup_angle_deg", -55.0)))
	_weapon_pivot.rotation = deg_to_rad(lerpf(float(_weapon_style.get("rest_angle_deg", 0.0)), pull, ratio))
	_weapon_pivot.position = _weapon_style.get("rest_offset", Vector2(12.0, 0.0)) + Vector2(-4.0 * ratio, 2.0 * ratio)


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

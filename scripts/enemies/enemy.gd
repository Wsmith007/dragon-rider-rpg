extends CharacterBody2D
## Basic enemy: idle, detect player, chase with spread, engage with light reposition.
##
## Speed exports are tuned for the default prototype enemy. Future enemy types should override
## chase_speed / engage_reposition_speed per archetype (heavy=slow, scout=fast, beast=burst, etc.).

signal player_detected
signal player_lost
signal attacked_player
signal enemy_died(enemy: Node)


enum State { IDLE, CHASE, ENGAGE }


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
@export var steer_smoothing: float = 10.0
@export var facing_smoothing: float = 14.0

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _state: State = State.IDLE
var _player: Node2D
var _attack_cooldown_remaining: float = 0.0
var _stagger_remaining: float = 0.0
var _smoothed_velocity: Vector2 = Vector2.ZERO
var is_dead: bool = false


func _ready() -> void:
	add_to_group("enemy")
	collision_mask = 1
	_health.max_health = max_health
	_health.current_health = max_health
	_health.died.connect(_on_died)
	_find_player()


func _physics_process(delta: float) -> void:
	if is_dead or not _health.is_alive():
		return

	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)

	if _stagger_remaining > 0.0:
		_stagger_remaining = maxf(_stagger_remaining - delta, 0.0)
		_smoothed_velocity = Vector2.ZERO
		velocity = Vector2.ZERO
		move_and_slide()
		_update_facing(delta)
		return

	if _player == null or not is_instance_valid(_player):
		_find_player()

	_update_state()
	_apply_movement(delta)
	_update_facing(delta)


func apply_hit_reaction(direction: Vector2, knockback_distance: float, stagger_duration: float) -> void:
	if is_dead or stagger_duration <= 0.0:
		return

	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT

	var applied_knockback := knockback_distance / maxf(knockback_resistance, 0.01)
	global_position += direction.normalized() * applied_knockback
	_stagger_remaining = maxf(_stagger_remaining, stagger_duration)
	_smoothed_velocity = Vector2.ZERO
	velocity = Vector2.ZERO


func is_staggered() -> bool:
	return _stagger_remaining > 0.0


func _update_state() -> void:
	if _player == null:
		_set_state(State.IDLE)
		return

	var distance := global_position.distance_to(_player.global_position)

	match _state:
		State.IDLE:
			if distance <= detection_radius:
				_set_state(State.CHASE)
		State.CHASE, State.ENGAGE:
			if distance > lose_radius:
				_set_state(State.IDLE)
			elif distance <= attack_range * 1.05:
				_set_state(State.ENGAGE)
			else:
				_set_state(State.CHASE)


func _apply_movement(delta: float) -> void:
	var target_velocity := Vector2.ZERO

	match _state:
		State.IDLE:
			target_velocity = Vector2.ZERO
		State.CHASE:
			if _player:
				target_velocity = EnemyCombatSteering.compute_chase_velocity(
					self,
					_player.global_position,
					chase_speed,
					slot_standoff
				)
		State.ENGAGE:
			_try_attack_player()
			if _player:
				target_velocity = EnemyCombatSteering.compute_engage_velocity(
					self,
					_player.global_position,
					attack_range,
					engage_reposition_speed,
					slot_standoff
				)

	var blend := 1.0 - exp(-steer_smoothing * delta)
	_smoothed_velocity = _smoothed_velocity.lerp(target_velocity, blend)
	velocity = _smoothed_velocity
	move_and_slide()


func _try_attack_player() -> void:
	if _stagger_remaining > 0.0 or _attack_cooldown_remaining > 0.0 or _player == null:
		return

	if global_position.distance_to(_player.global_position) > attack_range:
		return

	if not EnemyCombatSteering.has_clear_attack_line(self, _player.global_position):
		return

	var player_health := _player.get_node_or_null("Health") as Health
	if player_health == null or not player_health.is_alive():
		return

	player_health.take_damage(attack_damage)
	_attack_cooldown_remaining = attack_cooldown
	attacked_player.emit()


func _set_state(new_state: State) -> void:
	if _state == new_state:
		return

	if new_state == State.ENGAGE and _state != State.ENGAGE:
		_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, engage_windup)

	if _state == State.IDLE and new_state == State.CHASE:
		player_detected.emit()
	elif new_state == State.IDLE:
		player_lost.emit()

	_state = new_state


func _update_facing(delta: float) -> void:
	var face_dir := Vector2.ZERO

	if _player != null:
		if _state == State.ENGAGE or _stagger_remaining > 0.0:
			face_dir = _player.global_position - global_position
		elif _smoothed_velocity.length_squared() > 16.0:
			face_dir = _smoothed_velocity

	if face_dir.length_squared() < 1.0 and _player != null:
		face_dir = _player.global_position - global_position

	if face_dir.length_squared() <= 1.0:
		return

	var target_rotation := face_dir.angle() + PI * 0.5
	var turn_blend := 1.0 - exp(-facing_smoothing * delta)
	_visual.rotation = lerp_angle(_visual.rotation, target_rotation, turn_blend)


func is_chasing_player() -> bool:
	return _state == State.CHASE


func is_engaging_player() -> bool:
	return _state == State.ENGAGE


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_player = null
		return
	_player = players[0] as Node2D


func _on_died() -> void:
	if is_dead:
		return
	is_dead = true
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

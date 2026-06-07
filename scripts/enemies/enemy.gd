extends CharacterBody2D
## Basic enemy: idle, detect player, chase, melee with cooldown.

signal player_detected
signal player_lost
signal attacked_player
signal enemy_died(enemy: Node)


enum State { IDLE, CHASE, ENGAGE }


@export var max_health: float = 150.0
@export var detection_radius: float = 220.0
@export var lose_radius: float = 320.0
@export var chase_speed: float = 130.0
@export var attack_range: float = 36.0
@export var attack_damage: float = 12.0
@export var attack_cooldown: float = 1.0
@export var engage_windup: float = 0.45

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _state: State = State.IDLE
var _player: Node2D
var _attack_cooldown_remaining: float = 0.0
var is_dead: bool = false


func _ready() -> void:
	add_to_group("enemy")
	_health.max_health = max_health
	_health.current_health = max_health
	_health.died.connect(_on_died)
	_find_player()


func _physics_process(delta: float) -> void:
	if is_dead or not _health.is_alive():
		return

	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)

	if _player == null or not is_instance_valid(_player):
		_find_player()

	_update_state()
	_apply_movement(delta)
	_update_facing()


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
			elif distance <= attack_range:
				_set_state(State.ENGAGE)
			else:
				_set_state(State.CHASE)


func _apply_movement(_delta: float) -> void:
	match _state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.CHASE:
			if _player:
				velocity = global_position.direction_to(_player.global_position) * chase_speed
		State.ENGAGE:
			_try_attack_player()
			velocity = Vector2.ZERO

	move_and_slide()


func _try_attack_player() -> void:
	if _attack_cooldown_remaining > 0.0 or _player == null:
		return

	if global_position.distance_to(_player.global_position) > attack_range:
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


func _update_facing() -> void:
	if velocity.length_squared() > 1.0:
		_visual.rotation = velocity.angle() + PI * 0.5


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

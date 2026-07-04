extends CharacterBody2D
## Top-down rider movement, health, and combat signals.

signal moved(velocity: Vector2)
signal player_damaged(current_health: float, maximum_health: float)
signal player_died


@export var move_speed: float = 220.0
@export var max_health: float = 1000.0

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _is_dead: bool = false
var _facing_direction: Vector2 = Vector2.DOWN
var _move_speed_multiplier: float = 1.0
var _combat_stagger_remaining: float = 0.0
var _combat_safe_zone: bool = false
var _relationship_last_health: float = 0.0
var _relationship_was_critical: bool = false

const RELATIONSHIP_CRITICAL_HP_RATIO := 0.25


func _ready() -> void:
	add_to_group("player")
	_health.max_health = max_health
	_health.current_health = max_health
	_relationship_last_health = max_health
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity = Vector2.ZERO
		return

	if _combat_stagger_remaining > 0.0:
		_combat_stagger_remaining = maxf(_combat_stagger_remaining - delta, 0.0)
		velocity = Vector2.ZERO
		move_and_slide()
		if _combat_stagger_remaining <= 0.0:
			reset_attack_move_speed_multiplier()
			_visual.modulate = Color.WHITE
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed * _move_speed_multiplier
	move_and_slide()

	if velocity.length_squared() > 0.0:
		_facing_direction = velocity.normalized()
		moved.emit(velocity)
		_visual.rotation = _facing_direction.angle() + PI * 0.5


func get_facing_direction() -> Vector2:
	if velocity.length_squared() > 16.0:
		return velocity.normalized()
	if _facing_direction.length_squared() > 0.01:
		return _facing_direction.normalized()
	return Vector2.from_angle(_visual.rotation - PI * 0.5).normalized()


func set_attack_move_speed_multiplier(multiplier: float) -> void:
	_move_speed_multiplier = clampf(multiplier, 0.0, 1.0)


func reset_attack_move_speed_multiplier() -> void:
	_move_speed_multiplier = 1.0


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

	var direction := global_position - from_world_position
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
	var motion := direction.normalized() * distance
	var collision := move_and_collide(motion)
	if collision:
		var slide := motion.slide(collision.get_normal())
		if slide.length_squared() > 1.0:
			move_and_collide(slide)


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
	velocity = Vector2.ZERO
	set_physics_process(false)
	$MeleeAttack.set_physics_process(false)
	RelationshipSystem.record_event(RelationshipEvent.COMBAT_PLAYER_DEATH)
	player_died.emit()
	_visual.modulate = Color(0.6, 0.6, 0.6, 0.75)

extends Node2D
## Pass 7 prototype + weapon profile debug (1/2/3). See docs/combat_feel_notes.md.

signal attack_started
signal attack_hit(enemy: Node2D)
signal weapon_profile_changed(profile_name: String)


@export_group("Weapon Profile (debug)")
@export var weapon_profile: WeaponProfilePrototype.Id = WeaponProfilePrototype.Id.DAGGER


@export_group("Focused Attack")
@export var focused_damage: float = 25.0
@export var focused_knockback: float = 15.0
@export var focused_stagger: float = 0.3
@export var focused_cooldown: float = 0.35
@export var focused_range: float = 44.0
@export var focused_half_angle_deg: float = 35.0
@export var focused_close_range: float = 28.0
@export var focused_close_half_angle_deg: float = 50.0
@export var focused_windup: float = 0.10
@export var focused_recovery: float = 0.12
@export var focused_windup_move_speed: float = 0.55
@export var focused_recovery_move_speed: float = 0.70

@export_group("Focused Aim Forgiveness")
@export var soft_assist_range: float = 40.0
@export var soft_assist_half_angle_deg: float = 45.0
@export var soft_assist_strength: float = 0.2

@export_group("Crowd Control Attack")
@export var crowd_control_damage: float = 12.0
@export var crowd_control_knockback: float = 22.0
@export var crowd_control_stagger: float = 0.6
@export var crowd_control_cooldown: float = 0.9
@export var crowd_control_radius: float = 28.0
@export var crowd_control_windup: float = 0.17
@export var crowd_control_recovery: float = 0.20
@export var crowd_control_impact_duration: float = 0.10
@export var crowd_control_windup_move_speed: float = 0.40
@export var crowd_control_recovery_move_speed: float = 0.50

@export_group("Hit Feel")
@export var hit_stop_time_scale: float = 0.75
@export var hit_stop_real_duration: float = 0.028

@onready var _hitbox: Area2D = $Hitbox
@onready var _telegraph: CombatAttackTelegraph = $Telegraph
@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

var _focused_cooldown_remaining: float = 0.0
var _crowd_control_cooldown_remaining: float = 0.0
var _attack_active: bool = false
var _hit_targets: Array[Node2D] = []
var _hit_stop_active: bool = false


func _ready() -> void:
	_hitbox.monitoring = false
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_hitbox.area_entered.connect(_on_hitbox_area_entered)
	apply_weapon_profile(weapon_profile)


func _unhandled_input(event: InputEvent) -> void:
	if _attack_active or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.ctrl_pressed:
		return

	match key_event.keycode:
		KEY_1:
			_set_weapon_profile(WeaponProfilePrototype.Id.DAGGER)
			get_viewport().set_input_as_handled()
		KEY_2:
			_set_weapon_profile(WeaponProfilePrototype.Id.SWORD)
			get_viewport().set_input_as_handled()
		KEY_3:
			_set_weapon_profile(WeaponProfilePrototype.Id.POLEARM)
			get_viewport().set_input_as_handled()


func get_weapon_profile_name() -> String:
	return WeaponProfilePrototype.get_display_name(weapon_profile)


func get_weapon_profile_summary() -> String:
	return "%s  F %.2fs / CC %.2fs" % [
		get_weapon_profile_name(),
		focused_cooldown,
		crowd_control_cooldown,
	]


func get_weapon_profile_detail() -> String:
	return "F: %d dmg · %.0f° · %.0fpx  |  CC: %.0fpx · %d kb" % [
		int(focused_damage),
		focused_half_angle_deg * 2.0,
		focused_range,
		crowd_control_radius,
		int(crowd_control_knockback),
	]


func apply_weapon_profile(profile_id: WeaponProfilePrototype.Id) -> void:
	weapon_profile = profile_id
	var data := WeaponProfilePrototype.get_profile(profile_id)

	focused_damage = data["focused_damage"]
	focused_knockback = data["focused_knockback"]
	focused_stagger = data["focused_stagger"]
	focused_cooldown = data["focused_cooldown"]
	focused_range = data["focused_range"]
	focused_half_angle_deg = data["focused_half_angle_deg"]
	focused_close_range = data["focused_close_range"]
	focused_close_half_angle_deg = data["focused_close_half_angle_deg"]
	focused_windup = data["focused_windup"]
	focused_recovery = data["focused_recovery"]
	focused_windup_move_speed = data["focused_windup_move_speed"]
	focused_recovery_move_speed = data["focused_recovery_move_speed"]
	soft_assist_range = data["soft_assist_range"]
	soft_assist_half_angle_deg = data["soft_assist_half_angle_deg"]
	soft_assist_strength = data["soft_assist_strength"]
	if _player != null and _player.has_method("set_weapon_move_multiplier"):
		_player.set_weapon_move_multiplier(float(data.get("move_speed_multiplier", 1.0)))

	crowd_control_damage = data["crowd_control_damage"]
	crowd_control_knockback = data["crowd_control_knockback"]
	crowd_control_stagger = data["crowd_control_stagger"]
	crowd_control_cooldown = data["crowd_control_cooldown"]
	crowd_control_radius = data["crowd_control_radius"]
	crowd_control_windup = data["crowd_control_windup"]
	crowd_control_recovery = data["crowd_control_recovery"]
	crowd_control_windup_move_speed = data["crowd_control_windup_move_speed"]
	crowd_control_recovery_move_speed = data["crowd_control_recovery_move_speed"]
	_apply_cc_hitbox_radius()

	var summary := get_weapon_profile_summary()
	print("Weapon Profile: %s" % summary)
	weapon_profile_changed.emit(summary)


func _apply_cc_hitbox_radius() -> void:
	var shape_node := _hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return
	var circle := shape_node.shape as CircleShape2D
	if circle != null:
		circle.radius = crowd_control_radius


func _set_weapon_profile(profile_id: WeaponProfilePrototype.Id) -> void:
	if weapon_profile == profile_id:
		return
	apply_weapon_profile(profile_id)


func _physics_process(delta: float) -> void:
	_focused_cooldown_remaining = maxf(_focused_cooldown_remaining - delta, 0.0)
	_crowd_control_cooldown_remaining = maxf(_crowd_control_cooldown_remaining - delta, 0.0)

	if _attack_active:
		return

	if Input.is_action_just_pressed("crowd_control_attack"):
		if _crowd_control_cooldown_remaining <= 0.0:
			_perform_crowd_control_attack()
		return

	if Input.is_action_just_pressed("attack"):
		if _focused_cooldown_remaining <= 0.0:
			_perform_focused_attack()


func get_likely_focused_target() -> Node2D:
	if _attack_active or _player == null:
		return null

	var origin := _player.global_position
	var base_facing := _get_facing_direction()
	if base_facing.length_squared() < 0.01:
		return null

	var candidates := _gather_focused_candidates(origin, base_facing)
	if candidates.is_empty():
		return null

	return candidates[0]["enemy"] as Node2D


func _perform_focused_attack() -> void:
	_attack_active = true
	_hit_targets.clear()
	attack_started.emit()
	_lock_attack_facing()

	var windup_facing := _get_facing_direction()
	if _telegraph != null and windup_facing.length_squared() > 0.01:
		_telegraph.begin_focused_windup(
			windup_facing,
			focused_range,
			focused_half_angle_deg,
			focused_close_range,
			focused_close_half_angle_deg
		)

	_set_player_move_multiplier(focused_windup_move_speed)
	await get_tree().create_timer(focused_windup).timeout

	var impact_facing := _get_facing_direction()
	var hit_positions := _apply_focused_hits()
	_show_focused_impact_telegraph(impact_facing, hit_positions)

	if not hit_positions.is_empty():
		await _apply_hit_stop()

	_set_player_move_multiplier(focused_recovery_move_speed)
	await get_tree().create_timer(focused_recovery).timeout

	_reset_player_move_multiplier()
	_focused_cooldown_remaining = focused_cooldown
	_attack_active = false
	_unlock_attack_facing()


func _perform_crowd_control_attack() -> void:
	_attack_active = true
	_crowd_control_cooldown_remaining = crowd_control_cooldown
	_hit_targets.clear()
	attack_started.emit()
	_lock_attack_facing()

	if _telegraph != null:
		_telegraph.begin_cc_windup(crowd_control_radius)

	_set_player_move_multiplier(crowd_control_windup_move_speed)
	await get_tree().create_timer(crowd_control_windup).timeout

	if _telegraph != null:
		_telegraph.show_crowd_control_impact(crowd_control_radius)

	_hitbox.monitoring = true
	await get_tree().create_timer(crowd_control_impact_duration).timeout
	_hitbox.monitoring = false

	if not _hit_targets.is_empty():
		await _apply_hit_stop()

	_set_player_move_multiplier(crowd_control_recovery_move_speed)
	await get_tree().create_timer(crowd_control_recovery).timeout

	_reset_player_move_multiplier()
	_attack_active = false
	_unlock_attack_facing()


func _show_focused_impact_telegraph(base_facing: Vector2, hit_positions: Array[Vector2]) -> void:
	if _telegraph == null or base_facing.length_squared() < 0.01:
		return

	_telegraph.show_focused_impact(
		base_facing,
		focused_range,
		focused_half_angle_deg,
		focused_close_range,
		focused_close_half_angle_deg,
		not hit_positions.is_empty()
	)
	for position in hit_positions:
		_telegraph.show_hit_spark(position)


func _apply_focused_hits() -> Array[Vector2]:
	var hit_positions: Array[Vector2] = []
	if _player == null:
		return hit_positions

	var origin := _player.global_position
	var base_facing := _get_facing_direction()
	if base_facing.length_squared() < 0.01:
		return hit_positions

	var strict_half_angle := deg_to_rad(focused_half_angle_deg)
	var candidates := _gather_focused_candidates(origin, base_facing)
	if candidates.is_empty():
		return hit_positions

	var primary: Dictionary = candidates[0]
	if _try_damage(
		primary["enemy"],
		focused_damage,
		focused_knockback,
		focused_stagger
	):
		hit_positions.append((primary["enemy"] as Node2D).global_position)

	for i in range(1, candidates.size()):
		var extra: Dictionary = candidates[i]
		if extra["strict_angle"] > strict_half_angle:
			continue
		if _try_damage(
			extra["enemy"],
			focused_damage,
			focused_knockback,
			focused_stagger
		):
			hit_positions.append((extra["enemy"] as Node2D).global_position)

	return hit_positions


func _gather_focused_candidates(origin: Vector2, base_facing: Vector2) -> Array[Dictionary]:
	var facing := _get_soft_assisted_facing(origin, base_facing)
	var candidates: Array[Dictionary] = []

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_valid_enemy(enemy):
			continue

		var offset := enemy.global_position - origin
		var distance := offset.length()
		if distance > focused_range:
			continue

		if distance < 0.001:
			candidates.append({
				"enemy": enemy,
				"angle": 0.0,
				"strict_angle": 0.0,
				"distance": 0.0,
			})
			continue

		var angle := absf(facing.angle_to(offset))
		var strict_angle := absf(base_facing.angle_to(offset))
		var allowed_half_angle := _get_allowed_half_angle(distance)
		if angle > allowed_half_angle:
			continue

		candidates.append({
			"enemy": enemy,
			"angle": angle,
			"strict_angle": strict_angle,
			"distance": distance,
		})

	if candidates.is_empty():
		return candidates

	candidates.sort_custom(_compare_focus_candidates)
	return candidates


func _get_allowed_half_angle(distance: float) -> float:
	if distance <= focused_close_range:
		return deg_to_rad(focused_close_half_angle_deg)
	return deg_to_rad(focused_half_angle_deg)


func _get_soft_assisted_facing(origin: Vector2, base_facing: Vector2) -> Vector2:
	var assist_half_angle := deg_to_rad(soft_assist_half_angle_deg)
	var best_enemy: Node2D = null
	var best_angle := INF

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not _is_valid_enemy(enemy):
			continue

		var offset := enemy.global_position - origin
		var distance := offset.length()
		if distance > soft_assist_range:
			continue
		if distance < 0.001:
			best_angle = 0.0
			best_enemy = enemy
			continue

		var angle := absf(base_facing.angle_to(offset))
		if angle > assist_half_angle:
			continue
		if angle < best_angle:
			best_angle = angle
			best_enemy = enemy

	if best_enemy == null:
		return base_facing

	var to_enemy := (best_enemy.global_position - origin).normalized()
	return base_facing.lerp(to_enemy, soft_assist_strength).normalized()


func _compare_focus_candidates(a: Dictionary, b: Dictionary) -> bool:
	if not is_equal_approx(a["angle"], b["angle"]):
		return a["angle"] < b["angle"]
	return a["distance"] < b["distance"]


func _on_hitbox_body_entered(body: Node2D) -> void:
	if _try_damage(body, crowd_control_damage, crowd_control_knockback, crowd_control_stagger):
		_show_cc_hit_spark(body.global_position)


func _on_hitbox_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Node2D:
		if _try_damage(parent as Node2D, crowd_control_damage, crowd_control_knockback, crowd_control_stagger):
			_show_cc_hit_spark((parent as Node2D).global_position)


func _show_cc_hit_spark(world_position: Vector2) -> void:
	if _telegraph != null:
		_telegraph.show_hit_spark(world_position)


func _try_damage(
	target: Node2D,
	damage_amount: float,
	knockback_distance: float,
	stagger_duration: float
) -> bool:
	if target in _hit_targets:
		return false
	if not _is_valid_enemy(target):
		return false

	var health := target.get_node_or_null("Health") as Health
	if health == null or not health.is_alive():
		return false

	var feedback := target.get_node_or_null("CombatVisualFeedback") as CombatVisualFeedback
	var hit_knockback := knockback_distance
	var hit_stagger := stagger_duration
	if target.has_method("scale_incoming_player_hit"):
		var scaled: Vector2 = target.scale_incoming_player_hit(knockback_distance, stagger_duration)
		hit_knockback = scaled.x
		hit_stagger = scaled.y
	if feedback != null:
		feedback.override_next_hit_reaction(hit_knockback, hit_stagger)
		feedback.queue_player_hit_confirm()

	_hit_targets.append(target)
	health.take_damage(damage_amount)
	attack_hit.emit(target)
	return true


func _apply_hit_stop() -> void:
	if hit_stop_real_duration <= 0.0 or _hit_stop_active:
		return

	_hit_stop_active = true
	var previous_scale := Engine.time_scale
	Engine.time_scale = hit_stop_time_scale
	await get_tree().create_timer(hit_stop_real_duration, true, false, true).timeout
	Engine.time_scale = previous_scale
	_hit_stop_active = false


func _set_player_move_multiplier(multiplier: float) -> void:
	if _player != null and _player.has_method("set_attack_move_speed_multiplier"):
		_player.set_attack_move_speed_multiplier(multiplier)


func _reset_player_move_multiplier() -> void:
	if _player != null and _player.has_method("reset_attack_move_speed_multiplier"):
		_player.reset_attack_move_speed_multiplier()


func _lock_attack_facing() -> void:
	if _player != null and _player.has_method("lock_attack_facing"):
		_player.lock_attack_facing(_get_facing_direction())


func _unlock_attack_facing() -> void:
	if _player != null and _player.has_method("unlock_attack_facing"):
		_player.unlock_attack_facing()


func _is_valid_enemy(target: Node2D) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		return false
	return target.is_in_group("enemy")


func _get_facing_direction() -> Vector2:
	if _player != null and _player.has_method("get_facing_direction"):
		return _player.get_facing_direction()
	return Vector2.DOWN

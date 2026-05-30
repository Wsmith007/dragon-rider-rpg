extends CharacterBody2D
## Dragon actor: follow, threat response, and future combat layers.


signal behavior_changed(mode_name: String)

@onready var follow_behavior: DragonFollowBehavior = $FollowBehavior
@onready var threat_behavior: DragonThreatBehavior = $ThreatBehavior
@onready var _visual: Polygon2D = $Visual

@export var reposition_interval_min: float = 2.5
@export var reposition_interval_max: float = 6.0
@export var reposition_chance: float = 0.5
@export var reposition_only_when_rider_slow: bool = true
@export var rider_slow_speed_threshold: float = 40.0

var _follow_target: Node2D
var _reposition_cooldown: float = 0.0
var _last_mode_name: String = "follow"


func _ready() -> void:
	follow_behavior.setup(self)
	_schedule_next_reposition_check()
	threat_behavior.alert_started.connect(_on_alert_started)
	threat_behavior.alert_ended.connect(_on_alert_ended)


func set_follow_target(target: Node2D) -> void:
	_follow_target = target
	follow_behavior.set_follow_target(target)
	threat_behavior.set_follow_target(target)


func _physics_process(delta: float) -> void:
	if _follow_target == null:
		return

	threat_behavior.evaluate()

	if follow_behavior.mode != DragonFollowBehavior.Mode.ALERT:
		_update_reposition_timer(delta)

	velocity = follow_behavior.get_desired_velocity()
	move_and_slide()
	follow_behavior.apply_lag_leash()
	_update_facing()
	_emit_mode_if_changed()


func _update_facing() -> void:
	var look_target: Vector2

	if follow_behavior.mode == DragonFollowBehavior.Mode.ALERT:
		var threat := follow_behavior.get_alert_threat()
		if threat != null and is_instance_valid(threat):
			look_target = threat.global_position
		elif _follow_target:
			look_target = _follow_target.global_position
		else:
			return
	elif velocity.length_squared() > 1.0:
		look_target = global_position + velocity
	else:
		return

	var direction := global_position.direction_to(look_target)
	_visual.rotation = direction.angle() + PI * 0.5


func _update_reposition_timer(delta: float) -> void:
	if follow_behavior.mode == DragonFollowBehavior.Mode.REPOSITION:
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
	_emit_mode_if_changed()


func _on_alert_started(_threat: Node2D) -> void:
	follow_behavior.enter_alert(_threat)
	_visual.modulate = Color(1.0, 0.85, 0.55, 1.0)
	_emit_mode_if_changed()


func _on_alert_ended() -> void:
	follow_behavior.exit_alert()
	_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_emit_mode_if_changed()


func _emit_mode_if_changed() -> void:
	var mode_name := follow_behavior.get_mode_name()
	if mode_name != _last_mode_name:
		_last_mode_name = mode_name
		behavior_changed.emit(mode_name)


func _schedule_next_reposition_check() -> void:
	_reposition_cooldown = randf_range(reposition_interval_min, reposition_interval_max)

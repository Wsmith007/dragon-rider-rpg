extends CharacterBody2D
## Dragon actor: delegates movement to FollowBehavior; future layers (emotion, bond, combat) attach here.


signal behavior_changed(mode_name: String)

@onready var follow_behavior: DragonFollowBehavior = $FollowBehavior

@export var reposition_interval_min: float = 4.0
@export var reposition_interval_max: float = 9.0
@export var reposition_chance: float = 0.35
@export var reposition_only_when_rider_slow: bool = true
@export var rider_slow_speed_threshold: float = 40.0

var _follow_target: Node2D
var _reposition_cooldown: float = 0.0


func _ready() -> void:
	follow_behavior.setup(self)
	_schedule_next_reposition_check()


func set_follow_target(target: Node2D) -> void:
	_follow_target = target
	follow_behavior.set_follow_target(target)


func _physics_process(delta: float) -> void:
	if _follow_target == null:
		return

	_update_reposition_timer(delta)
	velocity = follow_behavior.get_desired_velocity()
	move_and_slide()


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

	var previous_mode := follow_behavior.get_mode_name()
	follow_behavior.start_reposition()
	if follow_behavior.get_mode_name() != previous_mode:
		behavior_changed.emit(follow_behavior.get_mode_name())


func _schedule_next_reposition_check() -> void:
	_reposition_cooldown = randf_range(reposition_interval_min, reposition_interval_max)

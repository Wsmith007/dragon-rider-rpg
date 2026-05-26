extends Camera2D
## Smooth follow camera. Target is assigned by the world scene, not hard-coded to Player.


@export var follow_smoothing: float = 8.0

var _target: Node2D


func _ready() -> void:
	make_current()


func set_follow_target(target: Node2D) -> void:
	_target = target
	if _target:
		global_position = _target.global_position


func _physics_process(delta: float) -> void:
	if _target == null:
		return
	var weight := 1.0 - exp(-follow_smoothing * delta)
	global_position = global_position.lerp(_target.global_position, weight)

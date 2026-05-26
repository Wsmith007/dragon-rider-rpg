extends CharacterBody2D
## Top-down rider movement. Emits signals for systems that react to player motion.

signal moved(velocity: Vector2)


@export var move_speed: float = 220.0


func _ready() -> void:
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

	if velocity.length_squared() > 0.0:
		moved.emit(velocity)

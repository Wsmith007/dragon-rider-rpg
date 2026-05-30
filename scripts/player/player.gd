extends CharacterBody2D
## Top-down rider movement, health, and combat signals.

signal moved(velocity: Vector2)
signal player_damaged(current_health: float, maximum_health: float)
signal player_died


@export var move_speed: float = 220.0
@export var max_health: float = 100.0

@onready var _health: Health = $Health
@onready var _visual: Polygon2D = $Visual

var _is_dead: bool = false


func _ready() -> void:
	add_to_group("player")
	_health.max_health = max_health
	_health.current_health = max_health
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
	if _is_dead:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

	if velocity.length_squared() > 0.0:
		moved.emit(velocity)
		_visual.rotation = velocity.angle() + PI * 0.5


func _on_health_changed(current: float, maximum: float) -> void:
	player_damaged.emit(current, maximum)


func _on_died() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	$MeleeAttack.set_physics_process(false)
	player_died.emit()
	_visual.modulate = Color(0.6, 0.6, 0.6, 0.75)

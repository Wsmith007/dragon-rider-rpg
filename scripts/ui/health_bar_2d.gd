extends Node2D
## Small world-space health bar (background + fill). Attach under an entity with a Health node.

@export var health_path: NodePath = ^"../Health"
@export var bar_size: Vector2 = Vector2(32.0, 5.0)
@export var bar_offset: Vector2 = Vector2(0.0, -28.0)
@export var background_color: Color = Color(0.12, 0.12, 0.12, 0.9)
@export var fill_color: Color = Color(0.82, 0.22, 0.22, 1.0)
@export var border_color: Color = Color(0.05, 0.05, 0.05, 0.95)

var _health: Health
var _fill_ratio: float = 1.0


func _ready() -> void:
	position = bar_offset
	_health = get_node_or_null(health_path) as Health
	if _health == null:
		push_warning("HealthBar2D: missing Health at %s" % health_path)
		return

	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	call_deferred("_refresh_from_health")


func _refresh_from_health() -> void:
	if _health == null:
		return
	_fill_ratio = _health.current_health / _health.max_health if _health.max_health > 0.0 else 0.0
	queue_redraw()


func _on_health_changed(current: float, maximum: float) -> void:
	_fill_ratio = current / maximum if maximum > 0.0 else 0.0
	queue_redraw()


func _on_died() -> void:
	visible = false


func _draw() -> void:
	var half_width := bar_size.x * 0.5
	var origin := Vector2(-half_width, 0.0)
	var background_rect := Rect2(origin, bar_size)

	draw_rect(background_rect, background_color)

	if _fill_ratio > 0.0:
		var fill_rect := Rect2(origin, Vector2(bar_size.x * _fill_ratio, bar_size.y))
		draw_rect(fill_rect, fill_color)

	draw_rect(background_rect, border_color, false, 1.0)

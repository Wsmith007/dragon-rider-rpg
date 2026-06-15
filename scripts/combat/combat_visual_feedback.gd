extends Node
class_name CombatVisualFeedback
## Brief flash, knockback, and optional stagger when parent Health loses hit points.


@export var visual_path: NodePath = ^"../Visual"
@export var health_path: NodePath = ^"../Health"
@export var hit_flash_color: Color = Color(1.55, 1.55, 1.55, 1.0)
@export var flash_duration: float = 0.1
@export var player_hit_flash_color: Color = Color(1.95, 1.82, 1.2, 1.0)
@export var player_hit_flash_duration: float = 0.16
@export var nudge_distance: float = 0.0
@export var stagger_duration: float = 0.0
@export var nudge_away_from_group: StringName = &"player"

var _visual: CanvasItem
var _health: Health
var _owner_body: Node2D
var _base_modulate: Color
var _tracked_health: float = -1.0
var _flash_tween: Tween
var _override_knockback: float = -1.0
var _override_stagger: float = -1.0
var _use_player_hit_confirm: bool = false


func override_next_hit_reaction(knockback_distance: float, stagger_duration: float) -> void:
	_override_knockback = knockback_distance
	_override_stagger = stagger_duration


func queue_player_hit_confirm() -> void:
	_use_player_hit_confirm = true


func _ready() -> void:
	_owner_body = get_parent() as Node2D
	_visual = get_node_or_null(visual_path) as CanvasItem
	_health = get_node_or_null(health_path) as Health
	if _visual == null or _health == null:
		push_warning("CombatVisualFeedback: missing Visual or Health on %s" % get_parent())
		set_process(false)
		return

	_base_modulate = _visual.modulate
	_tracked_health = _health.current_health
	_health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, _maximum: float) -> void:
	if _tracked_health < 0.0:
		_tracked_health = current
		return

	if current < _tracked_health:
		if _use_player_hit_confirm:
			_use_player_hit_confirm = false
			_play_player_hit_confirm()
		else:
			_play_hit_flash()
		_apply_hit_reaction()

	_tracked_health = current


func _play_hit_flash() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	_visual.modulate = hit_flash_color
	_flash_tween = create_tween()
	_flash_tween.tween_property(_visual, "modulate", _base_modulate, flash_duration)


func _play_player_hit_confirm() -> void:
	if _visual == null:
		return

	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	_visual.modulate = player_hit_flash_color
	_flash_tween = create_tween()
	_flash_tween.tween_property(_visual, "modulate", _base_modulate, player_hit_flash_duration)


func _apply_hit_reaction() -> void:
	var applied_knockback := nudge_distance
	var applied_stagger := stagger_duration
	if _override_knockback >= 0.0:
		applied_knockback = _override_knockback
		_override_knockback = -1.0
	if _override_stagger >= 0.0:
		applied_stagger = _override_stagger
		_override_stagger = -1.0

	if applied_knockback <= 0.0 and applied_stagger <= 0.0:
		return
	if _owner_body == null:
		return

	var away := _get_nudge_direction()
	if away.length_squared() < 0.01:
		away = Vector2.RIGHT

	if _owner_body.has_method("apply_hit_reaction"):
		_owner_body.apply_hit_reaction(away, applied_knockback, applied_stagger)
	elif applied_knockback > 0.0:
		_owner_body.global_position += away.normalized() * applied_knockback


func _get_nudge_direction() -> Vector2:
	var sources := get_tree().get_nodes_in_group(nudge_away_from_group)
	if sources.is_empty() or _owner_body == null:
		return Vector2.ZERO

	var closest: Node2D = null
	var closest_distance := INF
	for node in sources:
		if not node is Node2D:
			continue
		var source := node as Node2D
		if not is_instance_valid(source):
			continue
		var distance := _owner_body.global_position.distance_squared_to(source.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = source

	if closest == null:
		return Vector2.ZERO
	return _owner_body.global_position - closest.global_position

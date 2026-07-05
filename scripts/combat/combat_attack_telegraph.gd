extends Node2D
class_name CombatAttackTelegraph
## Pass 6 prototype: attack telegraphs with wind-up / impact phases. See docs/combat_feel_notes.md.

const PlayerTargetFocus = preload("res://scripts/player/player_target_focus.gd")

signal debug_ranges_toggled(enabled: bool)

@export var focused_fill_hit: Color = Color(0.45, 0.82, 1.0, 0.28)
@export var focused_fill_miss: Color = Color(0.55, 0.58, 0.68, 0.14)
@export var focused_edge_hit: Color = Color(0.75, 0.95, 1.0, 0.62)
@export var focused_edge_miss: Color = Color(0.65, 0.68, 0.78, 0.35)
@export var focused_windup_fill: Color = Color(0.42, 0.68, 0.92, 0.1)
@export var focused_windup_edge: Color = Color(0.55, 0.78, 0.95, 0.28)
@export var focused_close_forgiveness_fill: Color = Color(0.5, 0.85, 1.0, 0.08)
@export var focused_close_forgiveness_edge: Color = Color(0.6, 0.9, 1.0, 0.22)
@export var focused_sweep_color: Color = Color(0.9, 0.95, 1.0, 0.45)
@export var focused_windup_duration: float = 0.1
@export var focused_impact_duration: float = 0.18

@export var cc_ring_fill: Color = Color(0.78, 0.55, 0.95, 0.18)
@export var cc_ring_edge: Color = Color(0.9, 0.7, 1.0, 0.55)
@export var cc_windup_fill: Color = Color(0.65, 0.45, 0.82, 0.1)
@export var cc_windup_edge: Color = Color(0.78, 0.55, 0.92, 0.3)
@export var cc_windup_duration: float = 0.17
@export var cc_impact_duration: float = 0.24

@export var spark_core_color: Color = Color(1.0, 0.98, 0.82, 0.95)
@export var spark_ring_color: Color = Color(1.0, 0.85, 0.45, 0.55)
@export var spark_duration: float = 0.16
@export var spark_radius: float = 8.0

@export var debug_cone_color: Color = Color(0.35, 0.95, 0.55, 0.22)
@export var debug_cone_edge: Color = Color(0.45, 1.0, 0.65, 0.55)
@export var debug_close_cone_color: Color = Color(0.35, 0.75, 0.95, 0.12)
@export var debug_close_cone_edge: Color = Color(0.45, 0.85, 1.0, 0.35)
@export var debug_cc_color: Color = Color(0.95, 0.45, 0.95, 0.18)
@export var debug_cc_edge: Color = Color(1.0, 0.55, 1.0, 0.5)
@export var debug_target_line_color: Color = Color(0.95, 0.95, 0.35, 0.65)
@export var debug_target_ring_color: Color = Color(1.0, 0.95, 0.35, 0.85)
@export var debug_focus_line_color: Color = Color(0.4, 0.75, 1.0, 0.75)
@export var debug_focus_ring_color: Color = Color(0.45, 0.82, 1.0, 0.9)

var debug_ranges_enabled: bool = false

var _melee_attack: Node2D
var _focused_until: float = 0.0
var _focused_started_at: float = 0.0
var _focused_duration: float = 0.0
var _focused_facing: Vector2 = Vector2.DOWN
var _focused_range: float = 44.0
var _focused_half_angle_deg: float = 35.0
var _focused_close_range: float = 28.0
var _focused_close_half_angle_deg: float = 50.0
var _focused_hit: bool = false
var _focused_is_windup: bool = false

var _cc_until: float = 0.0
var _cc_started_at: float = 0.0
var _cc_duration: float = 0.0
var _cc_radius: float = 28.0
var _cc_is_windup: bool = false

var _sparks: Array[Dictionary] = []


func _ready() -> void:
	z_index = 5
	set_process(true)
	_melee_attack = get_parent() as Node2D


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode != KEY_F11:
		return

	debug_ranges_enabled = not debug_ranges_enabled
	debug_ranges_toggled.emit(debug_ranges_enabled)
	print("[DEBUG] Combat range overlay: %s (F11)" % ("ON" if debug_ranges_enabled else "OFF"))
	queue_redraw()


func begin_focused_windup(
	facing: Vector2,
	range: float,
	half_angle_deg: float,
	close_range: float,
	close_half_angle_deg: float
) -> void:
	if facing.length_squared() < 0.01:
		return

	_store_focused_params(facing, range, half_angle_deg, close_range, close_half_angle_deg, false, true)
	_focused_duration = focused_windup_duration
	_focused_started_at = Time.get_ticks_msec() / 1000.0
	_focused_until = _focused_started_at + _focused_duration
	queue_redraw()


func show_focused_impact(
	facing: Vector2,
	range: float,
	half_angle_deg: float,
	close_range: float,
	close_half_angle_deg: float,
	did_hit: bool
) -> void:
	if facing.length_squared() < 0.01:
		return

	_store_focused_params(facing, range, half_angle_deg, close_range, close_half_angle_deg, did_hit, false)
	_focused_duration = focused_impact_duration
	_focused_started_at = Time.get_ticks_msec() / 1000.0
	_focused_until = _focused_started_at + _focused_duration
	queue_redraw()


func begin_cc_windup(radius: float) -> void:
	_cc_radius = radius
	_cc_is_windup = true
	_cc_duration = cc_windup_duration
	_cc_started_at = Time.get_ticks_msec() / 1000.0
	_cc_until = _cc_started_at + _cc_duration
	queue_redraw()


func show_crowd_control_impact(radius: float) -> void:
	_cc_radius = radius
	_cc_is_windup = false
	_cc_duration = cc_impact_duration
	_cc_started_at = Time.get_ticks_msec() / 1000.0
	_cc_until = _cc_started_at + _cc_duration
	queue_redraw()


func show_hit_spark(world_position: Vector2) -> void:
	_sparks.append({
		"position": to_local(world_position),
		"until": Time.get_ticks_msec() / 1000.0 + spark_duration,
	})
	queue_redraw()


func _store_focused_params(
	facing: Vector2,
	range: float,
	half_angle_deg: float,
	close_range: float,
	close_half_angle_deg: float,
	did_hit: bool,
	is_windup: bool
) -> void:
	_focused_facing = facing.normalized()
	_focused_range = range
	_focused_half_angle_deg = half_angle_deg
	_focused_close_range = close_range
	_focused_close_half_angle_deg = close_half_angle_deg
	_focused_hit = did_hit
	_focused_is_windup = is_windup


func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var needs_redraw := debug_ranges_enabled

	if _focused_until > now:
		needs_redraw = true
	elif _focused_until > 0.0:
		_focused_until = 0.0
		needs_redraw = true

	if _cc_until > now:
		needs_redraw = true
	elif _cc_until > 0.0:
		_cc_until = 0.0
		needs_redraw = true

	var kept_sparks: Array[Dictionary] = []
	for spark in _sparks:
		if spark["until"] > now:
			kept_sparks.append(spark)
			needs_redraw = true
	_sparks = kept_sparks

	if needs_redraw:
		queue_redraw()


func _draw() -> void:
	var now := Time.get_ticks_msec() / 1000.0

	if debug_ranges_enabled:
		_draw_debug_ranges()

	if _focused_until > now:
		var progress := clampf((now - _focused_started_at) / _focused_duration, 0.0, 1.0)
		_draw_focused_telegraph(progress)

	if _cc_until > now:
		var progress := clampf((now - _cc_started_at) / _cc_duration, 0.0, 1.0)
		_draw_crowd_control_telegraph(progress)

	for spark in _sparks:
		var spark_until: float = spark["until"]
		var spark_position: Vector2 = spark["position"]
		var spark_t: float = 1.0 - ((spark_until - now) / spark_duration)
		_draw_hit_spark(spark_position, spark_t)


func _draw_debug_ranges() -> void:
	if _melee_attack == null:
		return

	var facing := _get_player_facing()
	if facing.length_squared() < 0.01:
		facing = Vector2.DOWN

	var range := float(_melee_attack.get("focused_range"))
	var half_angle := float(_melee_attack.get("focused_half_angle_deg"))
	var close_range := float(_melee_attack.get("focused_close_range"))
	var close_half_angle := float(_melee_attack.get("focused_close_half_angle_deg"))
	var cc_radius := float(_melee_attack.get("crowd_control_radius"))

	_draw_close_range_overlay(
		facing,
		close_range,
		close_half_angle,
		debug_close_cone_color,
		debug_close_cone_edge,
		1.0
	)
	_draw_cone_wedge(
		facing,
		range,
		half_angle,
		debug_cone_color,
		debug_cone_edge,
		1.0
	)
	draw_arc(Vector2.ZERO, cc_radius, 0.0, TAU, 48, debug_cc_edge, 1.5, true)
	draw_circle(Vector2.ZERO, cc_radius, debug_cc_color)
	_draw_debug_likely_target()
	_draw_debug_focus_target()


func _draw_debug_likely_target() -> void:
	if _melee_attack == null or not _melee_attack.has_method("get_likely_focused_target"):
		return

	var target := _melee_attack.get_likely_focused_target() as Node2D
	if target == null or not is_instance_valid(target):
		return

	var local_position := to_local(target.global_position)
	draw_line(Vector2.ZERO, local_position, debug_target_line_color, 1.5, true)
	draw_arc(local_position, 16.0, 0.0, TAU, 24, debug_target_ring_color, 2.0, true)


func _draw_debug_focus_target() -> void:
	var player := get_parent().get_parent() as Node
	if player == null:
		return
	var focus: PlayerTargetFocus = player.get_node_or_null("TargetFocus") as PlayerTargetFocus
	if focus == null or not focus.is_focus_active():
		return

	var target: Node2D = focus.get_focused_enemy()
	if target == null or not is_instance_valid(target):
		return

	var local_position := to_local(target.global_position)
	draw_line(Vector2.ZERO, local_position, debug_focus_line_color, 2.0, true)
	draw_arc(local_position, 20.0, 0.0, TAU, 28, debug_focus_ring_color, 2.5, true)


func _draw_focused_telegraph(progress: float) -> void:
	if _focused_is_windup:
		var pulse := 0.65 + sin(progress * PI) * 0.35
		var fill := focused_windup_fill
		var edge := focused_windup_edge
		fill.a *= pulse
		edge.a *= pulse
		_draw_close_range_overlay(
			_focused_facing,
			_focused_close_range,
			_focused_close_half_angle_deg,
			focused_close_forgiveness_fill,
			focused_close_forgiveness_edge,
			pulse
		)
		_draw_cone_wedge(
			_focused_facing,
			_focused_range,
			_focused_half_angle_deg,
			fill,
			edge,
			pulse
		)
		return

	var fade := 1.0 - progress
	var fill := focused_fill_hit if _focused_hit else focused_fill_miss
	var edge := focused_edge_hit if _focused_hit else focused_edge_miss
	fill.a *= fade
	edge.a *= fade

	_draw_close_range_overlay(
		_focused_facing,
		_focused_close_range,
		_focused_close_half_angle_deg,
		focused_close_forgiveness_fill,
		focused_close_forgiveness_edge,
		fade
	)
	_draw_cone_wedge(_focused_facing, _focused_range, _focused_half_angle_deg, fill, edge, fade)

	var sweep_end := _focused_facing.normalized() * _focused_range * lerpf(0.35, 1.0, progress)
	var sweep := focused_sweep_color
	sweep.a *= fade
	draw_line(Vector2.ZERO, sweep_end, sweep, 2.5 if _focused_hit else 2.0)


func _draw_crowd_control_telegraph(progress: float) -> void:
	if _cc_is_windup:
		var pulse := 0.55 + sin(progress * PI * 2.0) * 0.25
		var radius := lerpf(_cc_radius * 0.25, _cc_radius * 0.55, progress)
		var fill := cc_windup_fill
		var edge := cc_windup_edge
		fill.a *= pulse
		edge.a *= pulse
		draw_circle(Vector2.ZERO, radius, fill)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, edge, 1.5, true)
		return

	var fade := 1.0 - progress
	var radius := lerpf(_cc_radius * 0.45, _cc_radius, progress)
	var fill := cc_ring_fill
	var edge := cc_ring_edge
	fill.a *= fade * 0.85
	edge.a *= fade

	draw_circle(Vector2.ZERO, radius, fill)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, edge, 2.5, true)


func _draw_close_range_overlay(
	facing: Vector2,
	close_range: float,
	close_half_angle_deg: float,
	fill_color: Color,
	edge_color: Color,
	alpha_scale: float
) -> void:
	if close_range <= 0.0 or close_half_angle_deg <= 0.0:
		return

	var fill := fill_color
	var edge := edge_color
	fill.a *= alpha_scale
	edge.a *= alpha_scale
	_draw_cone_wedge(facing, close_range, close_half_angle_deg, fill, edge, alpha_scale)


func _draw_hit_spark(local_position: Vector2, progress: float) -> void:
	var fade := 1.0 - progress
	var core := spark_core_color
	var ring := spark_ring_color
	core.a *= fade
	ring.a *= fade * 0.8
	var radius := lerpf(spark_radius * 0.35, spark_radius * 1.2, progress)
	draw_circle(local_position, radius * 0.5, core)
	draw_arc(local_position, radius, 0.0, TAU, 12, ring, 2.0, true)


func _draw_cone_wedge(
	facing: Vector2,
	range: float,
	half_angle_deg: float,
	fill_color: Color,
	edge_color: Color,
	alpha_scale: float
) -> void:
	var points := _build_cone_points(facing, range, half_angle_deg)
	if points.size() < 3:
		return

	draw_colored_polygon(points, fill_color)

	if edge_color.a > 0.01:
		var edge := edge_color
		edge.a *= alpha_scale
		draw_polyline(points + PackedVector2Array([points[0]]), edge, 1.5, true)


func _build_cone_points(facing: Vector2, range: float, half_angle_deg: float) -> PackedVector2Array:
	var points: PackedVector2Array = [Vector2.ZERO]
	var half_angle := deg_to_rad(half_angle_deg)
	var base_angle := facing.normalized().angle()
	const SEGMENTS := 14

	for i in range(SEGMENTS + 1):
		var t := float(i) / float(SEGMENTS)
		var angle := base_angle - half_angle + t * half_angle * 2.0
		points.append(Vector2.from_angle(angle) * range)

	return points


func _get_player_facing() -> Vector2:
	var player := get_parent().get_parent() as CharacterBody2D
	if player != null and player.has_method("get_facing_direction"):
		return player.get_facing_direction()
	return Vector2.DOWN

extends Node2D
class_name CombatTargetFocusIndicator
## Visual marker for player-chosen target focus (distinct from likely-hit preview).

@export var ring_radius: float = 22.0
@export var ring_color: Color = Color(0.35, 0.72, 1.0, 0.88)
@export var ring_outline_color: Color = Color(0.08, 0.18, 0.32, 0.72)
@export var marker_radius: float = 4.5
@export var marker_offset: Vector2 = Vector2(0.0, -22.0)
@export var pulse_speed: float = 4.0

var _target_focus: PlayerTargetFocus
var _target: Node2D


func _ready() -> void:
	z_index = 6
	set_process(true)
	var player := get_parent().get_parent() as Node
	if player != null:
		_target_focus = player.get_node_or_null("TargetFocus") as PlayerTargetFocus


func _process(_delta: float) -> void:
	_target = null
	if _target_focus != null and _target_focus.is_focus_active():
		_target = _target_focus.get_focused_enemy()
	queue_redraw()


func _draw() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var local_position := to_local(_target.global_position)
	var pulse := 0.6 + sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * 0.25
	var outline := ring_outline_color
	outline.a *= pulse * 0.85
	draw_arc(local_position, ring_radius + 3.0, 0.0, TAU, 32, outline, 3.0, true)

	var ring := ring_color
	ring.a *= pulse

	draw_arc(local_position, ring_radius, 0.0, TAU, 32, ring, 2.5, true)

	var marker_pos := local_position + marker_offset
	var marker := Color(0.55, 0.88, 1.0, 0.95)
	marker.a *= pulse
	draw_circle(marker_pos, marker_radius, marker)

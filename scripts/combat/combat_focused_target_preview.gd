extends Node2D
class_name CombatFocusedTargetPreview
## Pass 7 prototype: subtle likely-target ring. See docs/combat_feel_notes.md.

@export var ring_radius: float = 17.0
@export var ring_color: Color = Color(0.45, 0.82, 0.95, 0.42)
@export var marker_radius: float = 3.0
@export var pulse_speed: float = 3.5

var _melee_attack: Node2D
var _target: Node2D


func _ready() -> void:
	z_index = 4
	set_process(true)
	_melee_attack = get_parent() as Node2D


func _process(_delta: float) -> void:
	_target = _query_likely_target()
	queue_redraw()


func _query_likely_target() -> Node2D:
	if _melee_attack == null or not _melee_attack.has_method("get_likely_focused_target"):
		return null

	var target := _melee_attack.get_likely_focused_target() as Node2D
	if target == null or not is_instance_valid(target):
		return null
	return target


func _draw() -> void:
	if _target == null:
		return

	var local_position := to_local(_target.global_position)
	var pulse := 0.55 + sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * 0.2
	var ring := ring_color
	ring.a *= pulse

	draw_arc(local_position, ring_radius, 0.0, TAU, 28, ring, 1.0, true)

	var marker := ring
	marker.a *= pulse * 0.75
	draw_circle(local_position, marker_radius, marker)

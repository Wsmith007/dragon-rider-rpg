extends Node2D
## Subtle dragon state ring — presentation only. Replaces constant speech bubbles for routine states.


@export var ring_radius: float = 22.0
@export var pulse_speed: float = 3.0

var _dragon: CharacterBody2D


func _ready() -> void:
	z_index = -1
	_dragon = get_parent() as CharacterBody2D
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _dragon == null:
		return

	var ring_color := _color_for_state(_dragon.state)
	if ring_color.a <= 0.01:
		return

	var pulse := 0.65 + sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * 0.25
	ring_color.a *= pulse
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 32, ring_color, 2.0, true)


func _color_for_state(state: DragonState.State) -> Color:
	match state:
		DragonState.State.WAITING:
			return Color(0.52, 0.72, 1.0, 0.28)
		DragonState.State.PROTECTING:
			return Color(1.0, 0.42, 0.32, 0.38)
		DragonState.State.ASSISTING:
			return Color(1.0, 0.58, 0.22, 0.42)
		DragonState.State.HESITATING:
			return Color(0.72, 0.66, 1.0, 0.34)
		_:
			return Color(0.0, 0.0, 0.0, 0.0)

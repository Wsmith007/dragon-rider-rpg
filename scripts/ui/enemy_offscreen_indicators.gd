extends Control
## Edge arrows pointing toward off-screen enemies.


@export var edge_margin: float = 28.0
@export var arrow_size: float = 10.0
@export var arrow_color: Color = Color(0.9, 0.25, 0.25, 0.85)

var _player: Node2D


func bind_to_player(player: Node2D) -> void:
	_player = player


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _player == null:
		return

	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	var viewport_size := get_viewport_rect().size
	var screen_center := viewport_size * 0.5

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		var enemy := node as Node2D
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue

		var screen_pos := _world_to_screen(enemy.global_position, camera, viewport_size)
		if _is_on_screen(screen_pos, viewport_size):
			continue

		var direction := (screen_pos - screen_center).normalized()
		if direction.length_squared() < 0.001:
			continue

		var edge_pos := _clamp_to_screen_edge(screen_center, direction, viewport_size, edge_margin)
		_draw_arrow(edge_pos, direction)


func _world_to_screen(world_pos: Vector2, camera: Camera2D, viewport_size: Vector2) -> Vector2:
	var local_pos := camera.to_local(world_pos)
	return local_pos + viewport_size * 0.5


func _is_on_screen(screen_pos: Vector2, viewport_size: Vector2) -> bool:
	return screen_pos.x >= 0.0 and screen_pos.x <= viewport_size.x \
		and screen_pos.y >= 0.0 and screen_pos.y <= viewport_size.y


func _clamp_to_screen_edge(
	center: Vector2,
	direction: Vector2,
	viewport_size: Vector2,
	margin: float
) -> Vector2:
	var half := viewport_size * 0.5 - Vector2(margin, margin)
	var abs_dir := direction.abs()
	var scale_factor := INF
	if abs_dir.x > 0.001:
		scale_factor = minf(scale_factor, half.x / abs_dir.x)
	if abs_dir.y > 0.001:
		scale_factor = minf(scale_factor, half.y / abs_dir.y)
	return center + direction * scale_factor


func _draw_arrow(center: Vector2, direction: Vector2) -> void:
	var tip := center + direction * arrow_size
	var back := center - direction * arrow_size * 0.55
	var side := Vector2(-direction.y, direction.x) * arrow_size * 0.45
	var points := PackedVector2Array([tip, back + side, back - side])
	draw_colored_polygon(points, arrow_color)

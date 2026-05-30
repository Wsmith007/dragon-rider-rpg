extends Node2D
## Visual-only floor markers to make movement easier to read. No collision or gameplay impact.

@export var grid_spacing: float = 80.0
@export var area_half_size: float = 2400.0
@export var dot_radius: float = 2.5
@export var major_dot_radius: float = 4.0
@export var dot_color: Color = Color(0.2, 0.28, 0.15, 0.55)
@export var major_dot_color: Color = Color(0.26, 0.36, 0.19, 0.75)
@export var major_dot_every: int = 5


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var start := -area_half_size
	var end := area_half_size
	var column_index := 0

	for x in range(int(start), int(end) + 1, int(grid_spacing)):
		var row_index := 0
		for y in range(int(start), int(end) + 1, int(grid_spacing)):
			var is_major := column_index % major_dot_every == 0 and row_index % major_dot_every == 0
			var color := major_dot_color if is_major else dot_color
			var radius := major_dot_radius if is_major else dot_radius
			draw_circle(Vector2(x, y), radius, color)
			row_index += 1
		column_index += 1

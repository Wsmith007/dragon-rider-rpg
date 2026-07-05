extends Node
class_name PlayerPathBreadcrumbs
## Records recent rider positions for dragon companion following. Not pathfinding.


const MIN_POINT_DISTANCE := 24.0
const MAX_POINTS := 20
const CONSUME_RADIUS := 22.0
const WALL_COLLISION_MASK := 1


var _points: Array[Vector2] = []


func _ready() -> void:
	add_to_group("player_breadcrumbs")


func record_position(world_position: Vector2) -> void:
	if _points.is_empty():
		_points.append(world_position)
		return

	var last := _points[_points.size() - 1]
	if world_position.distance_to(last) < MIN_POINT_DISTANCE:
		return

	_points.append(world_position)
	while _points.size() > MAX_POINTS:
		_points.pop_front()


func consume_reached(dragon_position: Vector2) -> void:
	while not _points.is_empty():
		if dragon_position.distance_to(_points[0]) > CONSUME_RADIUS:
			break
		_points.pop_front()


func find_next_waypoint(from_position: Vector2, exclude_body: CharacterBody2D) -> Vector2:
	for point in _points:
		if from_position.distance_to(point) <= CONSUME_RADIUS:
			continue
		if not is_line_blocked(from_position, point, exclude_body):
			return point
	return Vector2.ZERO


func is_line_blocked(from_position: Vector2, to_position: Vector2, exclude_body: CharacterBody2D) -> bool:
	if from_position.distance_squared_to(to_position) < 64.0:
		return false

	var space := exclude_body.get_world_2d().direct_space_state if exclude_body != null else null
	if space == null:
		return false

	var query := PhysicsRayQueryParameters2D.create(from_position, to_position, WALL_COLLISION_MASK)
	if exclude_body != null:
		query.exclude = [exclude_body.get_rid()]
	return not space.intersect_ray(query).is_empty()


func get_point_count() -> int:
	return _points.size()


func get_points() -> Array[Vector2]:
	return _points.duplicate()


func clear_trail() -> void:
	_points.clear()

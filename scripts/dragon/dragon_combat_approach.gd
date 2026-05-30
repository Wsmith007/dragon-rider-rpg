class_name DragonCombatApproach
## Shared flank positioning for protection and assist strikes. No pathfinding.


static func compute_approach_point(
	dragon_position: Vector2,
	enemy_position: Vector2,
	rider_position: Vector2,
	flank_offset: float,
	player_clearance: float
) -> Vector2:
	var rider_to_enemy := enemy_position - rider_position
	if rider_to_enemy.length_squared() < 1.0:
		rider_to_enemy = enemy_position - dragon_position
	if rider_to_enemy.length_squared() < 1.0:
		return enemy_position

	var direction := rider_to_enemy.normalized()
	var perpendicular := Vector2(-direction.y, direction.x)
	var flank_a := enemy_position + perpendicular * flank_offset
	var flank_b := enemy_position - perpendicular * flank_offset
	var flank_point := flank_a
	if dragon_position.distance_to(flank_b) < dragon_position.distance_to(flank_a):
		flank_point = flank_b

	if segment_passes_near_point(dragon_position, enemy_position, rider_position, player_clearance):
		return flank_point
	return enemy_position


static func segment_passes_near_point(
	segment_start: Vector2,
	segment_end: Vector2,
	point: Vector2,
	clearance: float
) -> bool:
	var closest := Geometry2D.get_closest_point_to_segment(point, segment_start, segment_end)
	return point.distance_to(closest) < clearance

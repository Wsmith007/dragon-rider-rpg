extends RefCounted
class_name CharacterWallRecovery
## Lightweight wall slide + stuck recovery for CharacterBody2D. No pathfinding.


const STUCK_MOVE_EPS := 2.25
const STUCK_TIME_THRESHOLD := 0.34


static func move_with_recovery(
	body: CharacterBody2D,
	desired_velocity: Vector2,
	stuck_timer: float,
	delta: float,
) -> float:
	if body == null:
		return stuck_timer

	var start_pos := body.global_position
	body.velocity = desired_velocity
	body.move_and_slide()

	var moved := body.global_position.distance_to(start_pos)
	var intent := desired_velocity.length()

	if intent > 36.0 and moved < STUCK_MOVE_EPS:
		stuck_timer += delta
	else:
		stuck_timer = maxf(stuck_timer - delta * 2.5, 0.0)

	if stuck_timer >= STUCK_TIME_THRESHOLD:
		_try_unstick(body, desired_velocity, intent)
		stuck_timer = 0.0
	elif intent > 36.0 and moved < STUCK_MOVE_EPS:
		_try_wall_slide(body, desired_velocity)

	return stuck_timer


static func nudge_with_collision(body: CharacterBody2D, direction: Vector2, distance: float) -> void:
	if body == null or distance <= 0.0:
		return

	var motion := direction.normalized() * distance
	var collision := body.move_and_collide(motion)
	if collision:
		var slide := motion.slide(collision.get_normal())
		if slide.length_squared() > 0.25:
			body.move_and_collide(slide)


static func _try_wall_slide(body: CharacterBody2D, desired_velocity: Vector2) -> void:
	var collision := body.get_last_slide_collision()
	if collision == null:
		return

	var slide := desired_velocity.slide(collision.get_normal())
	if slide.length_squared() < desired_velocity.length_squared() * 0.08:
		return

	body.velocity = slide
	body.move_and_slide()


static func _try_unstick(body: CharacterBody2D, desired_velocity: Vector2, intent: float) -> void:
	var collision := body.get_last_slide_collision()
	if collision != null:
		var slide := desired_velocity.slide(collision.get_normal())
		if slide.length_squared() > 20.0:
			body.velocity = slide
			body.move_and_slide()
			return

	var tangent := Vector2(-desired_velocity.y, desired_velocity.x)
	if tangent.length_squared() < 0.01:
		return
	body.velocity = tangent.normalized() * intent * 0.58
	body.move_and_slide()

extends Node
## Player health testers invoked by DeveloperInputRouter.


const HEALTH_STEP: float = 10.0
const MIN_MAX_HEALTH: float = 10.0

var _player: CharacterBody2D


func bind_to_player(player: CharacterBody2D) -> void:
	_player = player


func apply_heal_step() -> void:
	var health := _get_health()
	if health == null:
		return
	health.heal(HEALTH_STEP)


func apply_max_health_up() -> void:
	var health := _get_health()
	if health == null:
		return
	health.increase_max_health(HEALTH_STEP, true)


func apply_max_health_down() -> void:
	var health := _get_health()
	if health == null:
		return
	health.decrease_max_health(HEALTH_STEP, MIN_MAX_HEALTH)


func _get_health() -> Health:
	if _player == null:
		return null
	return _player.get_node_or_null("Health") as Health

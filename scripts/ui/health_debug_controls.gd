extends Node
## Player / dragon health testers invoked by DeveloperInputRouter.


const HEALTH_STEP: float = 5.0
const MIN_MAX_HEALTH: float = 10.0
const DRAGON_DAMAGE_STEP: float = 10.0

var _player: CharacterBody2D
var _dragon: CharacterBody2D


func bind_to_player(player: CharacterBody2D) -> void:
	_player = player


func bind_to_dragon(dragon: CharacterBody2D) -> void:
	_dragon = dragon


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


func apply_dragon_damage_step() -> void:
	var survivability := _get_dragon_survivability()
	if survivability == null:
		return
	survivability.receive_damage(DRAGON_DAMAGE_STEP)


func apply_dragon_heal_step() -> void:
	var survivability := _get_dragon_survivability()
	if survivability == null:
		return
	survivability.heal(DRAGON_DAMAGE_STEP)


func force_dragon_knockout() -> void:
	var survivability := _get_dragon_survivability()
	if survivability == null:
		return
	survivability.force_knockout()


func force_dragon_revive() -> void:
	var survivability := _get_dragon_survivability()
	if survivability == null:
		return
	survivability.force_revive()


func _get_health() -> Health:
	if _player == null:
		return null
	return _player.get_node_or_null("Health") as Health


func _get_dragon_survivability() -> DragonSurvivability:
	if _dragon == null:
		return null
	return _dragon.get_node_or_null("Survivability") as DragonSurvivability

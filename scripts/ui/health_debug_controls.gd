extends Node
## Temporary player health testers via InputMap actions.


const HEALTH_STEP: float = 10.0
const MIN_MAX_HEALTH: float = 10.0

var _player: CharacterBody2D


func bind_to_player(player: CharacterBody2D) -> void:
	_player = player


func _input(event: InputEvent) -> void:
	if _player == null:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	var health := _player.get_node_or_null("Health") as Health
	if health == null:
		return

	if event.is_action("debug_health_heal"):
		health.heal(HEALTH_STEP)
		get_viewport().set_input_as_handled()
	elif event.is_action("debug_health_max_up"):
		health.increase_max_health(HEALTH_STEP, true)
		get_viewport().set_input_as_handled()
	elif event.is_action("debug_health_max_down"):
		health.decrease_max_health(HEALTH_STEP, MIN_MAX_HEALTH)
		get_viewport().set_input_as_handled()

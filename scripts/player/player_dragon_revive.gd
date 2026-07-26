extends Node
class_name PlayerDragonRevive
## Hold interact near a knocked-out dragon to revive. Cancels on damage, range loss, or nearby danger.


const INTERACT_ACTION := &"interact"

@export var enabled: bool = true

var _player: CharacterBody2D
var _health: Health
var _dragon: CharacterBody2D
var _survivability: DragonSurvivability
var _last_health: float = -1.0


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	if _player != null:
		_health = _player.get_node_or_null("Health") as Health
		if _health != null:
			_last_health = _health.current_health
			if not _health.health_changed.is_connected(_on_player_health_changed):
				_health.health_changed.connect(_on_player_health_changed)
	set_process(true)
	call_deferred("_find_dragon")


func _process(delta: float) -> void:
	if not enabled or _player == null:
		return
	if _survivability == null or not is_instance_valid(_survivability):
		_find_dragon()
		if _survivability == null:
			return

	if not _survivability.is_knocked_out():
		return

	var holding := Input.is_action_pressed(INTERACT_ACTION)
	_survivability.update_revive_interaction(_player, holding, delta)


func _on_player_health_changed(current: float, _maximum: float) -> void:
	if _last_health < 0.0:
		_last_health = current
		return
	if current < _last_health - 0.01 and _survivability != null:
		_survivability.cancel_revive_interaction()
	_last_health = current


func _find_dragon() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var dragons := tree.get_nodes_in_group("dragon")
	if dragons.is_empty():
		_dragon = null
		_survivability = null
		return
	_dragon = dragons[0] as CharacterBody2D
	if _dragon == null:
		_survivability = null
		return
	_survivability = _dragon.get_node_or_null("Survivability") as DragonSurvivability

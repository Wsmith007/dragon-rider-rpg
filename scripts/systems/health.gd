extends Node
class_name Health
## Reusable health component. Attach to Player, Enemy, or Dragon.

signal health_changed(current: float, maximum: float)
signal died


@export var max_health: float = 100.0

var current_health: float = 100.0
var _death_handled: bool = false


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if _death_handled or current_health <= 0.0:
		return
	if amount <= 0.0:
		return

	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		_handle_death()


func heal(amount: float) -> void:
	if _death_handled or current_health <= 0.0:
		return

	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func increase_max_health(amount: float, also_heal: bool = false) -> void:
	if _death_handled:
		return
	if amount <= 0.0:
		return

	max_health += amount
	if also_heal:
		current_health = minf(current_health + amount, max_health)
	else:
		current_health = minf(current_health, max_health)
	health_changed.emit(current_health, max_health)


func decrease_max_health(amount: float, minimum_max: float = 10.0) -> void:
	if _death_handled:
		return
	if amount <= 0.0:
		return

	max_health = maxf(max_health - amount, minimum_max)
	current_health = minf(current_health, max_health)
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return not _death_handled and current_health > 0.0


func _handle_death() -> void:
	if _death_handled:
		return
	_death_handled = true
	current_health = 0.0
	died.emit()

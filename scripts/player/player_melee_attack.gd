extends Node2D
## Simple melee hitbox. Enabled briefly on attack input.

signal attack_started
signal attack_hit(enemy: Node2D)


@export var damage: float = 25.0
@export var attack_duration: float = 0.12
@export var attack_cooldown: float = 0.35

@onready var _hitbox: Area2D = $Hitbox

var _cooldown_remaining: float = 0.0
var _attack_active: bool = false
var _hit_targets: Array[Node2D] = []


func _ready() -> void:
	_hitbox.monitoring = false
	_hitbox.body_entered.connect(_on_body_entered)
	_hitbox.area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)

	if _attack_active:
		return

	if _cooldown_remaining > 0.0:
		return

	if not Input.is_action_just_pressed("attack"):
		return

	_perform_attack()


func _perform_attack() -> void:
	_attack_active = true
	_cooldown_remaining = attack_cooldown
	_hit_targets.clear()
	_hitbox.monitoring = true
	attack_started.emit()

	await get_tree().create_timer(attack_duration).timeout
	_hitbox.monitoring = false
	_attack_active = false


func _on_body_entered(body: Node2D) -> void:
	_try_damage(body)


func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Node2D:
		_try_damage(parent as Node2D)


func _try_damage(target: Node2D) -> void:
	if target in _hit_targets:
		return
	if not target.is_in_group("enemy"):
		return

	var health := target.get_node_or_null("Health") as Health
	if health == null or not health.is_alive():
		return

	_hit_targets.append(target)
	health.take_damage(damage)
	attack_hit.emit(target)

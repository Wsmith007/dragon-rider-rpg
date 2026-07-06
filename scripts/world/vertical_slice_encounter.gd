extends Area2D
class_name VerticalSliceEncounter
## Triggers a named slice encounter when the player enters. Spawns archetype-tuned enemies once.


signal encounter_started(encounter_name: String)
signal encounter_cleared(encounter_name: String)

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/Enemy.tscn")

@export var encounter_name: String = ""
@export var one_shot: bool = true
@export var spawn_on_ready: bool = false

## Each entry: { "archetype": VerticalSliceArchetypePresets.Archetype, "offset": Vector2 }
@export var spawn_specs: Array[Dictionary] = []

var _triggered: bool = false
var _cleared: bool = false
var _spawned_enemies: Array[CharacterBody2D] = []
var _enemies_container: Node2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = not spawn_on_ready
	monitorable = false
	body_entered.connect(_on_body_entered)

	if spawn_on_ready:
		_activate()


func bind_enemies_container(container: Node2D) -> void:
	_enemies_container = container


func configure(encounter_label: String, specs: Array) -> void:
	encounter_name = encounter_label
	spawn_specs.clear()
	for spec in specs:
		spawn_specs.append(spec as Dictionary)


func _on_body_entered(body: Node2D) -> void:
	if _triggered and one_shot:
		return
	if not body.is_in_group("player"):
		return
	_activate()


func _activate() -> void:
	if _triggered and one_shot:
		return
	if _enemies_container == null:
		push_warning("VerticalSliceEncounter '%s': enemies container not bound." % encounter_name)
		return

	_triggered = true
	call_deferred("_spawn_enemies")
	encounter_started.emit(encounter_name)
	set_deferred("monitoring", false)


func _spawn_enemies() -> void:
	_spawned_enemies.clear()
	var index := 0
	for spec in spawn_specs:
		var archetype: VerticalSliceArchetypePresets.Archetype = spec.get(
			"archetype", VerticalSliceArchetypePresets.Archetype.RAIDER
		)
		var offset: Vector2 = spec.get("offset", Vector2.ZERO)
		var enemy := ENEMY_SCENE.instantiate() as CharacterBody2D
		if enemy == null:
			continue
		index += 1
		enemy.name = "%s_%s_%d" % [
			encounter_name.replace(" ", ""),
			VerticalSliceArchetypePresets.archetype_name(archetype),
			index,
		]
		VerticalSliceArchetypePresets.apply_to_enemy(enemy, archetype)
		enemy.global_position = global_position + offset
		_enemies_container.add_child(enemy)
		_spawned_enemies.append(enemy)
		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(_enemy: Node) -> void:
	if _cleared:
		return
	for spawned in _spawned_enemies:
		if not is_instance_valid(spawned):
			continue
		if spawned.is_dead:
			continue
		return
	_cleared = true
	encounter_cleared.emit(encounter_name)


func reset_encounter() -> void:
	_cleared = false
	_triggered = false
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()
	monitoring = not spawn_on_ready

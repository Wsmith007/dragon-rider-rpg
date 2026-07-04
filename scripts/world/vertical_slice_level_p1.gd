extends Node2D
## Vertical Slice Level Prototype Pass 1 — graybox teaching layout.


const SPAWN_PLAYER := Vector2(-1180, 0)
const SPAWN_DRAGON := Vector2(-1180, 38)
const QUIET_GROVE_ZONE := "The Quiet Grove"

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/Enemy.tscn")

@onready var _player: CharacterBody2D = $Entities/Player
@onready var _dragon: CharacterBody2D = $Entities/Dragon
@onready var _enemies: Node2D = $Entities/Enemies
@onready var _zone_label: Label = $UI/SliceZoneLabel


func _ready() -> void:
	_configure_encounters()
	_bind_zone_notifiers()


func _configure_encounters() -> void:
	_setup_encounter(
		$Encounters/TheAmbush,
		"The Ambush",
		[ {"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(90, -10)} ],
	)
	_setup_encounter(
		$Encounters/TheCrossing,
		"The Crossing",
		[ {"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(0, 20)} ],
	)
	_setup_encounter(
		$Encounters/TheCrossroads,
		"The Crossroads",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(-70, -30)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(80, 25)},
		],
	)
	_setup_encounter(
		$Encounters/TheHold,
		"The Hold",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(-60, 0)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(60, 0)},
		],
	)
	_setup_encounter(
		$Encounters/TheGate,
		"The Gate",
		[ {"archetype": VerticalSliceArchetypePresets.Archetype.BRUTE, "offset": Vector2(0, 0)} ],
	)
	_setup_encounter(
		$Encounters/TheFork,
		"The Fork",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(-75, -25)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.BRUTE, "offset": Vector2(85, 15)},
		],
	)
	_setup_encounter(
		$Encounters/TheLastStand,
		"The Last Stand",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(-100, -35)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(0, 40)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.BRUTE, "offset": Vector2(95, -15)},
		],
	)


func _setup_encounter(
	encounter: VerticalSliceEncounter,
	encounter_name: String,
	specs: Array,
) -> void:
	if encounter == null:
		return
	encounter.bind_enemies_container(_enemies)
	encounter.configure(encounter_name, specs)


func _bind_zone_notifiers() -> void:
	var container := $ZoneNotifiers
	for child in container.get_children():
		child.queue_free()

	for zone in VerticalSliceGrayboxGeometry.ZONE_LAYOUT:
		var zone_name: String = zone.get("name", "")
		var rect: Rect2 = zone.get("rect", Rect2())
		var area := Area2D.new()
		area.name = zone_name.replace(" ", "_")
		area.collision_layer = 0
		area.collision_mask = 1
		area.monitorable = false
		area.position = rect.get_center()

		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = rect.size
		shape.shape = rect_shape
		area.add_child(shape)
		container.add_child(area)
		area.body_entered.connect(_on_zone_entered.bind(zone_name))
		area.body_exited.connect(_on_zone_exited.bind(zone_name))


func _on_zone_entered(body: Node2D, zone_name: String) -> void:
	if not body.is_in_group("player"):
		return
	if _zone_label != null:
		_zone_label.text = zone_name
	if zone_name == QUIET_GROVE_ZONE:
		_apply_quiet_grove_rest()


func _on_zone_exited(body: Node2D, zone_name: String) -> void:
	if not body.is_in_group("player"):
		return
	if zone_name == QUIET_GROVE_ZONE:
		_player.set_combat_safe_zone(false)


func _apply_quiet_grove_rest() -> void:
	_player.set_combat_safe_zone(true)

	var player_health := _player.get_node("Health") as Health
	if player_health != null and player_health.is_alive():
		player_health.restore_full()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.keycode == KEY_R and event.shift_pressed:
		restart_slice()
		get_viewport().set_input_as_handled()


func restart_slice() -> void:
	_player.global_position = SPAWN_PLAYER
	_player.velocity = Vector2.ZERO
	_dragon.global_position = SPAWN_DRAGON
	_dragon.velocity = Vector2.ZERO

	var player_health: Health = _player.get_node("Health") as Health
	if player_health != null:
		player_health._death_handled = false
		player_health.current_health = player_health.max_health
		player_health.health_changed.emit(player_health.current_health, player_health.max_health)

	_player._is_dead = false
	_player._combat_stagger_remaining = 0.0
	_player.set_combat_safe_zone(false)
	_player.set_physics_process(true)
	_player.reset_attack_move_speed_multiplier()
	_player.velocity = Vector2.ZERO
	var melee := _player.get_node("MeleeAttack")
	if melee != null:
		melee.set_physics_process(true)
	var visual := _player.get_node("Visual") as CanvasItem
	if visual != null:
		visual.modulate = Color.WHITE

	for child in _enemies.get_children():
		child.queue_free()

	for encounter in $Encounters.get_children():
		if encounter is VerticalSliceEncounter:
			(encounter as VerticalSliceEncounter).reset_encounter()

	if _zone_label != null:
		_zone_label.text = "The Clearing"

	print("VERTICAL SLICE | restart | Shift+R")

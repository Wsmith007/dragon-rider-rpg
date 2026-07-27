extends Node2D
## Cinderwatch Ridge -- Graybox Pass 1 / Identity Pass 4A.
## Terrain-first ridge identity; Core Memory at Broken Signal Span.


const SPAWN_PLAYER := Vector2(-1050, 10)
const SPAWN_DRAGON := Vector2(-1050, 48)
const HEARTH_GROVE_ZONE := "Hearth Grove"

const CORE_MEMORY_WAIT_SECONDS := 4.5
const STONE_WAIT_SECONDS := 2.8

@onready var _player: CharacterBody2D = $Entities/Player
@onready var _dragon: CharacterBody2D = $Entities/Dragon
@onready var _enemies: Node2D = $Entities/Enemies
@onready var _player_feedback: Control = $UI/PlayerFeedbackUI
@onready var _geometry: CinderwatchGrayboxGeometry = $GrayboxGeometry

var _core_memory_staged := false
var _ember_stone_staged := false
var _core_memory_timer: SceneTreeTimer
var _stone_timer: SceneTreeTimer


func _ready() -> void:
	_configure_encounters()
	_bind_zone_notifiers()
	_bind_dragon_staging_areas()
	call_deferred("_announce_starting_area")


func _configure_encounters() -> void:
	# Scrub Flank -- Scout hunting / ambushing travelers on the abandoned road
	_setup_encounter(
		$Encounters/ScrubAmbush,
		"Scrub Ambush",
		[{"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(40, -15)}],
	)
	# Occupied Road -- Raider scavenging / occupying the "easy" detour past the span
	_setup_encounter(
		$Encounters/OccupiedRoad,
		"Occupied Road",
		[{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(20, 25)}],
	)
	# Waystation Hold -- scavengers living in the hold
	_setup_encounter(
		$Encounters/WaystationHold,
		"Waystation Hold",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(-50, -10)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(55, 20)},
		],
	)
	# Old Watch Gate -- Brute guarding the fortified pinch
	_setup_encounter(
		$Encounters/OldWatchGate,
		"Old Watch Gate",
		[{"archetype": VerticalSliceArchetypePresets.Archetype.BRUTE, "offset": Vector2(0, 0)}],
	)
	# Outlook approach -- light mix occupying the last stretch (optional pressure before vista)
	_setup_encounter(
		$Encounters/OutlookApproach,
		"Outlook Approach",
		[
			{"archetype": VerticalSliceArchetypePresets.Archetype.SCOUT, "offset": Vector2(-60, -20)},
			{"archetype": VerticalSliceArchetypePresets.Archetype.RAIDER, "offset": Vector2(50, 15)},
		],
	)


func _setup_encounter(encounter: VerticalSliceEncounter, encounter_name: String, specs: Array) -> void:
	if encounter == null:
		return
	encounter.bind_enemies_container(_enemies)
	encounter.configure(encounter_name, specs)


func _bind_zone_notifiers() -> void:
	var container := $ZoneNotifiers
	for child in container.get_children():
		child.queue_free()

	for zone in CinderwatchGrayboxGeometry.ZONE_LAYOUT:
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


func _bind_dragon_staging_areas() -> void:
	# Temporary Pass 1 staging only -- not a permanent exploration AI system.
	var staging := $DragonStaging
	for child in staging.get_children():
		child.queue_free()

	_add_staging_trigger(
		staging,
		"CoreMemorySpan",
		Rect2(-620, -120, 280, 220),
		_on_core_memory_span_entered
	)
	_add_staging_trigger(
		staging,
		"EmberScarStone",
		Rect2(10, -310, 70, 70),
		_on_ember_stone_entered
	)


func _add_staging_trigger(parent: Node2D, trigger_name: String, rect: Rect2, callback: Callable) -> void:
	var area := Area2D.new()
	area.name = trigger_name
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	area.position = rect.get_center()
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	shape.shape = rect_shape
	area.add_child(shape)
	parent.add_child(area)
	area.body_entered.connect(func(body: Node2D) -> void: callback.call(body))


func _on_zone_entered(body: Node2D, zone_name: String) -> void:
	if not body.is_in_group("player"):
		return
	_announce_area(zone_name)
	if zone_name == HEARTH_GROVE_ZONE:
		_apply_hearth_grove_rest()


func _on_zone_exited(body: Node2D, zone_name: String) -> void:
	if not body.is_in_group("player"):
		return
	if zone_name == HEARTH_GROVE_ZONE:
		_player.set_combat_safe_zone(false)


func _on_core_memory_span_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _core_memory_staged:
		return
	_core_memory_staged = true
	# Shared observation: dragon holds at the lip, looking across the collapse toward the far road.
	var wait_point := _geometry.get_grove_hesitation_point()
	_dragon.command_behavior.set_wait(wait_point)
	_show_moment("Your dragon watches the broken span...")
	print("CINDERWATCH | Core Memory staging | shared observation at ravine")
	_core_memory_timer = get_tree().create_timer(CORE_MEMORY_WAIT_SECONDS)
	_core_memory_timer.timeout.connect(_release_dragon_from_core_memory, CONNECT_ONE_SHOT)


func _release_dragon_from_core_memory() -> void:
	if _dragon == null or not is_instance_valid(_dragon):
		return
	if _dragon.command_behavior.is_waiting:
		_dragon.command_behavior.recall()
	print("CINDERWATCH | Core Memory staging | dragon recalls")


func _on_ember_stone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _ember_stone_staged:
		return
	_ember_stone_staged = true
	var stone := _geometry.get_ember_stone_position()
	_dragon.command_behavior.set_wait(stone + Vector2(28, 10))
	_show_moment("Your dragon studies the ember-scarred stone.")
	print("CINDERWATCH | Ember-scar Stone staging")
	_stone_timer = get_tree().create_timer(STONE_WAIT_SECONDS)
	_stone_timer.timeout.connect(_release_dragon_from_stone, CONNECT_ONE_SHOT)


func _release_dragon_from_stone() -> void:
	if _dragon == null or not is_instance_valid(_dragon):
		return
	if _dragon.command_behavior.is_waiting:
		_dragon.command_behavior.recall()


func _apply_hearth_grove_rest() -> void:
	_player.set_combat_safe_zone(true)
	var player_health := _player.get_node("Health") as Health
	if player_health != null and player_health.is_alive():
		player_health.restore_full()


func _announce_area(area_name: String) -> void:
	if _player_feedback != null and _player_feedback.has_method("announce_area"):
		_player_feedback.announce_area(area_name)


func _show_moment(text: String) -> void:
	if _player_feedback != null and _player_feedback.has_method("show_toast"):
		_player_feedback.show_toast(text)
	elif _player_feedback != null and _player_feedback.has_method("announce_area"):
		_player_feedback.announce_area(text)


func _announce_starting_area() -> void:
	_announce_area("Western Approach")


func restart_slice() -> void:
	_core_memory_staged = false
	_ember_stone_staged = false
	_player.global_position = SPAWN_PLAYER
	_player.velocity = Vector2.ZERO
	_dragon.global_position = SPAWN_DRAGON
	_dragon.velocity = Vector2.ZERO
	if _dragon.command_behavior.is_waiting:
		_dragon.command_behavior.recall()

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
	var visual := _player.get_node_or_null("VisualPivot/SpinLayer/Visual") as CanvasItem
	if visual != null:
		visual.modulate = Color.WHITE

	for child in _enemies.get_children():
		child.queue_free()

	for encounter in $Encounters.get_children():
		if encounter is VerticalSliceEncounter:
			(encounter as VerticalSliceEncounter).reset_encounter()

	_announce_area("Western Approach")
	print("CINDERWATCH | restart | Shift+R")

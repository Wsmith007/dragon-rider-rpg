extends Node
## Debug-only enemy spawner for TestWorld. Places enemies at random positions near the player.


const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/Enemy.tscn")

const MIN_DISTANCE_FROM_PLAYER := 140.0
const MIN_DISTANCE_FROM_ENEMY := 48.0
const SPAWN_DISTANCE_MIN := 180.0
const SPAWN_DISTANCE_MAX := 520.0
const MAX_PLACEMENT_ATTEMPTS := 16
const PACK_SIZE := 3

var _player: CharacterBody2D
var _enemies_container: Node2D
var _spawn_counter: int = 0


func bind(player: CharacterBody2D, enemies_container: Node2D) -> void:
	_player = player
	_enemies_container = enemies_container


func spawn_random_enemy() -> CharacterBody2D:
	if _player == null or _enemies_container == null:
		push_warning("EnemySpawnDebug: bind player and enemies container before spawning.")
		return null

	var enemy := ENEMY_SCENE.instantiate() as CharacterBody2D
	if enemy == null:
		return null

	_spawn_counter += 1
	enemy.name = "SpawnedEnemy_%d" % _spawn_counter
	enemy.global_position = _pick_random_spawn_position()
	_enemies_container.add_child(enemy)
	print("DEBUG SPAWN | enemy=", enemy.name, " | pos=", enemy.global_position)
	return enemy


func spawn_random_pack(count: int = PACK_SIZE) -> void:
	for _i in count:
		spawn_random_enemy()


func _input(event: InputEvent) -> void:
	if _player == null or _enemies_container == null:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	if event.is_action("debug_spawn_enemy"):
		spawn_random_enemy()
		get_viewport().set_input_as_handled()
	elif event.is_action("debug_spawn_enemy_pack"):
		spawn_random_pack()
		get_viewport().set_input_as_handled()


func _pick_random_spawn_position() -> Vector2:
	var origin := _player.global_position

	for _attempt in MAX_PLACEMENT_ATTEMPTS:
		var angle := randf() * TAU
		var distance := randf_range(SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
		var candidate := origin + Vector2.from_angle(angle) * distance
		if _is_valid_spawn(candidate):
			return candidate

	return origin + Vector2.from_angle(randf() * TAU) * SPAWN_DISTANCE_MIN


func _is_valid_spawn(position: Vector2) -> bool:
	if position.distance_to(_player.global_position) < MIN_DISTANCE_FROM_PLAYER:
		return false

	for node in get_tree().get_nodes_in_group("enemy"):
		if not node is Node2D:
			continue
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and node.is_dead:
			continue
		if position.distance_to((node as Node2D).global_position) < MIN_DISTANCE_FROM_ENEMY:
			return false

	return true

extends RefCounted
class_name GameAudioBinder
## Connects existing gameplay signals to GameAudio events without gameplay logic changes.


var _audio: GameAudioService
var _game_root: Node2D
var _player: CharacterBody2D
var _dragon: CharacterBody2D
var _last_player_health: float = -1.0
var _focus_was_active: bool = false
var _focus_target_id: int = -1
var _bound_enemy_ids: Dictionary = {}
var _bound_tree: SceneTree
var _player_attack_impact_played: bool = false


func setup(audio: Node) -> void:
	_audio = audio as GameAudioService


func bind_game_root(game_root: Node2D) -> void:
	unbind_game_root()
	if game_root == null or _audio == null:
		return

	_game_root = game_root
	_audio.set_world_audio_root(game_root)

	_player = game_root.get_node_or_null("Entities/Player") as CharacterBody2D
	_dragon = game_root.get_node_or_null("Entities/Dragon") as CharacterBody2D

	_bind_player()
	_bind_dragon()
	_bind_relationship_system()
	_bind_existing_enemies()
	_connect_tree_signals(game_root)


func unbind_game_root() -> void:
	_disconnect_player_signals()
	_disconnect_dragon_signals()
	_disconnect_tree_signals()
	_bound_enemy_ids.clear()
	_player = null
	_dragon = null
	_game_root = null
	_last_player_health = -1.0
	_focus_was_active = false
	_focus_target_id = -1
	_player_attack_impact_played = false
	if _audio != null:
		_audio.set_world_audio_root(null)


func _bind_player() -> void:
	if _player == null:
		return

	if _player.has_signal("player_damaged") and not _player.player_damaged.is_connected(_on_player_damaged):
		_player.player_damaged.connect(_on_player_damaged)
		_last_player_health = _get_player_health()

	var melee := _player.get_node_or_null("MeleeAttack")
	if melee == null:
		return

	if melee.has_signal("attack_swing_started") and not melee.attack_swing_started.is_connected(_on_attack_swing_started):
		melee.attack_swing_started.connect(_on_attack_swing_started)
	if melee.has_signal("attack_swing_finished") and not melee.attack_swing_finished.is_connected(_on_attack_swing_finished):
		melee.attack_swing_finished.connect(_on_attack_swing_finished)
	if melee.has_signal("attack_hit") and not melee.attack_hit.is_connected(_on_attack_hit):
		melee.attack_hit.connect(_on_attack_hit)

	var target_focus := _player.get_node_or_null("TargetFocus") as PlayerTargetFocus
	if target_focus != null and not target_focus.focus_changed.is_connected(_on_focus_changed):
		target_focus.focus_changed.connect(_on_focus_changed)
		_focus_was_active = target_focus.is_focus_active()
		var focused := target_focus.get_focused_enemy()
		_focus_target_id = focused.get_instance_id() if focused != null else -1


func _bind_dragon() -> void:
	if _dragon == null:
		return

	var strike_behavior := _dragon.get_node_or_null("StrikeBehavior") as DragonStrikeBehavior
	if strike_behavior != null and not strike_behavior.strike_started.is_connected(_on_dragon_strike_started):
		strike_behavior.strike_started.connect(_on_dragon_strike_started)

	var command_behavior := _dragon.get_node_or_null("CommandBehavior") as DragonCommandBehavior
	if command_behavior != null and not command_behavior.wait_position_set.is_connected(_on_dragon_wait_ack):
		command_behavior.wait_position_set.connect(_on_dragon_wait_ack)


func _bind_relationship_system() -> void:
	if not RelationshipSystem.encounter_result_ready.is_connected(_on_encounter_result_ready):
		RelationshipSystem.encounter_result_ready.connect(_on_encounter_result_ready)
	if not RelationshipSystem.relationship_stats_applied.is_connected(_on_relationship_stats_applied):
		RelationshipSystem.relationship_stats_applied.connect(_on_relationship_stats_applied)


func _connect_tree_signals(game_root: Node2D) -> void:
	var tree := game_root.get_tree()
	if tree == null:
		return
	_bound_tree = tree
	if not tree.node_added.is_connected(_on_node_added):
		tree.node_added.connect(_on_node_added)


func _disconnect_tree_signals() -> void:
	if _bound_tree != null and _bound_tree.node_added.is_connected(_on_node_added):
		_bound_tree.node_added.disconnect(_on_node_added)
	_bound_tree = null


func _disconnect_player_signals() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if _player.has_signal("player_damaged") and _player.player_damaged.is_connected(_on_player_damaged):
		_player.player_damaged.disconnect(_on_player_damaged)
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee != null:
		if melee.has_signal("attack_swing_started") and melee.attack_swing_started.is_connected(_on_attack_swing_started):
			melee.attack_swing_started.disconnect(_on_attack_swing_started)
		if melee.has_signal("attack_swing_finished") and melee.attack_swing_finished.is_connected(_on_attack_swing_finished):
			melee.attack_swing_finished.disconnect(_on_attack_swing_finished)
		if melee.has_signal("attack_hit") and melee.attack_hit.is_connected(_on_attack_hit):
			melee.attack_hit.disconnect(_on_attack_hit)
	var target_focus := _player.get_node_or_null("TargetFocus") as PlayerTargetFocus
	if target_focus != null and target_focus.focus_changed.is_connected(_on_focus_changed):
		target_focus.focus_changed.disconnect(_on_focus_changed)


func _disconnect_dragon_signals() -> void:
	if _dragon == null or not is_instance_valid(_dragon):
		return
	var strike_behavior := _dragon.get_node_or_null("StrikeBehavior") as DragonStrikeBehavior
	if strike_behavior != null and strike_behavior.strike_started.is_connected(_on_dragon_strike_started):
		strike_behavior.strike_started.disconnect(_on_dragon_strike_started)
	var command_behavior := _dragon.get_node_or_null("CommandBehavior") as DragonCommandBehavior
	if command_behavior != null and command_behavior.wait_position_set.is_connected(_on_dragon_wait_ack):
		command_behavior.wait_position_set.disconnect(_on_dragon_wait_ack)


func _bind_existing_enemies() -> void:
	if _game_root == null:
		return
	for node in _game_root.get_tree().get_nodes_in_group("enemy"):
		_bind_enemy(node)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("enemy"):
		_bind_enemy(node)


func _bind_enemy(node: Node) -> void:
	if not node is CharacterBody2D:
		return
	var enemy := node as CharacterBody2D
	var enemy_id := enemy.get_instance_id()
	if _bound_enemy_ids.has(enemy_id):
		return
	_bound_enemy_ids[enemy_id] = true

	if enemy.has_signal("enemy_died") and not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)
	if enemy.has_signal("attacked_player") and not enemy.attacked_player.is_connected(_on_enemy_attacked_player):
		enemy.attacked_player.connect(_on_enemy_attacked_player.bind(enemy))


func _on_attack_swing_started(is_crowd_control: bool) -> void:
	_player_attack_impact_played = false
	var position := _player.global_position if _player != null else Vector2.ZERO
	var profile_id := _get_weapon_profile_id()
	if is_crowd_control:
		var windup := _get_cc_windup_duration()
		_audio.play_cc_swing_sequence(profile_id, position, windup)
	else:
		_audio.play_weapon_swing(profile_id, -1, position)


func _get_weapon_profile_id() -> WeaponProfilePrototype.Id:
	if _player == null:
		return WeaponProfilePrototype.Id.DAGGER
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee == null:
		return WeaponProfilePrototype.Id.DAGGER
	return melee.weapon_profile as WeaponProfilePrototype.Id


func _get_cc_windup_duration() -> float:
	if _player == null:
		return 0.17
	var melee := _player.get_node_or_null("MeleeAttack")
	if melee == null:
		return 0.17
	return float(melee.crowd_control_windup)


func _on_attack_swing_finished(_is_crowd_control: bool, did_hit: bool) -> void:
	if did_hit:
		return
	var position := _player.global_position if _player != null else Vector2.ZERO
	_audio.play(GameAudioEvent.Event.ATTACK_MISS, position)


func _on_attack_hit(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if _player_attack_impact_played:
		if _audio.has_method("defer_hit_evaluation"):
			_audio.defer_hit_evaluation(enemy)
		return

	_player_attack_impact_played = true
	var position := enemy.global_position
	if _player != null:
		# Anchor melee confirm near the listener while keeping slight spatial offset toward the target.
		position = _player.global_position.lerp(enemy.global_position, 0.35)

	var identity_id := WeaponIdentity.from_weapon_profile(_get_weapon_profile_id())
	_audio.play_weapon_impact(identity_id, position)
	if _audio.has_method("defer_hit_evaluation"):
		_audio.defer_hit_evaluation(enemy)


func _on_player_damaged(current: float, _maximum: float) -> void:
	if _last_player_health < 0.0:
		_last_player_health = current
		return
	if current < _last_player_health - 0.01:
		var position := _player.global_position if _player != null else Vector2.ZERO
		_audio.play(GameAudioEvent.Event.PLAYER_DAMAGED, position)
	_last_player_health = current


func _on_enemy_died(enemy: Node) -> void:
	if enemy is Node2D:
		_audio.play(GameAudioEvent.Event.ENEMY_DEFEATED, (enemy as Node2D).global_position)


func _on_enemy_attacked_player(enemy: CharacterBody2D) -> void:
	var position := _player.global_position if _player != null else enemy.global_position
	var identity_id := _get_enemy_weapon_identity(enemy)
	_audio.play_weapon_impact(identity_id, position)


func _on_focus_changed(active: bool, target: Node2D) -> void:
	if active:
		var target_id := target.get_instance_id() if target != null else -1
		if _focus_was_active and target_id != _focus_target_id and target_id >= 0:
			_audio.play(GameAudioEvent.Event.TARGET_FOCUS_SWITCH)
		elif not _focus_was_active:
			_audio.play(GameAudioEvent.Event.TARGET_FOCUS_ON)
		_focus_target_id = target_id
	else:
		if _focus_was_active:
			_audio.play(GameAudioEvent.Event.TARGET_FOCUS_OFF)
		_focus_target_id = -1
	_focus_was_active = active


func _on_encounter_result_ready(
	_summary: RelationshipEncounterSummary,
	_quality: EncounterQualityClassifier.Quality,
	_proposed: ProposedRelationshipDeltas
) -> void:
	_audio.play(GameAudioEvent.Event.ENCOUNTER_COMPLETE)


func _on_relationship_stats_applied(
	_encounter_id: String,
	sync_delta: float,
	instability_delta: float
) -> void:
	if sync_delta > 0.01 or instability_delta < -0.01:
		_audio.play(GameAudioEvent.Event.RELATIONSHIP_IMPROVED)
	elif sync_delta < -0.01 or instability_delta > 0.01:
		_audio.play(GameAudioEvent.Event.RELATIONSHIP_STRAINED)


func _on_dragon_strike_started(_enemy: Node2D, kind: DragonStrikeBehavior.StrikeKind) -> void:
	if _dragon == null:
		return
	var position := _dragon.global_position
	match kind:
		DragonStrikeBehavior.StrikeKind.ASSIST:
			_audio.play(GameAudioEvent.Event.DRAGON_ASSIST, position)
		DragonStrikeBehavior.StrikeKind.PROTECTION:
			_audio.play(GameAudioEvent.Event.DRAGON_PROTECT, position)


func _on_dragon_wait_ack(_wait_pos: Vector2) -> void:
	if _dragon == null:
		return
	_audio.play(GameAudioEvent.Event.DRAGON_WAIT, _dragon.global_position)


func evaluate_enemy_hit_result(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if not enemy.has_method("is_staggered"):
		return
	if enemy.is_staggered():
		return
	if not _is_brute(enemy):
		return
	_audio.play(GameAudioEvent.Event.BRUTE_RESIST, enemy.global_position)


func _get_enemy_weapon_identity(enemy: CharacterBody2D) -> WeaponIdentity.Id:
	if enemy.has_method("get_weapon_identity"):
		return enemy.get_weapon_identity()
	if enemy.has_meta("weapon_identity"):
		return enemy.get_meta("weapon_identity") as WeaponIdentity.Id
	return WeaponIdentity.Id.SWORD


func _is_brute(enemy: Node2D) -> bool:
	if enemy.has_method("_get_archetype"):
		return enemy.call("_get_archetype") == VerticalSliceArchetypePresets.Archetype.BRUTE
	if enemy.has_meta("slice_archetype"):
		return int(enemy.get_meta("slice_archetype")) == VerticalSliceArchetypePresets.Archetype.BRUTE
	return false


func _get_player_health() -> float:
	if _player == null:
		return -1.0
	var health := _player.get_node_or_null("Health") as Health
	if health == null:
		return -1.0
	return health.current_health

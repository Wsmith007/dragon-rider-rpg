extends Node
class_name DragonSurvivability
## Dragon HP, knockout, revival, and KO bond consequences (Survivability Pass 1).
## Never permanently dies — KNOCKED_OUT until danger clears and recovery completes.


enum SurvivabilityState {
	ACTIVE,
	KNOCKED_OUT,
}

signal health_changed(current_health: float, maximum_health: float)
signal survivability_state_changed(state: SurvivabilityState)
signal damaged(amount: float, current_health: float)
signal knocked_out
signal revived

## Evaluated vs Scout 6 / Raider 10 / Brute 18 → ~8 / 5 / ~3 hits.
@export var max_health: float = 50.0
@export var knockout_at_zero: bool = true
## Applied once per knockout via BondSystem.apply_sync_delta(-value). Restored after duration.
@export var sync_penalty_on_knockout: float = 10.0
@export var sync_penalty_duration: float = 12.0
## Applied once per knockout via BondSystem.apply_instability_delta(+value). Not auto-cleared.
@export var instability_on_knockout: float = 25.0
@export var revive_health_ratio: float = 0.35
@export var revive_delay_after_clear: float = 2.5
@export var post_revive_grace_duration: float = 2.0
@export var hit_invulnerability_duration: float = 0.15
@export var danger_clear_radius: float = 300.0

var current_health: float = 50.0
var state: SurvivabilityState = SurvivabilityState.ACTIVE
var _initialized: bool = false
var _hit_invuln_remaining: float = 0.0
var _grace_remaining: float = 0.0
var _revive_clear_timer: float = 0.0
var _sync_penalty_remaining: float = 0.0
var _sync_penalty_active_amount: float = 0.0
var _knockout_penalties_applied: bool = false
var _dragon: CharacterBody2D


func _ready() -> void:
	_dragon = get_parent() as CharacterBody2D
	if not _initialized:
		current_health = max_health
		_initialized = true
	set_process(true)
	health_changed.emit(current_health, max_health)


func _process(delta: float) -> void:
	_hit_invuln_remaining = maxf(_hit_invuln_remaining - delta, 0.0)
	_grace_remaining = maxf(_grace_remaining - delta, 0.0)
	_tick_sync_penalty(delta)

	if state == SurvivabilityState.KNOCKED_OUT:
		_tick_knockout_recovery(delta)


func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health


func is_active() -> bool:
	return state == SurvivabilityState.ACTIVE


func is_knocked_out() -> bool:
	return state == SurvivabilityState.KNOCKED_OUT


func is_valid_enemy_target() -> bool:
	return is_active() and current_health > 0.0


func is_in_grace() -> bool:
	return _grace_remaining > 0.0


func reset_to_full() -> void:
	_clear_sync_penalty_if_active()
	_hit_invuln_remaining = 0.0
	_grace_remaining = 0.0
	_revive_clear_timer = 0.0
	_knockout_penalties_applied = false
	current_health = max_health
	if state != SurvivabilityState.ACTIVE:
		state = SurvivabilityState.ACTIVE
		survivability_state_changed.emit(state)
	health_changed.emit(current_health, max_health)


func receive_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	if not is_active():
		return
	if _grace_remaining > 0.0 or _hit_invuln_remaining > 0.0:
		return

	current_health = maxf(current_health - amount, 0.0)
	_hit_invuln_remaining = hit_invulnerability_duration
	damaged.emit(amount, current_health)
	health_changed.emit(current_health, max_health)

	if knockout_at_zero and current_health <= 0.0:
		_enter_knocked_out()


func heal(amount: float) -> void:
	if amount <= 0.0 or max_health <= 0.0:
		return
	if state == SurvivabilityState.KNOCKED_OUT:
		return
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func force_knockout() -> void:
	if state == SurvivabilityState.KNOCKED_OUT:
		return
	current_health = 0.0
	health_changed.emit(current_health, max_health)
	_enter_knocked_out()


func force_revive() -> void:
	if state != SurvivabilityState.KNOCKED_OUT:
		return
	_complete_revive()


## Pass 1: unused interact rescue — revival is automatic after danger clears.
func begin_rescue(_rescuer: Node) -> void:
	pass


func _enter_knocked_out() -> void:
	if state == SurvivabilityState.KNOCKED_OUT:
		return

	state = SurvivabilityState.KNOCKED_OUT
	current_health = 0.0
	_revive_clear_timer = 0.0
	_hit_invuln_remaining = 0.0
	survivability_state_changed.emit(state)
	knocked_out.emit()
	_apply_knockout_penalties_once()

	if _dragon != null and _dragon.has_method("on_survivability_knocked_out"):
		_dragon.on_survivability_knocked_out()


func _apply_knockout_penalties_once() -> void:
	if _knockout_penalties_applied:
		return
	_knockout_penalties_applied = true

	var bond := get_node_or_null("/root/BondSystem")
	if bond == null:
		return

	if instability_on_knockout != 0.0 and bond.has_method("apply_instability_delta"):
		bond.apply_instability_delta(instability_on_knockout)

	if sync_penalty_on_knockout != 0.0 and bond.has_method("apply_sync_delta"):
		# Temporary Sync: apply negative once; restore the same amount when the timer expires.
		# If a prior penalty is still active, refresh the timer only — do not stack another −Sync.
		if _sync_penalty_active_amount <= 0.0:
			bond.apply_sync_delta(-absf(sync_penalty_on_knockout))
			_sync_penalty_active_amount = absf(sync_penalty_on_knockout)
		_sync_penalty_remaining = sync_penalty_duration


func _tick_sync_penalty(delta: float) -> void:
	if _sync_penalty_active_amount <= 0.0:
		return
	_sync_penalty_remaining -= delta
	if _sync_penalty_remaining > 0.0:
		return
	_clear_sync_penalty_if_active()


func _clear_sync_penalty_if_active() -> void:
	if _sync_penalty_active_amount <= 0.0:
		return
	var restore := _sync_penalty_active_amount
	_sync_penalty_active_amount = 0.0
	_sync_penalty_remaining = 0.0
	var bond := get_node_or_null("/root/BondSystem")
	if bond != null and bond.has_method("apply_sync_delta"):
		bond.apply_sync_delta(restore)


func _tick_knockout_recovery(delta: float) -> void:
	if _is_immediate_danger_clear():
		_revive_clear_timer += delta
	else:
		_revive_clear_timer = 0.0

	if _revive_clear_timer >= revive_delay_after_clear:
		_complete_revive()


func _is_immediate_danger_clear() -> bool:
	if _dragon == null or not is_instance_valid(_dragon):
		return false

	var player := _find_player()
	if player != null and player.has_method("is_in_combat_safe_zone") and player.is_in_combat_safe_zone():
		return true

	var relationship := get_node_or_null("/root/RelationshipSystem")
	if relationship != null and relationship.has_method("is_encounter_active"):
		if not relationship.is_encounter_active():
			# Still require no nearby living enemies so ambient spawns don't soft-lock revival.
			pass

	var origin := _dragon.global_position
	if player != null and is_instance_valid(player):
		origin = player.global_position

	var tree := get_tree()
	if tree == null:
		return false

	for node in tree.get_nodes_in_group("enemy"):
		if not is_instance_valid(node):
			continue
		if node.get("is_dead") == true:
			continue
		var health := node.get_node_or_null("Health") as Health
		if health != null and not health.is_alive():
			continue
		if node is Node2D and origin.distance_to((node as Node2D).global_position) <= danger_clear_radius:
			return false
	return true


func _complete_revive() -> void:
	if state != SurvivabilityState.KNOCKED_OUT:
		return

	current_health = maxf(max_health * revive_health_ratio, 1.0)
	state = SurvivabilityState.ACTIVE
	_knockout_penalties_applied = false
	_grace_remaining = post_revive_grace_duration
	_revive_clear_timer = 0.0
	_hit_invuln_remaining = hit_invulnerability_duration
	survivability_state_changed.emit(state)
	health_changed.emit(current_health, max_health)
	revived.emit()

	if _dragon != null and _dragon.has_method("on_survivability_revived"):
		_dragon.on_survivability_revived()


func _find_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var players := tree.get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D

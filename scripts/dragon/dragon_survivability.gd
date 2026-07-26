extends Node
class_name DragonSurvivability
## Dragon HP, knockout, player-interact revival, and KO bond consequences.
## Never permanently dies — remains KNOCKED_OUT until the player revives it.


enum SurvivabilityState {
	ACTIVE,
	KNOCKED_OUT,
}

signal health_changed(current_health: float, maximum_health: float)
signal survivability_state_changed(state: SurvivabilityState)
signal damaged(amount: float, current_health: float)
signal knocked_out
signal revived
## progress 0–1; blocked_reason empty when ready ("danger" | "range" | "").
signal revive_prompt_changed(visible: bool, progress: float, blocked_reason: String)

## Evaluated vs Scout 6 / Raider 10 / Brute 18 → ~8 / 5 / ~3 hits.
@export var max_health: float = 50.0
@export var knockout_at_zero: bool = true
## Applied once per knockout via BondSystem.apply_sync_delta(-value). Restored after duration.
@export var sync_penalty_on_knockout: float = 10.0
## First-pass tuning: temporary Sync penalty lasts 60s (was 12s — too short in playtest).
@export var sync_penalty_duration: float = 60.0
## Applied once per knockout via BondSystem.apply_instability_delta(+value). Not auto-cleared.
@export var instability_on_knockout: float = 25.0
@export var revive_health_ratio: float = 0.35
@export var revive_hold_duration: float = 2.5
@export var revive_interact_range: float = 56.0
## Hostile enemies inside this radius of the dragon block revival.
@export var revive_danger_radius: float = 220.0
@export var post_revive_grace_duration: float = 2.0
@export var hit_invulnerability_duration: float = 0.15

var current_health: float = 50.0
var state: SurvivabilityState = SurvivabilityState.ACTIVE
var _initialized: bool = false
var _hit_invuln_remaining: float = 0.0
var _grace_remaining: float = 0.0
var _revive_hold_progress: float = 0.0
var _sync_penalty_remaining: float = 0.0
var _sync_penalty_active_amount: float = 0.0
var _knockout_penalties_applied: bool = false
var _prompt_visible: bool = false
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


func get_revive_hold_progress() -> float:
	if revive_hold_duration <= 0.0:
		return 0.0
	return clampf(_revive_hold_progress / revive_hold_duration, 0.0, 1.0)


func reset_to_full() -> void:
	_clear_sync_penalty_if_active()
	_hit_invuln_remaining = 0.0
	_grace_remaining = 0.0
	_cancel_revive_hold()
	_knockout_penalties_applied = false
	current_health = max_health
	if state != SurvivabilityState.ACTIVE:
		state = SurvivabilityState.ACTIVE
		survivability_state_changed.emit(state)
	health_changed.emit(current_health, max_health)
	_emit_prompt(false, 0.0, "")


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


## Player hold-to-revive. Call each frame from the revive interaction component.
func update_revive_interaction(rescuer: Node2D, holding: bool, delta: float) -> void:
	if state != SurvivabilityState.KNOCKED_OUT:
		_cancel_revive_hold()
		_emit_prompt(false, 0.0, "")
		return
	if rescuer == null or not is_instance_valid(rescuer) or _dragon == null:
		_cancel_revive_hold()
		_emit_prompt(false, 0.0, "")
		return

	var in_range := rescuer.global_position.distance_to(_dragon.global_position) <= revive_interact_range
	if not in_range:
		_cancel_revive_hold()
		_emit_prompt(false, 0.0, "")
		return

	if _has_nearby_hostile_danger():
		_cancel_revive_hold()
		_emit_prompt(true, 0.0, "danger")
		return

	_emit_prompt(true, get_revive_hold_progress(), "")
	if not holding:
		_cancel_revive_hold()
		_emit_prompt(true, 0.0, "")
		return

	_revive_hold_progress += delta
	_emit_prompt(true, get_revive_hold_progress(), "")
	if _revive_hold_progress >= revive_hold_duration:
		_complete_revive()


func cancel_revive_interaction() -> void:
	_cancel_revive_hold()
	if state == SurvivabilityState.KNOCKED_OUT and _dragon != null:
		var player := _find_player()
		if player != null and player.global_position.distance_to(_dragon.global_position) <= revive_interact_range:
			var reason := "danger" if _has_nearby_hostile_danger() else ""
			_emit_prompt(true, 0.0, reason)
			return
	_emit_prompt(false, 0.0, "")


## Legacy stub name — prefer update_revive_interaction.
func begin_rescue(rescuer: Node) -> void:
	if rescuer is Node2D:
		update_revive_interaction(rescuer as Node2D, true, 0.0)


func _enter_knocked_out() -> void:
	if state == SurvivabilityState.KNOCKED_OUT:
		return

	state = SurvivabilityState.KNOCKED_OUT
	current_health = 0.0
	_cancel_revive_hold()
	_hit_invuln_remaining = 0.0
	survivability_state_changed.emit(state)
	knocked_out.emit()
	_apply_knockout_penalties_once()
	_emit_prompt(false, 0.0, "")

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


func _has_nearby_hostile_danger() -> bool:
	if _dragon == null or not is_instance_valid(_dragon):
		return true
	var tree := get_tree()
	if tree == null:
		return true
	var origin := _dragon.global_position
	for node in tree.get_nodes_in_group("enemy"):
		if not is_instance_valid(node):
			continue
		if node.get("is_dead") == true:
			continue
		var health := node.get_node_or_null("Health") as Health
		if health != null and not health.is_alive():
			continue
		if node is Node2D and origin.distance_to((node as Node2D).global_position) <= revive_danger_radius:
			return true
	return false


func _complete_revive() -> void:
	if state != SurvivabilityState.KNOCKED_OUT:
		return

	current_health = maxf(max_health * revive_health_ratio, 1.0)
	state = SurvivabilityState.ACTIVE
	_knockout_penalties_applied = false
	_grace_remaining = post_revive_grace_duration
	_cancel_revive_hold()
	_hit_invuln_remaining = hit_invulnerability_duration
	survivability_state_changed.emit(state)
	health_changed.emit(current_health, max_health)
	revived.emit()
	_emit_prompt(false, 0.0, "")

	if _dragon != null and _dragon.has_method("on_survivability_revived"):
		_dragon.on_survivability_revived()


func _cancel_revive_hold() -> void:
	_revive_hold_progress = 0.0


func _emit_prompt(visible: bool, progress: float, blocked_reason: String) -> void:
	_prompt_visible = visible
	revive_prompt_changed.emit(visible, progress, blocked_reason)


func _find_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var players := tree.get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D

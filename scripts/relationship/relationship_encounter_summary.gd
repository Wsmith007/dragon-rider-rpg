extends RefCounted
class_name RelationshipEncounterSummary
## Accumulated counters for one local combat encounter. No stat writes.


enum ResolvedOutcome {
	NONE,
	UNRESOLVED,
	ENEMY_DEFEATED,
	PLAYER_DEATH,
	FLED_DISENGAGED,
	# Future — hooks only in Milestone 8:
	DRAGON_INJURED,
	DRAGON_DEATH,
	ENEMY_ESCAPED,
}


const MEANINGFUL_DAMAGE := 20.0


var encounter_id: String = ""
var started_at: float = 0.0
var ended_at: float = 0.0

var involved_enemy_ids: Array[int] = []

var successful_assists: int = 0
var assist_hesitations: int = 0
var assist_cancellations: int = 0
var protection_triggers: int = 0
var successful_protections: int = 0
var player_attacks_landed: int = 0
var enemies_defeated: int = 0
var player_damage_taken: float = 0.0
var player_near_death_count: int = 0
var player_died: bool = false
var commands_obeyed: int = 0
var commands_delayed: int = 0

var was_disengaged: bool = false
var disengage_count: int = 0
var reengaged_after_disengage: bool = false
var excellent_disqualified: bool = false

# Future — dragon health not implemented; reserved for encounter outcomes.
var dragon_damage_taken: float = 0.0
var dragon_near_death_count: int = 0
var dragon_critical: bool = false
var dragon_died: bool = false

var encounter_completed: bool = false
var encounter_failed: bool = false
var resolved_outcome: ResolvedOutcome = ResolvedOutcome.NONE


func get_involved_enemy_count() -> int:
	return involved_enemy_ids.size()


func get_dragon_successes() -> int:
	return successful_assists + successful_protections


func player_contributed_meaningfully() -> bool:
	return player_attacks_landed > 0


func dragon_contributed_meaningfully() -> bool:
	return get_dragon_successes() > 0


func refresh_excellent_disqualification() -> void:
	if was_disengaged or reengaged_after_disengage:
		excellent_disqualified = true
		return
	if assist_cancellations > 0 or player_near_death_count > 0 or player_died:
		excellent_disqualified = true
		return
	if not is_zero_approx(player_damage_taken):
		excellent_disqualified = true
		return
	if not is_zero_approx(dragon_damage_taken) or dragon_critical or dragon_died:
		excellent_disqualified = true


func is_excellent_eligible() -> bool:
	if excellent_disqualified or was_disengaged or reengaged_after_disengage:
		return false
	if player_died or player_near_death_count > 0:
		return false
	if assist_cancellations > 0:
		return false
	if not player_contributed_meaningfully() or not dragon_contributed_meaningfully():
		return false
	if not is_zero_approx(player_damage_taken):
		return false
	if not is_zero_approx(dragon_damage_taken) or dragon_critical or dragon_died:
		return false
	return true


func has_meaningful_combat_progress() -> bool:
	if enemies_defeated > 0 or player_died:
		return true
	if player_damage_taken >= MEANINGFUL_DAMAGE:
		return true
	if player_near_death_count >= 1:
		return true
	if assist_cancellations >= 2:
		return true
	if player_attacks_landed >= 2:
		return true
	var dragon_successes := get_dragon_successes()
	if player_attacks_landed >= 1 and dragon_successes >= 1:
		return true
	if dragon_successes >= 2:
		return true
	return false


static func outcome_label(outcome: ResolvedOutcome) -> String:
	match outcome:
		ResolvedOutcome.ENEMY_DEFEATED:
			return "Enemy Defeated"
		ResolvedOutcome.PLAYER_DEATH:
			return "Player Death"
		ResolvedOutcome.FLED_DISENGAGED:
			return "Fled / Disengaged"
		ResolvedOutcome.UNRESOLVED:
			return "Unresolved"
		ResolvedOutcome.DRAGON_INJURED:
			return "Dragon Injured"
		ResolvedOutcome.DRAGON_DEATH:
			return "Dragon Death"
		ResolvedOutcome.ENEMY_ESCAPED:
			return "Enemy Escaped"
		_:
			return "-"


static func yes_no(value: bool) -> String:
	return "YES" if value else "NO"


func duplicate_summary() -> RelationshipEncounterSummary:
	var copy := RelationshipEncounterSummary.new()
	copy.encounter_id = encounter_id
	copy.started_at = started_at
	copy.ended_at = ended_at
	copy.involved_enemy_ids = involved_enemy_ids.duplicate()
	copy.successful_assists = successful_assists
	copy.assist_hesitations = assist_hesitations
	copy.assist_cancellations = assist_cancellations
	copy.protection_triggers = protection_triggers
	copy.successful_protections = successful_protections
	copy.player_attacks_landed = player_attacks_landed
	copy.enemies_defeated = enemies_defeated
	copy.player_damage_taken = player_damage_taken
	copy.player_near_death_count = player_near_death_count
	copy.player_died = player_died
	copy.commands_obeyed = commands_obeyed
	copy.commands_delayed = commands_delayed
	copy.was_disengaged = was_disengaged
	copy.disengage_count = disengage_count
	copy.reengaged_after_disengage = reengaged_after_disengage
	copy.excellent_disqualified = excellent_disqualified
	copy.dragon_damage_taken = dragon_damage_taken
	copy.dragon_near_death_count = dragon_near_death_count
	copy.dragon_critical = dragon_critical
	copy.dragon_died = dragon_died
	copy.encounter_completed = encounter_completed
	copy.encounter_failed = encounter_failed
	copy.resolved_outcome = resolved_outcome
	return copy


func format_counter_summary() -> String:
	return (
		"assists=%d prot=%d cancel=%d player_hits=%d dmg=%.0f defeated=%d "
		+ "disengage=%d excellent=%s outcome=%s"
	) % [
		successful_assists,
		successful_protections,
		assist_cancellations,
		player_attacks_landed,
		player_damage_taken,
		enemies_defeated,
		disengage_count,
		yes_no(is_excellent_eligible()),
		outcome_label(resolved_outcome),
	]

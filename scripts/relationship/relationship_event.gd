extends RefCounted
class_name RelationshipEvent
## Lightweight relationship-relevant event. Observation only — no stat writes.


const COMBAT_ASSIST_SUCCEEDED := "combat.assist_succeeded"
const COMBAT_ASSIST_ATTEMPT_STARTED := "combat.assist_attempt_started"
const COMBAT_ASSIST_CANCELED := "combat.assist_canceled"
const COMBAT_ASSIST_HESITATED := "combat.assist_hesitated"
const COMBAT_PROTECTION_TRIGGERED := "combat.protection_triggered"
const COMBAT_PROTECTION_SUCCEEDED := "combat.protection_succeeded"
const COMBAT_ALERT_ENTERED := "combat.alert_entered"
const COMBAT_ENEMY_AGGRO_STARTED := "combat.enemy_aggro_started"
const COMBAT_PLAYER_DAMAGED_ENEMY := "combat.player_damaged_enemy"
const COMBAT_ENEMY_DAMAGED_PLAYER := "combat.enemy_damaged_player"
const COMBAT_PLAYER_DAMAGED := "combat.player_damaged"
const COMBAT_PLAYER_CRITICAL_HP := "combat.player_critical_hp"
const COMBAT_PLAYER_DEATH := "combat.player_death"
const COMBAT_ENEMY_DEFEATED := "combat.enemy_defeated"
const COMBAT_ENCOUNTER_COMPLETED := "combat.encounter_completed"
const COMBAT_ENCOUNTER_FAILED := "combat.encounter_failed"

const COMMAND_OBEYED := "command.obeyed"
const COMMAND_DELAYED := "command.delayed"

const EXPLORE_DISCOVERY := "explore.discovery"
const STORY_BONDING_MOMENT := "story.bonding_moment"


var event_id: String
var timestamp: float
var payload: Dictionary


func _init(id: String, data: Dictionary = {}) -> void:
	event_id = id
	timestamp = Time.get_ticks_msec() / 1000.0
	payload = data.duplicate()


static func create(id: String, data: Dictionary = {}) -> RelationshipEvent:
	return RelationshipEvent.new(id, data)

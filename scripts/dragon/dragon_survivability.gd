extends Node
class_name DragonSurvivability
## Foundation for future dragon knockout / rescue (Combat Stakes Pass 1).
## No knockout or revival gameplay yet — config + state hooks only.


enum SurvivabilityState {
	ACTIVE,
	## Future: dragon incapacitated until rescued / recovered.
	KNOCKED_OUT,
}

signal survivability_state_changed(state: SurvivabilityState)

@export var max_health: float = 40.0
@export var knockout_at_zero: bool = true
@export var sync_penalty_on_knockout: float = 8.0
@export var instability_on_knockout: float = 6.0

var current_health: float = 40.0
var state: SurvivabilityState = SurvivabilityState.ACTIVE
var _initialized: bool = false


func _ready() -> void:
	if not _initialized:
		current_health = max_health
		_initialized = true


func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health


func is_active() -> bool:
	return state == SurvivabilityState.ACTIVE


## Future: route enemy/environmental damage here. No-op in Pass 1.
func receive_damage(_amount: float) -> void:
	pass


## Future: player rescue / bond-assisted revive. No-op in Pass 1.
func begin_rescue(_rescuer: Node) -> void:
	pass


func _enter_knocked_out() -> void:
	if state == SurvivabilityState.KNOCKED_OUT:
		return
	state = SurvivabilityState.KNOCKED_OUT
	survivability_state_changed.emit(state)
	# Future: apply sync_penalty_on_knockout / instability_on_knockout via BondSystem.


func _recover_to_active() -> void:
	if state == SurvivabilityState.ACTIVE:
		return
	state = SurvivabilityState.ACTIVE
	current_health = maxf(current_health, 1.0)
	survivability_state_changed.emit(state)

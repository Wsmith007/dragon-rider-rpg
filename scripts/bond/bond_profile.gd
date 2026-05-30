extends Resource
class_name BondProfile
## Persistent rider–dragon bond data. Future systems read and modify through BondSystem.
##
## Active gameplay stats (3-stat model):
## - bond_strength — relationship depth; protection and future command responsiveness
## - sync — coordination; cooperative assist frequency
## - instability — strain; assist hesitation and cancellation


signal profile_changed

@export_range(0.0, 100.0) var bond_strength: float = 50.0:
	get:
		return _bond_strength
	set(value):
		var clamped := clampf(value, 0.0, 100.0)
		if is_equal_approx(_bond_strength, clamped):
			return
		_bond_strength = clamped
		_emit_changed()

@export_range(0.0, 100.0) var sync: float = 50.0:
	get:
		return _sync
	set(value):
		var clamped := clampf(value, 0.0, 100.0)
		if is_equal_approx(_sync, clamped):
			return
		_sync = clamped
		_emit_changed()

@export_range(0.0, 100.0) var instability: float = 0.0:
	get:
		return _instability
	set(value):
		var clamped := clampf(value, 0.0, 100.0)
		if is_equal_approx(_instability, clamped):
			return
		_instability = clamped
		_emit_changed()

## DEPRECATED: Retained for save compatibility and legacy references only.
## Not used for active gameplay decisions. Use bond_strength for relationship depth.
@export var trust_state: String = "Neutral":
	get:
		return _trust_state
	set(value):
		if _trust_state == value:
			return
		_trust_state = value
		_emit_changed()

var _bond_strength: float = 50.0
var _sync: float = 50.0
var _instability: float = 0.0
var _trust_state: String = "Neutral"


func reset_to_defaults() -> void:
	_bond_strength = 50.0
	_sync = 50.0
	_instability = 0.0
	_trust_state = "Neutral"
	_emit_changed()


static func get_command_response_delay(bond_strength: float) -> float:
	## Planned hook for Q wait/recall responsiveness under bond_strength (not wired yet).
	if bond_strength <= 25.0:
		return 0.75
	if bond_strength <= 50.0:
		return 0.50
	if bond_strength <= 75.0:
		return 0.25
	return 0.0


func _emit_changed() -> void:
	profile_changed.emit()

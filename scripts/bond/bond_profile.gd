extends Resource
class_name BondProfile
## Persistent rider–dragon bond data. Future systems read and modify through BondSystem.

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


func _emit_changed() -> void:
	profile_changed.emit()

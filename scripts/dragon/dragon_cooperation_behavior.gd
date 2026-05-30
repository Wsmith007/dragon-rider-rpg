extends Node
class_name DragonCooperationBehavior
## Cooperative assist gate: hesitation, then immediate cancel decision on completion.


enum HesitationOutcome { NONE, APPROVED, CANCELED }
enum AssistStartResult { BLOCKED, HESITATING, CANCELED, APPROVED }

@export_group("Hesitation Visual")
@export var hesitation_duration: float = 0.35
@export var shudder_speed: float = 14.0
@export var shudder_offset_amount: float = 1.2
@export var shudder_color_pulse: float = 0.08
@export var assist_cancel_cooldown_duration: float = 0.75

var _hesitation_remaining: float = 0.0
var _shudder_phase: float = 0.0
var _is_hesitating: bool = false
var _assist_cancel_cooldown: float = 0.0
var _pending_assist_target: Node2D
var _approved_assist_target: Node2D
var _completed_outcome: HesitationOutcome = HesitationOutcome.NONE


func tick(delta: float) -> void:
	_assist_cancel_cooldown = maxf(_assist_cancel_cooldown - delta, 0.0)

	if not _is_hesitating:
		return

	_hesitation_remaining = maxf(_hesitation_remaining - delta, 0.0)
	_shudder_phase += delta * shudder_speed

	if _hesitation_remaining <= 0.0:
		_complete_hesitation()


func is_hesitating() -> bool:
	return _is_hesitating


func can_attempt_cooperative_assist() -> bool:
	return _assist_cancel_cooldown <= 0.0 and not _is_hesitating


func has_pending_hesitation_outcome() -> bool:
	return _completed_outcome != HesitationOutcome.NONE


func take_approved_assist_target() -> Node2D:
	var target := _approved_assist_target
	_approved_assist_target = null
	_pending_assist_target = null
	if EnemyValidation.is_usable(target):
		return target
	return null


func consume_hesitation_outcome() -> HesitationOutcome:
	var outcome := _completed_outcome
	_completed_outcome = HesitationOutcome.NONE
	return outcome


func get_pending_assist_target() -> Node2D:
	if EnemyValidation.is_usable(_pending_assist_target):
		return _pending_assist_target
	return null


func clear_pending_assist_target() -> void:
	_pending_assist_target = null
	_approved_assist_target = null


func clear_enemy_reference(enemy) -> void:
	var enemy_id: int = EnemyValidation.resolve_instance_id(enemy)
	if enemy_id == -1:
		return

	if EnemyValidation.resolve_instance_id(_pending_assist_target) == enemy_id:
		_pending_assist_target = null
	if EnemyValidation.resolve_instance_id(_approved_assist_target) == enemy_id:
		_approved_assist_target = null

	if _is_hesitating and not EnemyValidation.is_usable(_pending_assist_target):
		_cancel_cooperative_assist("target_died", true)


## Phase 1 only: enter hesitation or immediate cancel check (no hesitation tier).
func request_cooperative_assist(target: Node2D) -> AssistStartResult:
	if _is_hesitating or _completed_outcome != HesitationOutcome.NONE:
		return AssistStartResult.BLOCKED
	if not can_attempt_cooperative_assist():
		return AssistStartResult.BLOCKED
	if not EnemyValidation.is_usable(target):
		return AssistStartResult.BLOCKED

	_pending_assist_target = target
	var instability := BondSystem.get_profile().instability
	var hesitation_chance := get_hesitation_chance(instability)
	var hesitation_roll := randf()
	var hesitation_triggered := hesitation_chance > 0.0 and hesitation_roll < hesitation_chance

	print(
		"HESITATION CHECK | roll=", snapped(hesitation_roll, 0.01),
		" | chance=", hesitation_chance,
		" | triggered=", hesitation_triggered
	)

	if hesitation_triggered:
		_start_hesitation()
		print("ENTER HESITATION")
		return AssistStartResult.HESITATING

	return _evaluate_immediate_cancel(instability)


func _complete_hesitation() -> void:
	print("HESITATION COMPLETE")
	_clear_hesitation_state()

	var instability := BondSystem.get_profile().instability
	if _roll_cancel_decision(instability, true):
		return

	_approve_cooperative_assist()


func _evaluate_immediate_cancel(instability: float) -> AssistStartResult:
	if _roll_cancel_decision(instability, false):
		return AssistStartResult.CANCELED

	print("BEGIN ASSIST")
	return AssistStartResult.APPROVED


func _roll_cancel_decision(instability: float, from_hesitation_completion: bool) -> bool:
	print("INSTABILITY VALUE | ", int(instability))
	var cancel_chance := get_cancel_chance(instability)
	var cancel_roll := randf()
	print("CANCEL CHANCE | ", cancel_chance)
	print("CANCEL ROLL | ", snapped(cancel_roll, 0.01))

	if cancel_roll < cancel_chance:
		print("CANCELED")
		var reason: String = "post_hesitation_cancel" if from_hesitation_completion else "immediate_cancel"
		_cancel_cooperative_assist(reason, from_hesitation_completion)
		return true

	print("APPROVED")
	return false


func _approve_cooperative_assist() -> void:
	_approved_assist_target = _pending_assist_target
	_completed_outcome = HesitationOutcome.APPROVED
	print("BEGIN ASSIST")


func cancel_cooperative_assist(reason: String) -> void:
	_cancel_cooperative_assist(reason, false)


func _cancel_cooperative_assist(reason: String, set_completion_outcome: bool) -> void:
	_clear_hesitation_state()
	_pending_assist_target = null
	_approved_assist_target = null
	if set_completion_outcome:
		_completed_outcome = HesitationOutcome.CANCELED
	_assist_cancel_cooldown = assist_cancel_cooldown_duration
	_clear_active_strike_assist(reason)
	print("RETURNING WITHOUT ASSIST | reason=", reason)


func _clear_active_strike_assist(reason: String) -> void:
	var dragon := get_parent()
	if dragon == null:
		return
	var strike := dragon.get_node_or_null("StrikeBehavior") as DragonStrikeBehavior
	if strike != null:
		strike.cancel_assist(reason)


func _start_hesitation() -> void:
	_is_hesitating = true
	_hesitation_remaining = hesitation_duration
	_shudder_phase = 0.0
	_completed_outcome = HesitationOutcome.NONE


func _clear_hesitation_state() -> void:
	_is_hesitating = false
	_hesitation_remaining = 0.0
	_shudder_phase = 0.0


static func get_cancel_chance(instability: float) -> float:
	if instability <= 25.0:
		return 0.0
	if instability <= 50.0:
		return 0.25
	if instability <= 75.0:
		return 0.50
	return 0.80


static func get_hesitation_chance(instability: float) -> float:
	if instability <= 25.0:
		return 0.0
	if instability <= 50.0:
		return 0.20
	if instability <= 75.0:
		return 0.40
	return 0.65


func get_shudder_visual_offset() -> Vector2:
	if not _is_hesitating:
		return Vector2.ZERO
	return Vector2(
		cos(_shudder_phase) * shudder_offset_amount,
		sin(_shudder_phase * 1.35) * shudder_offset_amount * 0.85
	)


func get_shudder_modulate(base: Color) -> Color:
	if not _is_hesitating:
		return base
	var pulse := 1.0 - shudder_color_pulse + shudder_color_pulse * sin(_shudder_phase * 1.4)
	return Color(base.r * pulse, base.g * pulse * 0.96, base.b * pulse * 1.02, base.a)

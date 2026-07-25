extends CanvasLayer
class_name CriticalHealthFeedback
## Low-health urgency: vignette + transition warning cues.
## Presentation only — does not change damage or health math.
## Authoritative health-band thresholds for HUD and vignette.


enum DangerTier { HEALTHY, WOUNDED, CRITICAL, NEAR_DEATH }

signal danger_tier_changed(tier: DangerTier)

@export var wounded_ratio: float = 0.50
@export var critical_ratio: float = 0.25
@export var near_death_ratio: float = 0.12
@export var vignette_pulse_speed: float = 3.2

var _vignette: ColorRect
var _tier: DangerTier = DangerTier.HEALTHY
var _pulse_phase: float = 0.0
var _bound_health: Health


func _ready() -> void:
	layer = 64
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_build_vignette()
	set_process(true)
	_apply_tier(DangerTier.HEALTHY, true)


func bind_to_player(player: CharacterBody2D) -> void:
	if _bound_health != null and _bound_health.health_changed.is_connected(_on_health_changed):
		_bound_health.health_changed.disconnect(_on_health_changed)
	_bound_health = null
	if player == null:
		_apply_tier(DangerTier.HEALTHY, true)
		return

	var health := player.get_node_or_null("Health") as Health
	if health == null:
		push_warning("CriticalHealthFeedback: player missing Health node.")
		return

	_bound_health = health
	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)
	_on_health_changed(health.current_health, health.max_health)


func tier_for_ratio(ratio: float) -> DangerTier:
	if ratio <= near_death_ratio:
		return DangerTier.NEAR_DEATH
	if ratio <= critical_ratio:
		return DangerTier.CRITICAL
	if ratio <= wounded_ratio:
		return DangerTier.WOUNDED
	return DangerTier.HEALTHY


func _build_vignette() -> void:
	_vignette = ColorRect.new()
	_vignette.name = "Vignette"
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.color = Color(0.55, 0.02, 0.04, 0.0)
	add_child(_vignette)


func _on_health_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	_apply_tier(tier_for_ratio(ratio), false)


func _apply_tier(tier: DangerTier, force: bool) -> void:
	if not force and tier == _tier:
		return
	var previous := _tier
	_tier = tier
	danger_tier_changed.emit(_tier)
	if force:
		return
	_play_transition_warning(previous, _tier)


func _play_transition_warning(from_tier: DangerTier, to_tier: DangerTier) -> void:
	var event := GameAudioEvent.Event.PLAYER_CRITICAL_WARNING
	var should_play := false
	if to_tier == DangerTier.NEAR_DEATH and from_tier != DangerTier.NEAR_DEATH:
		event = GameAudioEvent.Event.PLAYER_NEAR_DEATH_WARNING
		should_play = true
	elif to_tier == DangerTier.CRITICAL and from_tier != DangerTier.CRITICAL and from_tier != DangerTier.NEAR_DEATH:
		event = GameAudioEvent.Event.PLAYER_CRITICAL_WARNING
		should_play = true
	if not should_play:
		return

	var audio := get_node_or_null("/root/GameAudio")
	if audio != null and audio.has_method("play"):
		audio.play(event, Vector2.ZERO)


func _process(delta: float) -> void:
	if _vignette == null:
		return

	_pulse_phase += delta * vignette_pulse_speed
	var pulse := (sin(_pulse_phase) + 1.0) * 0.5
	match _tier:
		DangerTier.HEALTHY:
			_vignette.color.a = lerpf(_vignette.color.a, 0.0, minf(delta * 6.0, 1.0))
		DangerTier.WOUNDED:
			_vignette.color = Color(0.45, 0.05, 0.06, lerpf(0.06, 0.11, pulse))
		DangerTier.CRITICAL:
			_vignette.color = Color(0.55, 0.02, 0.04, lerpf(0.14, 0.26, pulse))
		DangerTier.NEAR_DEATH:
			_vignette.color = Color(0.62, 0.0, 0.02, lerpf(0.22, 0.38, pulse))

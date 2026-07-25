extends Control
## Permanent top-left HUD: player HP, dragon HP, and dragon status.
## Health-band colors use CriticalHealthFeedback thresholds when bound.


const COLOR_HEALTHY := Color(0.25, 0.65, 0.95, 1.0)
const COLOR_WOUNDED := Color(0.95, 0.72, 0.28, 1.0)
const COLOR_CRITICAL := Color(0.92, 0.28, 0.28, 1.0)
const COLOR_NEAR_DEATH := Color(0.85, 0.12, 0.18, 1.0)
const COLOR_DRAGON := Color(0.55, 0.78, 0.42, 1.0)
const COLOR_DRAGON_KO := Color(0.55, 0.45, 0.48, 1.0)

@onready var _bar_background: ColorRect = $Panel/Margin/VBox/BarBackground
@onready var _bar_fill: ColorRect = $Panel/Margin/VBox/BarBackground/BarFill
@onready var _value_label: Label = $Panel/Margin/VBox/ValueLabel
@onready var _dragon_bar_background: ColorRect = $Panel/Margin/VBox/DragonBarBackground
@onready var _dragon_bar_fill: ColorRect = $Panel/Margin/VBox/DragonBarBackground/DragonBarFill
@onready var _dragon_value_label: Label = $Panel/Margin/VBox/DragonValueLabel
@onready var _dragon_status_label: Label = $Panel/Margin/VBox/DragonStatusLabel

var _bar_width: float = 0.0
var _dragon_bar_width: float = 0.0
var _dragon: CharacterBody2D
var _survivability: DragonSurvivability
var _bar_tween: Tween
var _dragon_bar_tween: Tween
var _critical_feedback: CriticalHealthFeedback


func _ready() -> void:
	_bar_width = _bar_background.custom_minimum_size.x
	_dragon_bar_width = _dragon_bar_background.custom_minimum_size.x
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind(game_root: Node2D) -> void:
	if game_root == null:
		return

	var player := game_root.get_node_or_null("Entities/Player") as CharacterBody2D
	if player != null:
		bind_to_player(player)

	_dragon = game_root.get_node_or_null("Entities/Dragon") as CharacterBody2D
	if _dragon != null:
		if not _dragon.state_changed.is_connected(_on_dragon_state_changed):
			_dragon.state_changed.connect(_on_dragon_state_changed)
		_bind_dragon_survivability(_dragon.get_node_or_null("Survivability") as DragonSurvivability)
		_refresh_dragon_status(_dragon.state)

	_critical_feedback = game_root.get_node_or_null("CriticalHealthFeedback") as CriticalHealthFeedback
	if _critical_feedback != null and player != null:
		_critical_feedback.bind_to_player(player)
		var health := player.get_node_or_null("Health") as Health
		if health != null:
			_update_display(health.current_health, health.max_health, true)


func bind_to_player(player: CharacterBody2D) -> void:
	var health := player.get_node_or_null("Health") as Health
	if health == null:
		push_warning("PlayerHud: player is missing a Health node.")
		return

	_update_display(health.current_health, health.max_health, true)
	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)


func _bind_dragon_survivability(survivability: DragonSurvivability) -> void:
	if _survivability != null:
		if _survivability.health_changed.is_connected(_on_dragon_health_changed):
			_survivability.health_changed.disconnect(_on_dragon_health_changed)
		if _survivability.survivability_state_changed.is_connected(_on_dragon_survivability_state_changed):
			_survivability.survivability_state_changed.disconnect(_on_dragon_survivability_state_changed)

	_survivability = survivability
	if _survivability == null:
		_dragon_value_label.text = "Dragon: —"
		return

	if not _survivability.health_changed.is_connected(_on_dragon_health_changed):
		_survivability.health_changed.connect(_on_dragon_health_changed)
	if not _survivability.survivability_state_changed.is_connected(_on_dragon_survivability_state_changed):
		_survivability.survivability_state_changed.connect(_on_dragon_survivability_state_changed)
	_update_dragon_health(_survivability.current_health, _survivability.max_health, true)
	_on_dragon_survivability_state_changed(_survivability.state)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_display(current, maximum, false)


func _on_dragon_health_changed(current: float, maximum: float) -> void:
	_update_dragon_health(current, maximum, false)


func _on_dragon_survivability_state_changed(state: DragonSurvivability.SurvivabilityState) -> void:
	if state == DragonSurvivability.SurvivabilityState.KNOCKED_OUT:
		_dragon_status_label.text = "Dragon: Knocked Out"
		_dragon_bar_fill.color = COLOR_DRAGON_KO
		_dragon_value_label.text = "KO"
	elif _dragon != null:
		_refresh_dragon_status(_dragon.state)
		if _survivability != null:
			_update_dragon_health(_survivability.current_health, _survivability.max_health, true)


func _on_dragon_state_changed(state: DragonState.State) -> void:
	if _survivability != null and _survivability.is_knocked_out():
		_dragon_status_label.text = "Dragon: Knocked Out"
		return
	_refresh_dragon_status(state)


func _refresh_dragon_status(state: DragonState.State) -> void:
	var label := PlayerFeedbackLabels.dragon_status_label(state)
	_dragon_status_label.text = "Dragon: %s" % label


func _update_display(current: float, maximum: float, instant: bool) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	var bar_height := _bar_background.custom_minimum_size.y
	var target_size := Vector2(_bar_width * clampf(ratio, 0.0, 1.0), bar_height)
	_value_label.text = "%d / %d HP" % [int(round(current)), int(round(maximum))]
	_bar_fill.color = _color_for_ratio(ratio)

	if _bar_tween != null and _bar_tween.is_valid():
		_bar_tween.kill()
	if instant:
		_bar_fill.size = target_size
		return

	_bar_tween = create_tween()
	_bar_tween.tween_property(_bar_fill, "size", target_size, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _update_dragon_health(current: float, maximum: float, instant: bool) -> void:
	if _survivability != null and _survivability.is_knocked_out():
		_dragon_value_label.text = "KO"
		_dragon_bar_fill.color = COLOR_DRAGON_KO
		_dragon_bar_fill.size = Vector2(0.0, _dragon_bar_background.custom_minimum_size.y)
		return

	var ratio := current / maximum if maximum > 0.0 else 0.0
	var bar_height := _dragon_bar_background.custom_minimum_size.y
	var target_size := Vector2(_dragon_bar_width * clampf(ratio, 0.0, 1.0), bar_height)
	_dragon_value_label.text = "Dragon %d / %d" % [int(round(current)), int(round(maximum))]
	_dragon_bar_fill.color = COLOR_DRAGON

	if _dragon_bar_tween != null and _dragon_bar_tween.is_valid():
		_dragon_bar_tween.kill()
	if instant:
		_dragon_bar_fill.size = target_size
		return

	_dragon_bar_tween = create_tween()
	_dragon_bar_tween.tween_property(_dragon_bar_fill, "size", target_size, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _color_for_ratio(ratio: float) -> Color:
	var tier := CriticalHealthFeedback.DangerTier.HEALTHY
	if _critical_feedback != null:
		tier = _critical_feedback.tier_for_ratio(ratio)
	else:
		# Fallback matches CriticalHealthFeedback defaults if overlay is missing.
		if ratio <= 0.12:
			tier = CriticalHealthFeedback.DangerTier.NEAR_DEATH
		elif ratio <= 0.25:
			tier = CriticalHealthFeedback.DangerTier.CRITICAL
		elif ratio <= 0.50:
			tier = CriticalHealthFeedback.DangerTier.WOUNDED

	match tier:
		CriticalHealthFeedback.DangerTier.NEAR_DEATH:
			return COLOR_NEAR_DEATH
		CriticalHealthFeedback.DangerTier.CRITICAL:
			return COLOR_CRITICAL
		CriticalHealthFeedback.DangerTier.WOUNDED:
			return COLOR_WOUNDED
		_:
			return COLOR_HEALTHY

extends Control
## Permanent top-left HUD: player HP and dragon status.


const COLOR_HEALTHY := Color(0.25, 0.65, 0.95, 1.0)
const COLOR_WOUNDED := Color(0.95, 0.72, 0.28, 1.0)
const COLOR_CRITICAL := Color(0.92, 0.28, 0.28, 1.0)
const COLOR_NEAR_DEATH := Color(0.85, 0.12, 0.18, 1.0)

@onready var _bar_background: ColorRect = $Panel/Margin/VBox/BarBackground
@onready var _bar_fill: ColorRect = $Panel/Margin/VBox/BarBackground/BarFill
@onready var _value_label: Label = $Panel/Margin/VBox/ValueLabel
@onready var _dragon_status_label: Label = $Panel/Margin/VBox/DragonStatusLabel

var _bar_width: float = 0.0
var _dragon: CharacterBody2D
var _bar_tween: Tween
var _critical_feedback: CriticalHealthFeedback


func _ready() -> void:
	_bar_width = _bar_background.custom_minimum_size.x
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
		_refresh_dragon_status(_dragon.state)

	_critical_feedback = game_root.get_node_or_null("CriticalHealthFeedback") as CriticalHealthFeedback
	if _critical_feedback != null and player != null:
		_critical_feedback.bind_to_player(player)


func bind_to_player(player: CharacterBody2D) -> void:
	var health := player.get_node_or_null("Health") as Health
	if health == null:
		push_warning("PlayerHud: player is missing a Health node.")
		return

	_update_display(health.current_health, health.max_health, true)
	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_display(current, maximum, false)


func _on_dragon_state_changed(state: DragonState.State) -> void:
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


func _color_for_ratio(ratio: float) -> Color:
	if ratio <= 0.12:
		return COLOR_NEAR_DEATH
	if ratio <= 0.25:
		return COLOR_CRITICAL
	if ratio <= 0.50:
		return COLOR_WOUNDED
	return COLOR_HEALTHY

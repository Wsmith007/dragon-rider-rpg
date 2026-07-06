extends Control
## Permanent top-left HUD: player HP and dragon status.


@onready var _bar_background: ColorRect = $Panel/Margin/VBox/BarBackground
@onready var _bar_fill: ColorRect = $Panel/Margin/VBox/BarBackground/BarFill
@onready var _value_label: Label = $Panel/Margin/VBox/ValueLabel
@onready var _dragon_status_label: Label = $Panel/Margin/VBox/DragonStatusLabel

var _bar_width: float = 0.0
var _dragon: CharacterBody2D


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


func bind_to_player(player: CharacterBody2D) -> void:
	var health := player.get_node_or_null("Health") as Health
	if health == null:
		push_warning("PlayerHud: player is missing a Health node.")
		return

	_update_display(health.current_health, health.max_health)
	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_display(current, maximum)


func _on_dragon_state_changed(state: DragonState.State) -> void:
	_refresh_dragon_status(state)


func _refresh_dragon_status(state: DragonState.State) -> void:
	var label := PlayerFeedbackLabels.dragon_status_label(state)
	_dragon_status_label.text = "Dragon: %s" % label


func _update_display(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	var bar_height := _bar_background.custom_minimum_size.y
	_bar_fill.size = Vector2(_bar_width * ratio, bar_height)
	_value_label.text = "%d / %d HP" % [int(current), int(maximum)]

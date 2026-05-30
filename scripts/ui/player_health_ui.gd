extends Control
## Simple screen-space player HP readout for the top-left corner.

@onready var _bar_background: ColorRect = $Panel/Margin/VBox/BarBackground
@onready var _bar_fill: ColorRect = $Panel/Margin/VBox/BarBackground/BarFill
@onready var _value_label: Label = $Panel/Margin/VBox/ValueLabel

var _bar_width: float = 0.0


func _ready() -> void:
	_bar_width = _bar_background.custom_minimum_size.x


func bind_to_player(player: CharacterBody2D) -> void:
	var health := player.get_node_or_null("Health") as Health
	if health == null:
		push_warning("PlayerHealthUI: player is missing a Health node.")
		return

	_update_display(health.current_health, health.max_health)

	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_display(current, maximum)


func _update_display(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	var bar_height := _bar_background.custom_minimum_size.y
	_bar_fill.size = Vector2(_bar_width * ratio, bar_height)
	_value_label.text = "%d / %d HP" % [int(current), int(maximum)]

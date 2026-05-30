extends Node2D
## Boots the vertical-slice test map and wires references between player, dragon, and camera.


@onready var _player: CharacterBody2D = $Entities/Player
@onready var _dragon: CharacterBody2D = $Entities/Dragon
@onready var _camera: Camera2D = $Camera2D
@onready var _dragon_command: Node = $Entities/Player/DragonCommand
@onready var _player_health_ui: Control = $UI/PlayerHealthUI
@onready var _bond_debug_ui: Control = $UI/BondDebugUI
@onready var _health_debug_controls: Node = $UI/HealthDebugControls


func _ready() -> void:
	_dragon.set_follow_target(_player)
	if _camera.has_method("set_follow_target"):
		_camera.set_follow_target(_player)
	_dragon_command.command_toggle_requested.connect(_dragon.handle_command_toggle)
	if _player_health_ui.has_method("bind_to_player"):
		_player_health_ui.bind_to_player(_player)
	if _bond_debug_ui.has_method("bind_to_dragon"):
		_bond_debug_ui.bind_to_dragon(_dragon)
	if _health_debug_controls.has_method("bind_to_player"):
		_health_debug_controls.bind_to_player(_player)
	var enemy_indicators := get_node_or_null("UI/EnemyOffscreenIndicators") as Control
	if enemy_indicators != null and enemy_indicators.has_method("bind_to_player"):
		enemy_indicators.bind_to_player(_player)

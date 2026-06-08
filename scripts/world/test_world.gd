extends Control
## Playtest shell: gameplay SubViewport on the left, docked debug panel on the right.


const DEBUG_PANEL_WIDTH := 400

@onready var _game_viewport: SubViewport = $LayoutHBox/GameplayViewportContainer/GameplayViewport
@onready var _game_root: Node2D = _game_viewport.get_node("TestWorldGame")
@onready var _player: CharacterBody2D = _game_root.get_node("Entities/Player")
@onready var _dragon: CharacterBody2D = _game_root.get_node("Entities/Dragon")
@onready var _camera: Camera2D = _game_root.get_node("Camera2D")
@onready var _dragon_command: Node = _player.get_node("DragonCommand")
@onready var _player_health_ui: Control = _game_root.get_node("UI/PlayerHealthUI")
@onready var _bond_debug_ui: Control = $LayoutHBox/DebugPanel/BondDebugUI
@onready var _debug_panel: PanelContainer = $LayoutHBox/DebugPanel
@onready var _health_debug_controls: Node = _game_root.get_node("UI/HealthDebugControls")
@onready var _enemy_spawn_debug: Node = _game_root.get_node("UI/EnemySpawnDebug")
@onready var _enemies_container: Node2D = _game_root.get_node("Entities/Enemies")


func _ready() -> void:
	RelationshipSystem.setup_from_scene(_game_root)
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
	if _enemy_spawn_debug.has_method("bind"):
		_enemy_spawn_debug.bind(_player, _enemies_container)
	var enemy_indicators := _game_root.get_node_or_null("UI/EnemyOffscreenIndicators") as Control
	if enemy_indicators != null and enemy_indicators.has_method("bind_to_player"):
		enemy_indicators.bind_to_player(_player)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.keycode != KEY_F10:
		return

	if _debug_panel != null:
		_debug_panel.visible = not _debug_panel.visible
	get_viewport().set_input_as_handled()

extends Control
## Playtest shell for Vertical Slice Level P1. Same debug layout as TestWorld.


const DEBUG_PANEL_WIDTH := 400
const GAME_SCENE: PackedScene = preload("res://scenes/world/VerticalSliceLevelP1Game.tscn")

@onready var _game_viewport: SubViewport = $LayoutHBox/GameplayViewportContainer/GameplayViewport
@onready var _debug_panel: PanelContainer = $LayoutHBox/DebugPanel
@onready var _bond_debug_ui: Control = $LayoutHBox/DebugPanel/BondDebugUI

var _game_root: Node2D


func _ready() -> void:
	_wire_game_scene(_game_viewport.get_child(0) as Node2D)


func _wire_game_scene(game_root: Node2D) -> void:
	if game_root == null:
		return
	_game_root = game_root

	RelationshipSystem.setup_from_scene(_game_root)

	var player := game_root.get_node("Entities/Player") as CharacterBody2D
	var dragon := game_root.get_node("Entities/Dragon") as CharacterBody2D
	var camera := game_root.get_node("Camera2D") as Camera2D
	var dragon_command := player.get_node("DragonCommand")
	var player_health_ui := game_root.get_node("UI/PlayerHealthUI") as Control
	var health_debug := game_root.get_node("UI/HealthDebugControls")
	var enemy_spawn_debug := game_root.get_node("UI/EnemySpawnDebug")
	var enemies_container := game_root.get_node("Entities/Enemies") as Node2D
	var enemy_indicators := game_root.get_node_or_null("UI/EnemyOffscreenIndicators") as Control

	dragon.set_follow_target(player)
	if camera.has_method("set_follow_target"):
		camera.set_follow_target(player)
	dragon_command.command_toggle_requested.connect(dragon.handle_command_toggle)

	if player_health_ui.has_method("bind_to_player"):
		player_health_ui.bind_to_player(player)
	if _bond_debug_ui.has_method("bind_to_dragon"):
		_bond_debug_ui.bind_to_dragon(dragon)
	if health_debug.has_method("bind_to_player"):
		health_debug.bind_to_player(player)
	if enemy_spawn_debug.has_method("bind"):
		enemy_spawn_debug.bind(player, enemies_container)
	if enemy_indicators != null and enemy_indicators.has_method("bind_to_player"):
		enemy_indicators.bind_to_player(player)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_F10:
		if _debug_panel != null:
			_debug_panel.visible = not _debug_panel.visible
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_R and event.shift_pressed and event.ctrl_pressed:
		_restart_gameplay()
		get_viewport().set_input_as_handled()


func _restart_gameplay() -> void:
	for child in _game_viewport.get_children():
		child.queue_free()
	await get_tree().process_frame
	var game := GAME_SCENE.instantiate() as Node2D
	_game_viewport.add_child(game)
	_wire_game_scene(game)
	print("VERTICAL SLICE | full reload | Ctrl+Shift+R")

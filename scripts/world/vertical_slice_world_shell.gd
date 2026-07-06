extends "res://scripts/world/playtest_shell.gd"
## Playtest shell for Vertical Slice Level P1 — full reload via Ctrl+Shift+R.


const GAME_SCENE: PackedScene = preload("res://scenes/world/VerticalSliceLevelP1Game.tscn")

var _game_root: Node2D


func _ready() -> void:
	super._ready()
	_wire_game_scene(get_game_root())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and event.shift_pressed and event.ctrl_pressed:
			_restart_gameplay()
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)


func _wire_game_scene(game_root: Node2D) -> void:
	if game_root == null:
		return
	_game_root = game_root

	RelationshipSystem.setup_from_scene(game_root)

	var player := game_root.get_node("Entities/Player") as CharacterBody2D
	var dragon := game_root.get_node("Entities/Dragon") as CharacterBody2D
	var camera := game_root.get_node("Camera2D") as Camera2D
	var dragon_command := player.get_node("DragonCommand")
	var player_hud := game_root.get_node("UI/PlayerHud") as Control
	var bond_debug_ui := get_bond_debug_ui()
	var health_debug := game_root.get_node("UI/HealthDebugControls")
	var enemy_spawn_debug := game_root.get_node("UI/EnemySpawnDebug")
	var enemies_container := game_root.get_node("Entities/Enemies") as Node2D
	var enemy_indicators := game_root.get_node_or_null("UI/EnemyOffscreenIndicators") as Control
	var player_feedback_ui := game_root.get_node_or_null("UI/PlayerFeedbackUI") as Control

	dragon.set_follow_target(player)
	if camera.has_method("set_follow_target"):
		camera.set_follow_target(player)
	set_game_camera(camera)
	dragon_command.command_toggle_requested.connect(dragon.handle_command_toggle)

	if player_hud.has_method("bind"):
		player_hud.bind(game_root)
	if bond_debug_ui != null and bond_debug_ui.has_method("bind_to_dragon"):
		bond_debug_ui.bind_to_dragon(dragon)
	if health_debug.has_method("bind_to_player"):
		health_debug.bind_to_player(player)
	if enemy_spawn_debug.has_method("bind"):
		enemy_spawn_debug.bind(player, enemies_container)
	if enemy_indicators != null and enemy_indicators.has_method("bind_to_player"):
		enemy_indicators.bind_to_player(player)
	if player_feedback_ui != null and player_feedback_ui.has_method("bind"):
		player_feedback_ui.bind(game_root)
	var game_audio := get_node_or_null("/root/GameAudio") as GameAudioService
	if game_audio != null:
		game_audio.bind_game_root(game_root)


func _restart_gameplay() -> void:
	for child in get_game_viewport().get_children():
		child.queue_free()
	await get_tree().process_frame
	var game := GAME_SCENE.instantiate() as Node2D
	get_game_viewport().add_child(game)
	_wire_game_scene(game)
	print("VERTICAL SLICE | full reload | Ctrl+Shift+R")

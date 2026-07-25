extends Control
## Application shell: game region + developer sidebar as sibling HBox regions.
## F10 toggles sidebar width — game viewport always fills remaining space.


signal developer_mode_changed(enabled: bool)

const DEVELOPER_SIDEBAR_WIDTH := 420.0
const DEV_TRANSITION_DURATION := 0.22
const DeveloperInputScript := preload("res://scripts/core/developer_input_service.gd")
## Set false after confirming viewport sizes in the Output panel.
const DEBUG_VIEWPORT_LAYOUT := true

@onready var _shell_row: HBoxContainer = $ShellRow
@onready var _game_region: Control = $ShellRow/GameRegion
@onready var _viewport_container: SubViewportContainer = $ShellRow/GameRegion/GameplayViewportContainer
@onready var _game_viewport: SubViewport = $ShellRow/GameRegion/GameplayViewportContainer/GameplayViewport
@onready var _developer_sidebar: VBoxContainer = $ShellRow/DeveloperSidebar
@onready var _debug_panel: PanelContainer = $ShellRow/DeveloperSidebar/DebugPanel
@onready var _help_panel: PanelContainer = $ShellRow/DeveloperSidebar/HelpPanel

var _developer_mode_enabled := false
var _layout_tween: Tween
var _viewport_sync_queued := false
var _last_debug_signature := ""


func _developer_input() -> Node:
	return get_node_or_null("/root/DeveloperInput")


func _ready() -> void:
	# Gameplay runs in a SubViewport; positional AudioStreamPlayer2D nodes need a 2D listener here.
	_game_viewport.audio_listener_enable_2d = true
	_developer_sidebar.visible = false
	_developer_sidebar.custom_minimum_size = Vector2.ZERO
	_viewport_container.stretch = true
	var dev_input := _developer_input()
	if dev_input != null:
		dev_input.ensure_actions_registered()
		dev_input.bind_shell(self)
	else:
		push_error("PlaytestShell: DeveloperInput autoload is missing from project.godot.")
	get_viewport().size_changed.connect(_request_viewport_sync)
	_shell_row.resized.connect(_request_viewport_sync)
	_game_region.resized.connect(_request_viewport_sync)
	_viewport_container.resized.connect(_request_viewport_sync)
	call_deferred("_finish_ready")


func _finish_ready() -> void:
	_apply_developer_workspace(false)
	await get_tree().process_frame
	await get_tree().process_frame
	_sync_viewport_size()


func get_game_viewport() -> SubViewport:
	return _game_viewport


func get_game_root() -> Node2D:
	if _game_viewport.get_child_count() == 0:
		return null
	return _game_viewport.get_child(0) as Node2D


func get_bond_debug_ui() -> Control:
	return $ShellRow/DeveloperSidebar/DebugPanel/BondDebugUI as Control


func set_game_camera(_camera: Camera2D) -> void:
	call_deferred("_request_viewport_sync")


func is_developer_mode_enabled() -> bool:
	return _developer_mode_enabled


func toggle_developer_mode() -> void:
	set_developer_mode(not _developer_mode_enabled)


func set_developer_mode(enabled: bool) -> void:
	if _developer_mode_enabled == enabled:
		return
	_developer_mode_enabled = enabled
	_animate_developer_workspace(_developer_mode_enabled)
	developer_mode_changed.emit(_developer_mode_enabled)


func configure_developer_input(bindings: DeveloperInputScript.GameplayBindings) -> void:
	var dev_input := _developer_input()
	if dev_input != null:
		dev_input.bind_gameplay(bindings)


func build_developer_input_bindings(
	game_root: Node2D,
	slice_level: Node = null
) -> DeveloperInputScript.GameplayBindings:
	var player := game_root.get_node("Entities/Player") as CharacterBody2D
	var bindings := DeveloperInputScript.GameplayBindings.new()
	bindings.melee_attack = player.get_node("MeleeAttack")
	bindings.telegraph = player.get_node("MeleeAttack/Telegraph")
	bindings.dragon = game_root.get_node("Entities/Dragon")
	bindings.health_debug = game_root.get_node("UI/HealthDebugControls")
	bindings.spawn_debug = game_root.get_node("UI/EnemySpawnDebug")
	bindings.slice_level = slice_level
	return bindings


func set_developer_reload_enabled(enabled: bool) -> void:
	var dev_input := _developer_input()
	if dev_input != null:
		dev_input.set_reload_gameplay_enabled(enabled)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(PlaytestNavigation.RETURN_MENU_ACTION):
		call_deferred("_return_to_launch_menu")


func _return_to_launch_menu() -> void:
	var dev_input := _developer_input()
	if dev_input != null:
		dev_input.clear_gameplay_bindings()
	PlaytestNavigation.return_to_launch_menu(get_tree(), "PlaytestShell")


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_request_viewport_sync()


func _request_viewport_sync() -> void:
	if _viewport_sync_queued:
		return
	_viewport_sync_queued = true
	call_deferred("_sync_viewport_size")


func _animate_developer_workspace(show_sidebar: bool) -> void:
	if _layout_tween != null and _layout_tween.is_valid():
		_layout_tween.kill()

	var sidebar_width := DEVELOPER_SIDEBAR_WIDTH if show_sidebar else 0.0
	_developer_sidebar.visible = true

	_layout_tween = create_tween()
	_layout_tween.set_trans(Tween.TRANS_CUBIC)
	_layout_tween.set_ease(Tween.EASE_OUT)
	_layout_tween.tween_method(
		func(width: float) -> void:
			_developer_sidebar.custom_minimum_size = Vector2(width, 0.0),
		_developer_sidebar.custom_minimum_size.x,
		sidebar_width,
		DEV_TRANSITION_DURATION,
	)
	_layout_tween.parallel().tween_method(
		func(_step: float) -> void: _sync_viewport_size(),
		0.0,
		1.0,
		DEV_TRANSITION_DURATION,
	)
	_layout_tween.chain().tween_callback(func() -> void:
		_apply_developer_workspace(show_sidebar)
	)


func _apply_developer_workspace(enabled: bool) -> void:
	_developer_sidebar.custom_minimum_size = (
		Vector2(DEVELOPER_SIDEBAR_WIDTH, 0.0) if enabled else Vector2.ZERO
	)
	_developer_sidebar.visible = enabled
	_debug_panel.visible = enabled
	_help_panel.visible = enabled
	if not enabled:
		var viewport := get_viewport()
		if viewport != null:
			viewport.gui_release_focus()
	_request_viewport_sync()


func _sync_viewport_size() -> void:
	_viewport_sync_queued = false

	var container_size := _viewport_container.size.floor()
	if container_size.x < 2.0 or container_size.y < 2.0:
		container_size = _game_region.size.floor()
	if container_size.x < 2.0 or container_size.y < 2.0:
		call_deferred("_retry_viewport_sync_after_layout")
		return

	var render_size := Vector2i(maxi(1, int(container_size.x)), maxi(1, int(container_size.y)))
	if _game_viewport.size != render_size:
		_game_viewport.size = render_size

	_viewport_container.stretch = true
	_log_viewport_layout(render_size)


func _retry_viewport_sync_after_layout() -> void:
	await get_tree().process_frame
	_sync_viewport_size()


func _log_viewport_layout(render_size: Vector2i) -> void:
	if not DEBUG_VIEWPORT_LAYOUT:
		return
	var signature := (
		"%s|%s|%s|%s" % [
			_shell_row.size,
			_game_region.size,
			_viewport_container.size,
			render_size,
		]
	)
	if signature == _last_debug_signature:
		return
	_last_debug_signature = signature
	print(
		"VIEWPORT_LAYOUT | ShellRow=%s GameRegion=%s Container=%s SubViewport=%s"
		% [_shell_row.size, _game_region.size, _viewport_container.size, render_size]
	)

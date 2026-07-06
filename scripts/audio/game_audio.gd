extends Node
class_name GameAudioService
## Central audio manager. Gameplay calls play(event) — never file paths.

const UI_PLAYER_POOL_SIZE := 4
const WORLD_PLAYER_POOL_SIZE := 8

var _stream_cache: Dictionary = {}
var _ui_players: Array[AudioStreamPlayer] = []
var _world_players: Array[AudioStreamPlayer2D] = []
var _world_audio_root: Node2D
var _event_cooldown_until: Dictionary = {}
var _binder: GameAudioBinder


func _ready() -> void:
	_ensure_audio_buses()
	_preload_placeholder_streams()
	_create_player_pools()
	_binder = GameAudioBinder.new()
	_binder.setup(self)


func play(event: GameAudioEvent.Event, world_position: Vector2 = Vector2.ZERO) -> void:
	var playback := GameAudioCatalog.get_playback(event)
	if playback.is_empty():
		return

	if _is_on_cooldown(event):
		return

	var stream: AudioStream = _stream_cache.get(playback["stream_path"])
	if stream == null:
		return

	var pitch_min: float = playback.get("pitch_min", 1.0)
	var pitch_max: float = playback.get("pitch_max", 1.0)
	var pitch_scale := randf_range(pitch_min, pitch_max)

	if playback.get("positional", true):
		_play_world(stream, world_position, playback, pitch_scale)
	else:
		_play_ui(stream, playback, pitch_scale)

	_apply_cooldown(event)


func bind_game_root(game_root: Node2D) -> void:
	if _binder == null:
		_binder = GameAudioBinder.new()
		_binder.setup(self)
	_binder.bind_game_root(game_root)


func unbind_game_root() -> void:
	if _binder != null:
		_binder.unbind_game_root()


func defer_hit_evaluation(enemy: Node2D) -> void:
	call_deferred("_run_hit_evaluation", enemy)


func _run_hit_evaluation(enemy: Node2D) -> void:
	if _binder != null:
		_binder.evaluate_enemy_hit_result(enemy)


func _ensure_audio_buses() -> void:
	var planned: Array[StringName] = [
		GameAudioCatalog.BUS_COMBAT,
		GameAudioCatalog.BUS_UI,
		GameAudioCatalog.BUS_DRAGON,
		GameAudioCatalog.BUS_AMBIENT,
		GameAudioCatalog.BUS_MUSIC,
		GameAudioCatalog.BUS_VOICE,
	]
	for bus_name in planned:
		if _find_bus_index(bus_name) >= 0:
			continue
		var index := AudioServer.bus_count
		AudioServer.add_bus(index)
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, &"Master")


func _find_bus_index(bus_name: StringName) -> int:
	for index in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(index) == bus_name:
			return index
	return -1


func _preload_placeholder_streams() -> void:
	for path in GameAudioCatalog.unique_stream_paths():
		if _stream_cache.has(path):
			continue
		var stream := load(path) as AudioStream
		if stream != null:
			_stream_cache[path] = stream


func _create_player_pools() -> void:
	for index in range(UI_PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "UiPlayer_%d" % index
		add_child(player)
		_ui_players.append(player)

	for index in range(WORLD_PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer2D.new()
		player.name = "WorldPlayer_%d" % index
		player.max_distance = 2400.0
		player.attenuation = 1.0
		add_child(player)
		_world_players.append(player)


func _play_ui(stream: AudioStream, playback: Dictionary, pitch_scale: float) -> void:
	var player := _acquire_ui_player()
	if player == null:
		return
	player.stream = stream
	player.bus = playback.get("bus", &"Master")
	player.volume_db = playback.get("volume_db", 0.0)
	player.pitch_scale = pitch_scale
	player.play()


func _play_world(
	stream: AudioStream,
	world_position: Vector2,
	playback: Dictionary,
	pitch_scale: float
) -> void:
	var player := _acquire_world_player()
	if player == null:
		return

	_ensure_world_player_parent(player)
	player.global_position = world_position

	player.stream = stream
	player.bus = playback.get("bus", &"Master")
	player.volume_db = playback.get("volume_db", 0.0)
	player.pitch_scale = pitch_scale
	player.play()


func _acquire_ui_player() -> AudioStreamPlayer:
	for player in _ui_players:
		if not player.playing:
			return player
	return _ui_players[0]


func _acquire_world_player() -> AudioStreamPlayer2D:
	for player in _world_players:
		if not is_instance_valid(player):
			continue
		if not player.playing:
			return player
	if _world_players.is_empty():
		return null
	return _world_players[0]


func set_world_audio_root(root: Node2D) -> void:
	_world_audio_root = root
	for player in _world_players:
		if not is_instance_valid(player):
			continue
		if root != null and is_instance_valid(root):
			_reparent_world_player(player, root)
		else:
			_reparent_world_player(player, self)


func _ensure_world_player_parent(player: AudioStreamPlayer2D) -> void:
	if _world_audio_root != null and is_instance_valid(_world_audio_root):
		_reparent_world_player(player, _world_audio_root)
	elif player.get_parent() != self:
		_reparent_world_player(player, self)


func _reparent_world_player(player: AudioStreamPlayer2D, new_parent: Node) -> void:
	if player.get_parent() == new_parent:
		return
	if player.get_parent() != null:
		player.get_parent().remove_child(player)
	new_parent.add_child(player)


func _is_on_cooldown(event: GameAudioEvent.Event) -> bool:
	var until: float = _event_cooldown_until.get(event, 0.0)
	return Time.get_ticks_msec() / 1000.0 < until


func _apply_cooldown(event: GameAudioEvent.Event) -> void:
	var duration := _cooldown_for_event(event)
	if duration <= 0.0:
		return
	_event_cooldown_until[event] = Time.get_ticks_msec() / 1000.0 + duration


func _cooldown_for_event(event: GameAudioEvent.Event) -> float:
	match event:
		GameAudioEvent.Event.PLAYER_SWING, GameAudioEvent.Event.PLAYER_CC:
			return 0.08
		GameAudioEvent.Event.PLAYER_HIT, GameAudioEvent.Event.ENEMY_HIT:
			return 0.05
		GameAudioEvent.Event.PLAYER_DAMAGED:
			return 0.12
		GameAudioEvent.Event.BRUTE_HEAVY:
			return 0.2
		GameAudioEvent.Event.BRUTE_RESIST:
			return 0.15
		GameAudioEvent.Event.TARGET_FOCUS_SWITCH:
			return 0.08
		GameAudioEvent.Event.DRAGON_ASSIST, GameAudioEvent.Event.DRAGON_PROTECT:
			return 0.35
		GameAudioEvent.Event.DRAGON_WAIT:
			return 0.25
		GameAudioEvent.Event.ENCOUNTER_COMPLETE:
			return 0.5
		GameAudioEvent.Event.RELATIONSHIP_IMPROVED, GameAudioEvent.Event.RELATIONSHIP_STRAINED:
			return 0.4
		_:
			return 0.0

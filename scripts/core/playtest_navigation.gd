extends RefCounted
class_name PlaytestNavigation
## Shared scene changes for LaunchMenu and playtest shells.


const LAUNCH_MENU_SCENE := "res://scenes/LaunchMenu.tscn"
const TEST_WORLD_SCENE := "res://scenes/world/TestWorld.tscn"
const VERTICAL_SLICE_SCENE := "res://scenes/world/VerticalSlice_Level_P1.tscn"
const CINDERWATCH_RIDGE_SCENE := "res://scenes/world/Cinderwatch_Ridge.tscn"

const RETURN_MENU_ACTION := &"playtest_return_menu"


static func change_scene(tree: SceneTree, scene_path: String, log_prefix: String = "PlaytestNavigation") -> bool:
	if tree == null:
		push_error("%s: SceneTree unavailable; cannot load %s" % [log_prefix, scene_path])
		return false

	if scene_path.is_empty():
		push_error("%s: scene path is empty." % log_prefix)
		return false

	if not ResourceLoader.exists(scene_path, "PackedScene"):
		push_error("%s: scene path does not exist: %s" % [log_prefix, scene_path])
		return false

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("%s: failed to load scene as PackedScene: %s" % [log_prefix, scene_path])
		return false

	var change_err := tree.change_scene_to_packed(packed_scene)
	if change_err != OK:
		push_error("%s: change_scene_to_packed failed for %s (error %d)" % [log_prefix, scene_path, change_err])
		return false

	return true


static func return_to_launch_menu(tree: SceneTree, log_prefix: String = "PlaytestNavigation") -> bool:
	var game_audio := tree.get_root().get_node_or_null("GameAudio") as GameAudioService
	if game_audio != null:
		game_audio.unbind_game_root()
	return change_scene(tree, LAUNCH_MENU_SCENE, log_prefix)

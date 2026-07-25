class_name GameBuildConfig
extends RefCounted
## Player vs developer build flags. See checkpoints/project_checkpoint_dragon_personality_pass1.md.


const SETTING_DEVELOPER_TOOLS := "gameplay/developer_tools_enabled"


static func are_developer_tools_enabled() -> bool:
	var value = ProjectSettings.get_setting(SETTING_DEVELOPER_TOOLS, null)
	if value != null:
		return bool(value)
	return OS.has_feature("editor")

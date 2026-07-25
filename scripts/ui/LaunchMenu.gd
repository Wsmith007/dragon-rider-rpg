extends Control
## Playtest entry menu for exported builds and editor runs.


func _ready() -> void:
	%TestWorldButton.pressed.connect(_on_test_world_pressed)
	%VerticalSliceButton.pressed.connect(_on_vertical_slice_pressed)


func _on_test_world_pressed() -> void:
	PlaytestNavigation.change_scene(get_tree(), PlaytestNavigation.TEST_WORLD_SCENE, "LaunchMenu")


func _on_vertical_slice_pressed() -> void:
	PlaytestNavigation.change_scene(get_tree(), PlaytestNavigation.VERTICAL_SLICE_SCENE, "LaunchMenu")

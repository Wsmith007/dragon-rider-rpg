extends Node
## Emits dragon wait/recall commands. Wired to the dragon by the world scene.


signal command_toggle_requested


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dragon_command"):
		command_toggle_requested.emit()

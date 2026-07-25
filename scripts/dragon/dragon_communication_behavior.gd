extends Node
class_name DragonCommunicationBehavior
## Ambient combat/exploration text is intentionally disabled.
## Dragon personality in Pass 1 is communicated through behavior (stance, facing,
## proximity, assist/protect/wait/recall/hesitation) - not automatic thought bubbles.
##
## Future: player-initiated dialogue may publish through message_changed when the
## rider deliberately interacts with the dragon (NPC-style conversation).


signal message_changed(message: String)


func _ready() -> void:
	# No ambient signal hooks. Threat, strike, command, and cooperation behaviors
	# continue to drive AI and StatusVisual without text output here.
	pass


func get_message() -> String:
	return ""

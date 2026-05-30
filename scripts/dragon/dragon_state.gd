class_name DragonState

## Top-level dragon activity states. Future bond systems may gate transitions.

enum State {
	FOLLOWING,
	WAITING,
	ALERT,
	PROTECTING,
	ASSISTING,
}


static func state_name(state: State) -> String:
	match state:
		State.FOLLOWING:
			return "following"
		State.WAITING:
			return "waiting"
		State.ALERT:
			return "alert"
		State.PROTECTING:
			return "protecting"
		State.ASSISTING:
			return "assisting"
		_:
			return "unknown"


static func state_display_name(state: State) -> String:
	match state:
		State.FOLLOWING:
			return "FOLLOWING"
		State.WAITING:
			return "WAITING"
		State.ALERT:
			return "ALERT"
		State.PROTECTING:
			return "PROTECTING"
		State.ASSISTING:
			return "ASSISTING"
		_:
			return "UNKNOWN"

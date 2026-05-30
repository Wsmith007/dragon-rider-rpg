class_name DragonState

## Top-level dragon activity states. Future bond systems may gate transitions.

enum State {
	FOLLOWING,
	WAITING,
	ALERT,
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
		State.ASSISTING:
			return "assisting"
		_:
			return "unknown"

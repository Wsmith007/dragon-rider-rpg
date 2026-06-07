extends RefCounted
class_name RelationshipEventBus
## Central relationship event bus: emit, subscribe, debug logging only.


signal event_emitted(event: RelationshipEvent)

var debug_logging_enabled: bool = true
var _subscribers: Array[Callable] = []


func emit_event(event: RelationshipEvent) -> void:
	if debug_logging_enabled:
		var payload_text := ""
		if not event.payload.is_empty():
			payload_text = " | payload=%s" % str(event.payload)
		print("[RelationshipEvent] %s @ %.2f%s" % [event.event_id, event.timestamp, payload_text])

	event_emitted.emit(event)

	for callback: Callable in _subscribers:
		if callback.is_valid():
			callback.call(event)


func subscribe(callback: Callable) -> void:
	if not _subscribers.has(callback):
		_subscribers.append(callback)


func unsubscribe(callback: Callable) -> void:
	_subscribers.erase(callback)

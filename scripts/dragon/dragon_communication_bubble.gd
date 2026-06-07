extends Node2D
class_name DragonCommunicationBubble
## Temporary in-world display for dragon communication lines.
##
## Listens to DragonCommunicationBehavior.message_changed only — no message selection here.
## Future: swap panel style, add emotion icons, race themes, or a hide-bubbles option.


@export var anchor_offset: Vector2 = Vector2(0.0, -44.0)
@export var display_duration: float = 1.75
@export var fade_duration: float = 0.25
@export var max_text_width: float = 140.0

@onready var _bubble_root: Control = $BubbleRoot
@onready var _panel: PanelContainer = $BubbleRoot/Panel
@onready var _label: Label = $BubbleRoot/Panel/MarginContainer/Label

var _time_remaining: float = 0.0
var _is_fading: bool = false
var _fade_tween: Tween


func _ready() -> void:
	position = anchor_offset
	_bubble_root.visible = false
	_bubble_root.modulate.a = 1.0
	_bubble_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.custom_minimum_size.x = max_text_width
	call_deferred("_bind_communication")


func _process(delta: float) -> void:
	if not _bubble_root.visible or _is_fading:
		return

	_time_remaining -= delta
	if _time_remaining <= 0.0:
		_begin_fade_out()


func bind_to_communication(behavior: DragonCommunicationBehavior) -> void:
	if behavior == null:
		return
	if not behavior.message_changed.is_connected(_on_message_changed):
		behavior.message_changed.connect(_on_message_changed)


func _bind_communication() -> void:
	var behavior := get_parent().get_node_or_null("CommunicationBehavior") as DragonCommunicationBehavior
	if behavior == null:
		push_warning("DragonCommunicationBubble: CommunicationBehavior not found.")
		return
	bind_to_communication(behavior)


func _on_message_changed(message: String) -> void:
	if message.is_empty():
		return

	_cancel_fade()
	_label.text = message
	_bubble_root.visible = true
	_bubble_root.modulate.a = 1.0
	_is_fading = false
	_time_remaining = display_duration
	call_deferred("_center_bubble")


func _center_bubble() -> void:
	_panel.reset_size()
	_bubble_root.position.x = -_panel.size.x * 0.5


func _begin_fade_out() -> void:
	if not _bubble_root.visible:
		return

	_is_fading = true
	_fade_tween = create_tween()
	_fade_tween.tween_property(_bubble_root, "modulate:a", 0.0, fade_duration)
	_fade_tween.tween_callback(_hide_bubble)


func _hide_bubble() -> void:
	_bubble_root.visible = false
	_bubble_root.modulate.a = 1.0
	_is_fading = false
	_time_remaining = 0.0
	_fade_tween = null


func _cancel_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
	_is_fading = false

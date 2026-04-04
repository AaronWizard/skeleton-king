class_name MapEvents

signal custom_event_sent(event_type_id: StringName, source_rect: Rect2i,
		data: Dictionary[StringName, Variant])


func send_custom_event(event_type_id: StringName, source_rect: Rect2i,
		data: Dictionary[StringName, Variant]) -> void:
	custom_event_sent.emit(event_type_id, source_rect, data)

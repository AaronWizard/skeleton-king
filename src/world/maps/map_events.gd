class_name MapEvents

signal custom_event_sent(event: CustomEvent)


func send_custom_event(id: StringName, source_rect: Rect2i,
		data: Dictionary[StringName, Variant]) -> void:
	custom_event_sent.emit(CustomEvent.new(id, source_rect, data))


class CustomEvent:
	var id: StringName
	var source_rect: Rect2i
	var data: Dictionary[StringName, Variant]

	func _init(p_id: StringName, p_source_rect: Rect2i,
			p_data: Dictionary[StringName, Variant]) -> void:
		id = p_id
		source_rect = p_source_rect
		data = p_data

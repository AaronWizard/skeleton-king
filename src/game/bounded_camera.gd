class_name BoundedCamera
extends Camera2D


var bounds := Rect2i(0, 0, 180, 180):
	set(value):
		if bounds != value:
			bounds = value
			_update_bounds()


func _ready() -> void:
	_update_bounds()
	get_viewport().size_changed.connect(_update_bounds)


func _update_bounds() -> void:
	limit_left = bounds.position.x
	limit_top = bounds.position.y

	limit_right = bounds.end.x
	limit_bottom = bounds.end.y

	var viewport := get_viewport()
	if viewport:
		var view_size := viewport.get_visible_rect().size

		if view_size.x > bounds.size.x:
			var margin := int((view_size.x - bounds.size.x) / 2)
			limit_left -= margin
			limit_right += margin

		if view_size.y > bounds.size.y:
			var margin := int((view_size.y - bounds.size.y) / 2)
			limit_top -= margin
			limit_bottom += margin

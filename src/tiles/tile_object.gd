@tool
class_name TileObject
extends Node2D

#region Exports

@export_group("Position and size")

## The pixel position is the tile object's [b]bottom left[/b] corner.
@export var origin_cell: Vector2i:
	get:
		return Vector2i(position / Vector2(tile_size)) - Vector2i.DOWN
	set(value):
		position = (value + Vector2i.DOWN) * tile_size
		_origin_cell_changed()


@export var tile_size := Vector2i(12, 12):
	set(value):
		var old_cell := origin_cell
		tile_size = value
		origin_cell = old_cell
		_tile_size_changed()
		queue_redraw()

@export_group("Editing")

@export var editor_colour := Color.CORNFLOWER_BLUE * Color(1, 1, 1, 0.25):
	set(value):
		editor_colour = value
		queue_redraw()

#endregion Exports

## The pixel position of the tile object's centre.
var pixel_centre: Vector2:
	get:
		return (Vector2(tile_size) * Vector2(1, -1)) / 2.0


func _draw() -> void:
	if Engine.is_editor_hint():
		var rect := Rect2i(Vector2i.UP * tile_size, tile_size)
		draw_rect(rect, editor_colour, true)


func covers_cell(cell: Vector2i) -> bool:
	return origin_cell == cell


## Called when the origin cell changed.[br]
## Can be overridden.
func _origin_cell_changed() -> void:
	pass


## Called when the tile size changed.[br]
## Can be overridden.
func _tile_size_changed() -> void:
	pass

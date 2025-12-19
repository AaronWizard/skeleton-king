@tool
class_name RectTileObject
extends TileObject


@export var cell_dimensions := Vector2i.ONE:
	get:
		return _get_cell_size()
	set(value):
		_set_cell_size(value)

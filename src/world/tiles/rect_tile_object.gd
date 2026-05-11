@tool
class_name RectTileObject
extends TileObject

## A rectangular [TileObject].

## The width and height of the tile object in tiles.
@export var cell_dimensions := Vector2i.ONE:
	get:
		return _get_cell_size()
	set(value):
		_set_cell_size(value)

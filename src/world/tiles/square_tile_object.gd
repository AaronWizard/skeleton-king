@tool
class_name SquareTileObject
extends TileObject

## A square [TileObject].

## The width and height of the tile object in tiles.
@export_range(1, 1, 1, "or_greater") var cell_length := 1:
	get:
		return _get_cell_size().x
	set(value):
		_set_cell_size(Vector2i(value, value))

@icon("uid://cbnjt51pc0ii7")
@tool
@abstract
class_name TileObject
extends Node2D

#region Exports

@export_group("Position and size")

## The object's [b]top left[/b] cell.[br]
## [br]
## The pixel position is the object's [b]bottom left[/b] point.
@export var origin_cell: Vector2i:
	get:
		return (Vector2i(position) / tile_size) - Vector2i(0, _cell_size.y)
	set(value):
		var old_cell := origin_cell

		_set_position(value)

		if old_cell != origin_cell:
			_origin_cell_changed(old_cell)
			queue_redraw()


@export var tile_size := Vector2i(12, 12):
	set(value):
		var old_size := tile_size
		var current_origin := origin_cell

		tile_size = value.maxi(1)

		_set_position(current_origin)
		if old_size != tile_size:
			_tile_size_changed()
			queue_redraw()


@export_group("Editor")

@export var grid_colour := Color.CORNFLOWER_BLUE:
	set(value):
		if grid_colour != value:
			grid_colour = value
			queue_redraw()


@export var origin_colour := Color.VIOLET:
	set(value):
		if grid_colour != value:
			grid_colour = value
			queue_redraw()


@export var show_grid_in_game := false:
	set(value):
		if show_grid_in_game != value:
			show_grid_in_game = value
			queue_redraw()

#endregion Exports

#region Properties

## The size of the tile object in cells.
var cell_size: Vector2i:
	get:
		return _cell_size


## The rectangle the tile object covers on the grid.
var cell_rect: Rect2i:
	get:
		return Rect2i(origin_cell, _cell_size)


## The center of the tile object in pixels.
var pixel_centre: Vector2:
	get:
		return Vector2(
			(_cell_size.x * tile_size.x) / 2.0,
			(-_cell_size.y * tile_size.y) / 2.0
		)

#endregion

var _cell_size := Vector2i.ONE


func _draw() -> void:
	if not Engine.is_editor_hint() and not show_grid_in_game:
		return

	for x in range(_cell_size.x + 1):
		var line_x := x * tile_size.x
		var line_y_end := -_cell_size.y * tile_size.y
		draw_line(
			Vector2(line_x, 0), Vector2(line_x, line_y_end), grid_colour
		)
	for y in range(_cell_size.y + 1):
		var line_x_end := _cell_size.x * tile_size.x
		var line_y := (y - _cell_size.y) * tile_size.y
		draw_line(
			Vector2(0, line_y), Vector2(line_x_end, line_y), grid_colour
		)

	var origin_rect := Rect2(
		Vector2(0, -_cell_size.y * tile_size.y), tile_size
	)
	draw_rect(origin_rect, origin_colour, false)


func covers_cell(cell: Vector2i) -> bool:
	return cell_rect.has_point(cell)


func get_covered_cells_at_cell(cell: Vector2i) -> Array[Vector2i]:
	return TileGeometry.cells_in_rect(Rect2i(cell, cell_size))


func _set_position(new_origin_cell: Vector2i) -> void:
	position = (new_origin_cell + Vector2i(0, _cell_size.y)) * tile_size


## Gets the width and height in cells.[br]
## [br]
## For internal use.
func _get_cell_size() -> Vector2i:
	return _cell_size


## Sets the width and height in cells.[br]
## [br]
## For internal use.
func _set_cell_size(size: Vector2i) -> void:
	var old_size := _cell_size
	var current_origin := origin_cell

	_cell_size = size.maxi(1)
	if old_size != _cell_size:
		# Pixel position depends on cell size
		_set_position(current_origin)
		_cell_size_changed()
		queue_redraw()


## Called when the origin cell changed.[br]
## [br]
## Can be overridden.
func _origin_cell_changed(_old_cell: Vector2i) -> void:
	pass


## Called when the tile size changed.[br]
## [br]
## Can be overridden.
func _tile_size_changed() -> void:
	pass


## Called after the width and height is changed.[br]
## [br]
## Can be overridden.
func _cell_size_changed() -> void:
	pass

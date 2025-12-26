class_name Pathfinder

## A class for finding paths on a map.
##
## A class for finding paths on a grid map. Handles actors with different sizes.

const _DEBUG_DRAW_COLOUR := Color.DEEP_PINK * Color(1, 1, 1, 0.25)

var _map_region: Rect2i

# Represents the base terrain. Used by 1x1 actors.
var _base_grid: AStarGrid2D
# Grids used by actors bigger than 1x1.
var _grids: Dictionary[Vector2i, AStarGrid2D] = {}


## Initializes the Pathfinder with the bounds of the map
func _init(map_region: Rect2i) -> void:
	_map_region = map_region
	_base_grid = _create_grid(_map_region)


## Initializes pathfinding for actors with the given size.
func init_grid_for_actor_size(actor_size: Vector2i) -> void:
	if (actor_size != Vector2i.ONE) and not _grids.has(actor_size):
		var new_grid := _create_grid(_map_region)
		_grids[actor_size] = new_grid
		_update_other_grids()


## Enables or disables a single cell for pathfinding.
func set_cell_solid(cell: Vector2i, solid: bool) -> void:
	_base_grid.set_point_solid(cell, solid)
	_update_other_grids()


## Enables or disables a rectangle of cells for pathfinding.
func set_rect_solid(rect: Rect2i, solid: bool) -> void:
	_base_grid.fill_solid_region(rect, solid)
	_update_other_grids()


## Finds a path that would move an actor with a size of [param actor_size] from
## [param start] to [param end]. If no valid path exists the result is empty.
func find_path(start: Vector2i, end: Vector2i, actor_size: Vector2i) \
		-> Array[Vector2i]:
	var grid := _base_grid
	if actor_size != Vector2i.ONE:
		grid = _grids[actor_size]
	return grid.get_id_path(start, end)


func _update_other_grids() -> void:
	var region := _base_grid.region

	for actor_size in _grids:
		var grid := _grids[actor_size]

		grid.clear()
		grid.region = region
		grid.update()

		for cell in TileGeometry.cells_in_rect(region):
			if _base_grid.is_point_solid(cell):
				var block_rect := Rect2i(
					cell - actor_size + Vector2i.ONE,
					actor_size
				)
				grid.fill_solid_region(block_rect, true)
		var bottom_border := Rect2i(
			Vector2i(region.position.x, region.end.y - actor_size.y + 1),
			Vector2i(region.size.x, actor_size.y - 1)
		)
		var right_border := Rect2i(
			Vector2i(region.end.x - actor_size.x + 1, region.position.y),
			Vector2i(actor_size.x - 1, region.size.y)
		)
		grid.fill_solid_region(bottom_border, true)
		grid.fill_solid_region(right_border, true)


func debug_draw(canvas_item: CanvasItem, actor_size: Vector2i,
		tile_size: Vector2) -> void:
	if (actor_size != Vector2i.ONE) and _grids.has(actor_size):
		var other_grid := _grids[actor_size]
		_debug_draw_grid(canvas_item, other_grid, tile_size)
	_debug_draw_grid(canvas_item, _base_grid, tile_size)


static func _create_grid(region: Rect2i) -> AStarGrid2D:
	var result := AStarGrid2D.new()
	result.region = region
	result.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	result.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	result.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.update()
	return result


static func _debug_draw_grid(canvas_item: CanvasItem, grid: AStarGrid2D,
		tile_size: Vector2) -> void:
	for cell in TileGeometry.cells_in_rect(grid.region):
		if grid.is_point_solid(cell):
			var tile_rect := Rect2(
				Vector2(cell) * tile_size,
				tile_size
			)
			canvas_item.draw_rect(tile_rect, _DEBUG_DRAW_COLOUR)

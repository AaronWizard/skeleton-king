class_name ActorPathfinder

## Custom A-star implementation for actors.

const _PATHFIND_COST_OTHER_ACTOR := 10.0

## Finds a path for [param actor] from its current origin cell to
## [param end_cell].[br]
## Returns an empty list if no path could be found.
static func find_path_to_cell(actor: Actor, end_cell: Vector2i) \
		-> Array[Vector2i]:
	var heuristic_func := \
		func (cell: Vector2i) -> float:
			return TileGeometry.manhattan_distance(cell, end_cell)

	var reached_goal_func := \
		func (cell: Vector2i) -> bool:
			return cell == end_cell

	return _find_path(actor, heuristic_func, reached_goal_func)


## Finds a path for [param actor] from its current origin cell to any cell that
## would cause the actor to overlap with [param end_rect].[br]
## Returns an empty list if no path could be found.
static func find_path_to_rect(actor: Actor, end_rect: Rect2i) \
		-> Array[Vector2i]:
	var heuristic_func := \
		func (cell: Vector2i) -> float:
			@warning_ignore("integer_division")
			var actor_centre := cell + (actor.cell_size / 2)
			@warning_ignore("integer_division")
			var end_centre := end_rect.position + (end_rect.size / 2)
			return TileGeometry.manhattan_distance(actor_centre, end_centre)

	var reached_goal_func := \
		func (cell: Vector2i) -> bool:
			var actor_rect := Rect2i(cell, actor.cell_size)
			return end_rect.intersects(actor_rect)

	return _find_path(actor, heuristic_func, reached_goal_func)


# heuristic_func(cell: Vector2i) -> float
# reached_goal_func(cell: vector2i) -> bool
static func _find_path(actor: Actor, heuristic_func: Callable,
		reached_goal_func: Callable) -> Array[Vector2i]:
	var frontier := PriorityQueue.new()
	frontier.push(actor.origin_cell, 0)

	var came_from: Dictionary[Vector2i, Vector2i] = {}

	var cost_so_far: Dictionary[Vector2i, float] = {}
	cost_so_far[actor.origin_cell] = 0

	while not frontier.is_empty():
		var current := frontier.pop() as Vector2i
		if reached_goal_func.call(current):
			return _build_path(current, came_from)

		for neighbor in _get_neighbors(current, actor):
			var new_cost := cost_so_far[current] + _cell_cost(neighbor, actor)
			if not cost_so_far.has(neighbor) \
					or (new_cost < cost_so_far[neighbor]):
				cost_so_far[neighbor] = new_cost
				var priority: float = new_cost + heuristic_func.call(neighbor)
				frontier.push(neighbor, priority)
				came_from[neighbor] = current

	return []


static func _get_neighbors(cell: Vector2i, actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dir in Directions.get_cardinal_dirs():
		var next_cell := cell + dir
		if actor.map.actor_can_enter_cell(actor, next_cell, true):
			result.append(next_cell)
	return result


static func _cell_cost(cell: Vector2i, actor: Actor) -> float:
	var result := 1.0

	# Treat cells occupied by other actors as having a higher move cost instead
	# of as fully blocked.
	for covered_cell in actor.get_covered_cells_at_cell(cell):
		var other_actor := actor.map.get_actor_on_cell(covered_cell)
		if other_actor and (other_actor != actor):
			result = _PATHFIND_COST_OTHER_ACTOR
			break

	return result


static func _build_path(cell: Vector2i,
		came_from: Dictionary[Vector2i, Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	while came_from.has(cell):
		result.append(cell)
		cell = came_from[cell]
	result.reverse()
	return result

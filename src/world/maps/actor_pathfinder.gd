class_name ActorPathfinder

## Custom A-star implementation for actors.

static func find_path(actor: Actor, end: Vector2i) \
		-> Array[Vector2i]:
	var frontier := PriorityQueue.new()
	frontier.push(actor.origin_cell, 0)

	var came_from: Dictionary[Vector2i, Vector2i] = {}

	var cost_so_far: Dictionary[Vector2i, int] = {}
	cost_so_far[actor.origin_cell] = 0

	var end_actor := actor.map.get_actor_on_cell(end)

	while not frontier.is_empty():
		var current := frontier.pop() as Vector2i
		if current == end:
			return _build_path(current, came_from)

		for neighbor in _get_neighbors(current, actor, end_actor):
			var new_cost := cost_so_far[current] + 1
			if not cost_so_far.has(neighbor) \
					or (new_cost < cost_so_far[neighbor]):
				cost_so_far[neighbor] = new_cost
				var priority := new_cost + _get_heuristic(neighbor, end)
				frontier.push(neighbor, priority)
				came_from[neighbor] = current

	return []


static func _get_neighbors(cell: Vector2i, actor: Actor, end_actor: Actor) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dir in TileGeometry.CARDINALS:
		var next_cell := cell + dir
		if actor.map.actor_can_enter_cell(actor, next_cell, [end_actor]):
			result.append(next_cell)
	return result


static func _get_heuristic(cell: Vector2i, end: Vector2i) -> int:
	return TileGeometry.manhattan_distance(cell, end)


static func _build_path(cell: Vector2i,
		came_from: Dictionary[Vector2i, Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	while came_from.has(cell):
		result.append(cell)
		cell = came_from[cell]
	result.reverse()
	return result

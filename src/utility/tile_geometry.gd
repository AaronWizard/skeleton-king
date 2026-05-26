class_name TileGeometry

## Get the [url=https://en.wikipedia.org/wiki/Taxicab_geometry]manhattan
## distance[/url] between two tile cells: the number of cells needed to move
## from [param start] to [param end] while only moving in the four cardinal
## directions.
static func manhattan_distance(start: Vector2, end: Vector2) -> float:
	var diff := (end - start).abs()
	return diff.x + diff.y


## Tests if two rectangles are adjacent but not overlapping. The rectangles
## overlapping or only touching at the corners do not count as adjacent.
static func rects_are_adjacent(a: Rect2i, b: Rect2i) -> bool:
	if a.intersects(b):
		return false

	var touching_horizontally := \
			(a.end.x == b.position.x) or (b.end.x == a.position.x)
	var overlap_y := (a.position.y < b.end.y) and (b.position.y < a.end.y)
	if touching_horizontally and overlap_y:
		return true

	var touching_vertically := \
			(a.end.y == b.position.y) or (b.end.y == a.position.y)
	var overlap_x := (a.position.x < b.end.x) and (b.position.x < a.end.x)
	if touching_vertically and overlap_x:
		return true

	return false


## Get all cells covered by [param rect].
static func cells_in_rect(rect: Rect2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			result.append(Vector2i(x, y))
	return result


## Gets the square of the distance between the centres of two rectangles.
static func rect_distance_squared(a: Rect2i, b: Rect2i) -> float:
	var center_a := Vector2(a.position) + (a.size / 2.0)
	var center_b := Vector2(b.position) + (b.size / 2.0)

	return center_a.distance_squared_to(center_b)


## Gets all cells that are between [param min_dist] and [param max_dist] cells
## away from [param rect] using Manhattan distance.
static func cells_in_range_of_rect(rect: Rect2i, min_dist: int, max_dist: int) \
		-> Array[Vector2i]:
	if min_dist > max_dist:
		push_error("min_dist %d is greater than max_dist %d" \
				% [min_dist, max_dist])
		return []

	var result: Array[Vector2i] = []

	# Get coordinate values of rect edges.
	var left_edge := rect.position.x
	var top_edge := rect.position.y
	var right_edge := rect.end.x - 1
	var bottom_edge := rect.end.y - 1

	# Loop through cells in bounding box resulting from expanding rect by
	# max_dist in all directions.
	for x in range(left_edge - max_dist, right_edge + max_dist + 1):
		for y in range(top_edge - max_dist, bottom_edge + max_dist + 1):
			# Distance between x and left or right side of rect, or zero if x is
			# inside rect.
			var dx := 0
			if x < left_edge:
				dx = left_edge - x
			elif x > right_edge:
				dx = x - right_edge

			# Distance between y and top or bottom of rect, or zero if y is
			# inside rect.
			var dy := 0
			if y < top_edge:
				dy = top_edge - y
			elif y > bottom_edge:
				dy = y - bottom_edge

			var dist := dx + dy # Manhattan distance
			if (dist >= min_dist) and (dist <= max_dist):
				result.append(Vector2i(x, y))

	return result

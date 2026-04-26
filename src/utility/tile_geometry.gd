class_name TileGeometry

const CARDINALS: Array[Vector2i] = [
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
]


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

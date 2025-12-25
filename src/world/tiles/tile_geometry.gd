class_name TileGeometry

## Get the [url=https://en.wikipedia.org/wiki/Taxicab_geometry]manhattan
## distance[/url] between two tile cells: the number of cells needed to move
## from [param start] to [param end] while only moving in the four cardinal
## directions.
static func manhattan_distance(start: Vector2i, end: Vector2i) -> int:
	var diff := (end - start).abs()
	return int(diff.x + diff.y)


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

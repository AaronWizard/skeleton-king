class_name Directions

enum Cardinal {
	NORTH, EAST, SOUTH, WEST
}


static func get_cardinals() -> Array[Cardinal]:
	var result: Array[Cardinal] = []
	result.assign(Cardinal.values())
	return result


static func get_cardinal_dirs() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(get_cardinals().map(cardinal_to_dir))
	return result


static func cardinal_to_dir(cardinal: Cardinal) -> Vector2i:
	var result := Vector2i.ZERO
	match cardinal:
		Cardinal.NORTH:
			result = Vector2i.UP
		Cardinal.EAST:
			result = Vector2i.RIGHT
		Cardinal.SOUTH:
			result = Vector2i.DOWN
		Cardinal.WEST:
			result = Vector2i.LEFT
		_:
			push_error("Unknown cardinal '%s'" % cardinal)
			result = Vector2i.ZERO
	return result


static func dir_to_cardinal(direction: Vector2i) -> Cardinal:
	var result := Directions.Cardinal.SOUTH
	match direction.clampi(-1, 1):
		Vector2i.UP:
			result = Directions.Cardinal.NORTH
		Vector2i.RIGHT:
			result = Directions.Cardinal.EAST
		Vector2i.DOWN:
			result = Directions.Cardinal.SOUTH
		Vector2i.LEFT:
			result = Directions.Cardinal.WEST
		_:
			push_error("%.v is not a valid cardinal" % direction)
	return result

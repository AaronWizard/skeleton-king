class_name Directions

## Functions for handling the four cardinal directions.

## The four cardinal directions.
enum Cardinal {
	NORTH, EAST, SOUTH, WEST
}


## Get an array of all cardinals.
static func get_cardinals() -> Array[Cardinal]:
	var result: Array[Cardinal] = []
	result.assign(Cardinal.values())
	return result


## Get an array of vectors for each cardinal.
static func get_cardinal_dirs() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(get_cardinals().map(cardinal_to_dir))
	return result


## Get the vector for a cardinal.[br]
## Returns the zero vector if [param cardinal] is not valid.
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


## Gets the cardinal for a vector.[br]
## Returns [enum Cardinal.SOUTH] if [param direction] is not a valid
## cardinal vector regardless of its length, i.e. if [param direction] is a
## diagonal vector.
static func dir_to_cardinal(direction: Vector2i) -> Cardinal:
	var result := Cardinal.SOUTH
	match direction.clampi(-1, 1):
		Vector2i.UP:
			result = Cardinal.NORTH
		Vector2i.RIGHT:
			result = Cardinal.EAST
		Vector2i.DOWN:
			result = Cardinal.SOUTH
		Vector2i.LEFT:
			result = Cardinal.WEST
		_:
			push_error("%.v is not a valid cardinal" % direction)
	return result

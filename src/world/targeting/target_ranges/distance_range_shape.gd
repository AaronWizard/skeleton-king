@tool
class_name DistanceRangeShape
extends TargetRangeShape


@export_range(1, 1, 1, "or_greater") var min_dist := 1:
	set(value):
		min_dist = value
		max_dist = maxi(max_dist, min_dist)


@export_range(1, 1, 1, "or_greater") var max_dist := 1:
	set(value):
		if value >= min_dist:
			max_dist = value


func get_cells(actor: Actor) -> Array[Vector2i]:
	return TileGeometry.cells_in_range_of_rect(
			actor.cell_rect, min_dist, max_dist)

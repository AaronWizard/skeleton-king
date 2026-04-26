class_name MarkerLayer
extends Node2D


func has_marker(marker_name: StringName) -> bool:
	return has_node(NodePath(marker_name))


func get_marker_cell(marker_name: StringName) -> Vector2i:
	if not has_marker(marker_name):
		push_error("No marker with name '%s'" % marker_name)

	var result := Vector2.ZERO
	var tile_object := get_node(NodePath(marker_name)) \
			as SquareTileObject
	if tile_object:
		result = tile_object.origin_cell
	return result

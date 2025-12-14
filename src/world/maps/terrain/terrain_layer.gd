@tool
class_name TerrainLayer
extends Node2D

const _TERRAIN_DATA_LAYER_NAME := "terrain"

func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	for c in get_children():
		if not c is TileMapLayer:
			result.append("'%s' is not of type 'TileMapLayer'" % c)
	return result


func get_terrain_name(cell: Vector2i) -> StringName:
	var result := &""

	var layers := get_children()
	layers.reverse()
	for layer: TileMapLayer in layers:
		var tile_data := layer.get_cell_tile_data(cell)
		if not tile_data:
			continue
		if not tile_data.has_custom_data(_TERRAIN_DATA_LAYER_NAME):
			continue

		result = tile_data.get_custom_data(_TERRAIN_DATA_LAYER_NAME)

	return result

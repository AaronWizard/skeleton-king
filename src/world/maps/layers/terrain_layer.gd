@tool
class_name TerrainLayer
extends Node2D

const _TERRAIN_DATA_LAYER_NAME := "terrain"

@export var terrain_library: TerrainLibrary


func get_pixel_rect() -> Rect2i:
	var top_layer := get_children().back() as TileMapLayer
	var tile_size := top_layer.tile_set.tile_size
	var result := get_cell_rect()
	result.position *= tile_size
	result.size *= tile_size
	return result


func get_cell_rect() -> Rect2i:
	var result := Rect2i()
	for layer: TileMapLayer in get_children():
		var layer_rect := layer.get_used_rect()
		result = result.merge(
			Rect2i(layer_rect.position, layer_rect.size)
		)
	return result


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	for c in get_children():
		if not c is TileMapLayer:
			result.append("'%s' is not of type 'TileMapLayer'" % c)
	return result


func get_terrain(cell: Vector2i) -> Terrain:
	if not terrain_library:
		return null

	var result: Terrain = null
	var terrain_name := _get_terrain_name(cell)
	if terrain_library.library.has(terrain_name):
		result = terrain_library.library[terrain_name]
	return result


func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	var result := true
	for covered_cell in actor.get_covered_cells_at_cell(cell):
		var terrain_data := get_terrain(covered_cell)
		result = not terrain_data or not terrain_data.blocks_move
		if not result:
			break
	return result


func _get_terrain_name(cell: Vector2i) -> StringName:
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

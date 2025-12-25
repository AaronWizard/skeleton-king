@tool
class_name TerrainLayer
extends Node2D

const _TERRAIN_DATA_LAYER_NAME := "terrain"

@export var terrain_library: TerrainLibrary


var _rect := Rect2i(Vector2i.ZERO, Vector2i(-1, -1))
var _tile_size := Vector2i(-1, -1)

func get_pixel_rect() -> Rect2i:
	if _tile_size.x == -1:
		var top_layer := get_children().back() as TileMapLayer
		_tile_size = top_layer.tile_set.tile_size
	var result := get_cell_rect()
	result.position *= _tile_size
	result.size *= _tile_size
	return result


func get_cell_rect() -> Rect2i:
	if _rect.size.x == -1:
		_rect.size = Vector2.ZERO
		for layer: TileMapLayer in get_children():
			var layer_rect := layer.get_used_rect()
			_rect = _rect.merge(
				Rect2i(layer_rect.position, layer_rect.size)
			)
	return _rect


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
	if not get_cell_rect().has_point(cell):
		return false

	for covered_cell in actor.get_covered_cells_at_cell(cell):
		var terrain_data := get_terrain(covered_cell)
		var blocks_move = terrain_data and terrain_data.blocks_move
		if blocks_move:
			return false

	return true


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

class_name TargetingGrid
extends Node2D

signal target_selected(target: Vector2i)

const _SOURCE_ID_TARGET_RANGE := 0
const _SOURCE_ID_AOE := 1

const _ATLAS_COORD_TARGET_RANGE := Vector2i.ZERO
const _ATLAS_COORD_AOE := Vector2i.ZERO

@onready var _target_range := $TargetRange as TileMapLayer
@onready var _aoe := $AOE as TileMapLayer
@onready var _target := $Target as RectTileObject

var _target_range_cells: Array[Vector2i] = []


func _unhandled_input(event: InputEvent) -> void:
	if _try_click(event):
		return


func show_targeting(target: Rect2i,
		target_range: Array[Vector2i], aoe: Array[Vector2i]) -> void:
	clear()

	_target.origin_cell = target.position
	_target.cell_dimensions = target.size
	_target.visible = true

	for cell in target_range:
		_target_range.set_cell(
				cell, _SOURCE_ID_TARGET_RANGE, _ATLAS_COORD_TARGET_RANGE)

	_target_range_cells.assign(target_range)

	for cell in aoe:
		_aoe.set_cell(cell, _SOURCE_ID_AOE, _ATLAS_COORD_AOE)


func clear() -> void:
	_target_range.clear()
	_aoe.clear()
	_target.visible = false
	_target_range_cells.clear()


func _try_click(event: InputEvent) -> bool:
	if not event.is_action("click"):
		return false

	var mouse_pos := _target_range.get_local_mouse_position()
	var mouse_cell := _target_range.local_to_map(mouse_pos)

	var result := _target_range_cells.has(mouse_cell)
	if result:
		target_selected.emit(mouse_cell)
	return result

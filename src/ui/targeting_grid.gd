class_name TargetingGrid
extends Node2D

const _SOURCE_ID_TARGET_RANGE := 0
const _SOURCE_ID_AOE := 1

const _ATLAS_COORD_TARGET_RANGE := Vector2i.ZERO
const _ATLAS_COORD_AOE := Vector2i.ZERO

@onready var _target_range := $TargetRange as TileMapLayer
@onready var _aoe := $AOE as TileMapLayer
@onready var _target := $Target as RectTileObject


func show_targeting(target: Rect2i,
		target_range: Array[Vector2i], aoe: Array[Vector2i]) -> void:
	clear()

	_target.position = target.position
	_target.cell_dimensions = target.size
	_target.visible = true

	for cell in target_range:
		_target_range.set_cell(
				cell, _SOURCE_ID_TARGET_RANGE, _ATLAS_COORD_TARGET_RANGE)

	for cell in aoe:
		_aoe.set_cell(cell, _SOURCE_ID_AOE, _ATLAS_COORD_AOE)


func clear() -> void:
	_target_range.clear()
	_aoe.clear()
	_target.visible = false

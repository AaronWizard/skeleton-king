class_name TargetingGrid
extends Node2D

signal target_selected(target: Vector2i)

const _SOURCE_ID_TARGET_RANGE := 0
const _SOURCE_ID_AOE := 1

const _ATLAS_COORD_TARGET_RANGE := Vector2i.ZERO
const _ATLAS_COORD_AOE := Vector2i.ZERO

@onready var _target_range := $TargetRange as TileMapLayer
@onready var _aoe := $AOE as TileMapLayer
@onready var _target := $Target as Target


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wait"):
		_select_target()
	elif event.is_action_released("click"):
		_try_click()


func show_targeting(target_range: Array[Vector2i], aoe: Array[Vector2i]) -> void:
	clear()

	_target.show_with_target_range(target_range)

	for cell in target_range:
		_target_range.set_cell(
				cell, _SOURCE_ID_TARGET_RANGE, _ATLAS_COORD_TARGET_RANGE)

	for cell in aoe:
		_aoe.set_cell(cell, _SOURCE_ID_AOE, _ATLAS_COORD_AOE)


func clear() -> void:
	_target_range.clear()
	_aoe.clear()
	_target.clear_and_hide()


func _try_click() -> void:
	var mouse_pos := _target_range.get_local_mouse_position()
	var mouse_cell := _target_range.local_to_map(mouse_pos)

	if _target.covers_cell(mouse_cell):
		_select_target()
	else:
		_target.try_assign_cell(mouse_cell)


func _select_target() -> void:
	target_selected.emit(_target.origin_cell)


func _on_target_moved() -> void:
	print("target moved to ", _target.origin_cell)

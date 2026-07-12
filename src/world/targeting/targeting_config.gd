@icon("uid://bsynj7bxhunni")
class_name TargetingConfig
extends Resource

## An action's target range and AOE.
##
## An action's target range and AOE. Can be used for actor abilities or for
## other actions like using objects.

## The type of cells the action targets.
@export var target_type := TargetType.Type.CELL

## The base target range.
@export var target_range_shape: TargetRangeShape
## Filters applied to the base target range to determine the final target range.
@export var target_range_filters: Array[TargetRangeFilter] = []


## The base area-of-effect for a given target.
@export var aoe_shape: AoeShape
## Filters applied to the base area-of-effect to determine the final AOE for a
## given target.
@export var aoe_filters: Array[AoeFilter] = []


## Returns true if [param target] is a valid target for this ability and
## [param actor] at its current cell.
func target_is_valid(actor: Actor, target: Vector2i) -> bool:
	var range_shape := _get_target_range_shape(actor)
	var base_target_range := _get_base_target_range(actor, range_shape, false)
	var valid_targets := _get_valid_targets(actor, base_target_range)
	return target in valid_targets


## Gets the complete targeting data for the ability and [param actor] at its
## current cell.
func get_targeting_data(actor: Actor) -> TargetingData:
	var range_shape := _get_target_range_shape(actor)

	var base_target_range := _get_base_target_range(actor, range_shape, false)
	var valid_targets := _get_valid_targets(actor, base_target_range)

	var ui_target_range := _get_base_target_range(actor, range_shape, true)

	var aoes: Dictionary[Vector2i, Array] = {}
	var ui_aoes: Dictionary[Vector2i, Array] = {}
	for target in valid_targets:
		var aoe_shp := _get_aoe_shape(actor, target)
		var aoe := _get_aoe(actor, target, aoe_shp, false)
		var ui_aoe := _get_aoe(actor, target, aoe_shp, true)
		aoes[target] = aoe
		ui_aoes[target] = ui_aoe

	return TargetingData.new(
		target_type, valid_targets, ui_target_range, aoes, ui_aoes
	)


## Gets the non-UI AOE for the action at [param target] for [param actor].
func get_aoe(actor: Actor, target: Vector2i) -> Array[Vector2i]:
	var aoe_shp := _get_aoe_shape(actor, target)
	var aoe := _get_aoe(actor, target, aoe_shp, false)
	return aoe


func _get_target_range_shape(actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i]
	if target_range_shape:
		result = target_range_shape.get_cells(actor)
	else:
		result = [actor.origin_cell]
	return result


func _get_base_target_range(
		actor: Actor, range_shape: Array[Vector2i], for_ui: bool) \
		-> Array[Vector2i]:
	if not target_range_filters or target_range_filters.is_empty():
		return range_shape
	else:
		var filter_func := func (filter: TargetRangeFilter, target: Vector2i) \
				-> bool:
			return (for_ui and not filter.use_in_ui) \
					or filter.cell_in_range(target, actor)
		var range_filter_funct := func (target: Vector2i) -> bool:
			return target_range_filters.all(filter_func.bind(target))

		var result: Array[Vector2i]
		result.assign( range_shape.filter(range_filter_funct) )
		return result


func _get_valid_targets(actor: Actor, base_range: Array[Vector2i]) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []
	match target_type:
		TargetType.Type.ACTOR:
			var target_set: Dictionary[Vector2i, bool] = {}
			for cell in base_range:
				var other_actor := actor.map.get_actor_on_cell(cell)
				if other_actor:
					target_set[other_actor.origin_cell] = true
			result.assign(target_set.keys())
		TargetType.Type.OBJECT:
			var target_set: Dictionary[Vector2i, bool] = {}
			for cell in base_range:
				var object := actor.map.get_useable_object_on_cell(cell)
				if object:
					target_set[object.origin_cell] = true
			result.assign(target_set.keys())
		_:
			result.assign(base_range)
	return result


func _get_aoe_shape(actor: Actor, target: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i]
	if aoe_shape:
		result = aoe_shape.get_cells(target, actor)
	else:
		result = [target]
	return result


func _get_aoe(
		actor: Actor, target: Vector2i,
		base_aoe: Array[Vector2i], for_ui: bool) -> Array[Vector2i]:
	if not aoe_filters or aoe_filters.is_empty():
		return base_aoe
	else:
		var filter_func := func (filter: AoeFilter, cell: Vector2i) -> bool:
			return (for_ui and not filter.use_in_ui) \
					or filter.cell_affected(cell, target, actor)
		var aoe_filter_funct := func (cell: Vector2i) -> bool:
			return aoe_filters.all(filter_func.bind(cell))

		var result: Array[Vector2i]
		result.assign( base_aoe.filter(aoe_filter_funct) )
		return result

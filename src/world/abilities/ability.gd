@icon("uid://bsynj7bxhunni")
class_name Ability
extends Resource

## An actor's ability.

## The name of the ability.
@export var name: String
## The ability's icon.
@export var icon: Texture2D

## The type of target the ability uses.
@export var target_type: TargetType.Type

## The base target range.
@export var target_range_shape: TargetRangeShape
## Filters applied to the base target range to determine the final target range.
@export var target_range_filters: Array[TargetRangeFilter] = []

## The base area-of-effect for a given target.
@export var aoe_shape: AoeShape
## Filters applied to the base area-of-effect to determine the final AOE for a
## given target.
@export var aoe_filters: Array[AoeFilter] = []

## The effects applied when the ability is run for a given actor and target.
@export var effects: Array[AbilityEffect]


## Returns true if [param target] is a valid target for this ability and
## [param actor] at its current cell.
func target_is_valid(actor: Actor, target: Vector2i) -> bool:
	var base_range := _get_base_target_range(actor)
	var target_range := _get_target_range(actor, base_range, false)
	return target in target_range


## Gets the cells in the ability's area-of-effect at [param target] for
## [param actor] at its current cell.[br]
## [param for_ui] determines if the result is used for the UI or for regular AOE
## logic.
func get_aoe(target: Vector2i, actor: Actor, for_ui := false) \
		-> Array[Vector2i]:
	var base_aoe := _get_base_aoe(actor, target)
	return _get_aoe(actor, target, base_aoe, for_ui)


## Gets the complete targeting data for the ability and [param actor] at its
## current cell.
func get_targeting_data(actor: Actor) -> TargetingData:
	var base_range := _get_base_target_range(actor)
	var valid_targets := _get_target_range(actor, base_range, false)
	var ui_target_range := _get_target_range(actor, base_range, true)

	var aoes: Dictionary[Vector2i, Array] = {}
	var ui_aoes: Dictionary[Vector2i, Array] = {}
	for target in valid_targets:
		var base_aoe := _get_base_aoe(actor, target)
		var aoe := _get_aoe(actor, target, base_aoe, false)
		var ui_aoe := _get_aoe(actor, target, base_aoe, true)
		aoes[target] = aoe
		ui_aoes[target] = ui_aoe

	return TargetingData.new(
		valid_targets, ui_target_range, aoes, ui_aoes
	)


## Runs the ability with a given source actor and target.[br]
## Assumes [param target] is a valid target.
func run(actor: Actor, target: Vector2i) -> void:
	if actor.map.animations_running:
		await actor.map.animations_finished

	var aoe := get_aoe(target, actor)
	var data := AbilityData.new(
			actor, actor.origin_cell, target, target_type, aoe)

	for e in effects:
		@warning_ignore("redundant_await")
		await e.run(data)


## Creates an [AbilityAction] that makes [param actor] use this ability at
## [param target].
func create_turn_action(actor: Actor, target: Vector2i) -> TurnAction:
	return AbilityAction.new(actor, self, target)


func _get_base_target_range(actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i]
	if target_range_shape:
		result = target_range_shape.get_cells(actor)
	else:
		result = [actor.origin_cell]
	return result


func _get_target_range(
		actor: Actor, base_range: Array[Vector2i], for_ui: bool) \
		-> Array[Vector2i]:
	if not target_range_filters or target_range_filters.is_empty():
		return base_range
	else:
		var filter_func := func (filter: TargetRangeFilter, target: Vector2i) \
				-> bool:
			return (for_ui and not filter.use_in_ui) \
					or filter.cell_in_range(target, actor)
		var range_filter_funct := func (target: Vector2i) -> bool:
			return target_range_filters.all(filter_func.bind(target))

		var result: Array[Vector2i]
		result.assign( base_range.filter(range_filter_funct) )
		return result


func _get_base_aoe(actor: Actor, target: Vector2i) -> Array[Vector2i]:
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

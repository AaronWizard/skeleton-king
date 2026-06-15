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
@export var aoe_filter: Array[AoeFilter] = []

## The effects applied when the ability is run for a given actor and target.
@export var effects: Array[AbilityEffect]


## Gets the cells the ability may target for [param actor].[br]
## [param for_ui] determines if the result is used for the UI or for regular
## targeting logic.
func get_target_range(actor: Actor, for_ui := false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var base_range: Array[Vector2i]
	if target_range_shape:
		base_range = target_range_shape.get_cells(actor)
	else:
		base_range = [actor.origin_cell]

	for target in base_range:
		if not target_range_filters or target_range_filters.is_empty():
			result.append(target)
		else:
			var filter := func (f: TargetRangeFilter) -> bool:
				return (for_ui and not f.use_in_ui) \
						or f.cell_in_range(target, actor)
			if target_range_filters.all(filter):
				result.append(target)

	return result


## Gets the cells in the ability's area-of-effect at [param target] for
## [param actor].[br]
## [param for_ui] determines if the result is used for the UI or for regular AOE
## logic.
func get_aoe(target: Vector2i, actor: Actor, for_ui := false) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var base_range: Array[Vector2i]
	if aoe_shape:
		base_range = aoe_shape.get_cells(target, actor)
	else:
		base_range = [target]

	for cell in base_range:
		if not aoe_filter or aoe_filter.is_empty():
			result.append(cell)
		else:
			var filter := func (f: AoeFilter) -> bool:
				return (for_ui and not f.use_in_ui) \
						or f.cell_affected(cell, target, actor)
			if aoe_filter.all(filter):
				result.append(target)

	return result


func target_is_valid(actor: Actor, target: Vector2i) -> bool:
	return target in get_target_range(actor)


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

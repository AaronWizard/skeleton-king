@abstract
@icon("uid://bsynj7bxhunni")
class_name AoeFilter
extends Resource

## Determins if a cell is included in an ability's AOE for a given target.

## If true, filter will be used when displaying the AOE for an ability's target
## in the UI.
@export var use_in_ui := true

## Checks if [param cell] is included in the ability's AOE around [param target]
## for [param actor].[br]
## Assumes [param cell] is within the AOE set by the ability's
## [member Ability.aoe_shape].
@abstract func cell_affected(cell: Vector2i, \
		target_cell: Vector2i, actor: Actor) -> bool

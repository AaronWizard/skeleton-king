@abstract
@icon("uid://bsynj7bxhunni")
class_name AoeFilter
extends Resource

## Determins if a cell is included in an action's AOE for a given target.

## If true, filter will be used when displaying the AOE for an action's target
## in the UI.
@export var use_in_ui := true

## Checks if [param cell] is included in the action's AOE around [param target]
## for [param actor].[br]
## Assumes [param cell] is within the action's AOE, e.g.
## [member Ability.aoe_shape] for abilities.
@abstract func cell_affected(cell: Vector2i, \
		target_cell: Vector2i, actor: Actor) -> bool

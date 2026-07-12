@abstract
@icon("uid://bsynj7bxhunni")
class_name TargetRangeFilter
extends Resource

## Determins if a cell is a valid target in an action's base target range.
##
## Determins if a cell is a valid target in an action's base target range as
## derived from a [TargetRangeShape].[br]
## [br]
## Example: All cells covered by an actor.

## If true, filter will be used when displaying an action's target range in the
## UI.[br]
## [br]
## Example: Consider a filter that checks if a target cell is filtered by an
## actor, and an action that only has that one filter. If
## [member TargetRangeFilter.use_in_ui] is set to true, only cells occupied by
## actors will be displayed when the action's target range is displayed in-game.
## If this is set to false, the action's full target range is displayed.
@export var use_in_ui := true

## Checks if [param cell] is a valid target for the action when used by
## [param actor].[br]
## Assumes [param cell] is within the range. e.g. Within
## [member Ability.target_range_shape] for abilities.
@abstract func cell_in_range(cell: Vector2i, actor: Actor) -> bool

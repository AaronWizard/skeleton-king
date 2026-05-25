@abstract
@icon("uid://bsynj7bxhunni")
class_name TargetRangeFilter
extends Resource

## Determins if a cell is a valid target in an ability's base target range.

## If true, filter will be used when displaying an ability's target range in the
## UI.
@export var use_in_ui := true

## Checks if [param cell] is a valid target for the ability when used by
## [param actor].[br]
## Assumes [param cell] is within the range set by the ability's
## [member Ability.target_range_shape].
@abstract func cell_in_range(cell: Vector2i, actor: Actor) -> bool

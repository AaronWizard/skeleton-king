@abstract
@icon("uid://bsynj7bxhunni")
class_name TargetRangeShape
extends Resource

## The base target range of an action before filtering.
##
## The base target range of an action before filtering.[br]
## [br]
## Example: All cells between X and Y cells of the source actor.

## Gets the cells in the action's base target range for [param actor].
@abstract func get_cells(actor: Actor) -> Array[Vector2i]

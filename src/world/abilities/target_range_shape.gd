@abstract
@icon("uid://bsynj7bxhunni")
class_name TargetRangeShape
extends Resource

## The base target range of an ability before filtering.

## Gets the cells in the ability's base target range for [param actor].
@abstract func get_cells(actor: Actor) -> Array[Vector2i]

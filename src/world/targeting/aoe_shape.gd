@abstract
@icon("uid://bsynj7bxhunni")
class_name AoeShape
extends Resource

## The base AOE around an action target before filtering.

## Gets the cells in the base AOE around [param target_cell] for [param actor].
@abstract func get_cells(target_cell: Vector2i, actor: Actor) -> Array[Vector2i]

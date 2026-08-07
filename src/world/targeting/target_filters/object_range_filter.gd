class_name ObjectRangeFilter
extends TargetRangeFilter

enum CanUse
{
	ANY, TRUE, FALSE
}

@export var can_use := CanUse.TRUE


func cell_in_range(cell: Vector2i, actor: Actor) -> bool:
	var object := actor.map.get_useable_object_on_cell(cell)
	if not object:
		return false

	var result := true
	match can_use:
		CanUse.TRUE:
			result = object.can_use()
		CanUse.FALSE:
			result = not object.can_use()
	return result

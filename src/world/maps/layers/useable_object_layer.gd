@tool
class_name UseableObjectLayer
extends Node2D


var objects: Array[UseableObject]:
	get:
		var result: Array[UseableObject] = []
		result.assign(get_children())
		return result


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	for c in get_children():
		if not c is UseableObject:
			result.append("'%s' is not of type 'UseableObject'" % c)
	return result


func get_object_on_cell(cell: Vector2i) -> UseableObject:
	var result: UseableObject = null
	for o in objects:
		if o.covers_cell(cell):
			result = o
			break
	return result


func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	var result := true
	for covered_cell in actor.get_covered_cells_at_cell(cell):
		var object := get_object_on_cell(cell)
		result = not object or not object.current_state.blocks_move
		if not result:
			break
	return result

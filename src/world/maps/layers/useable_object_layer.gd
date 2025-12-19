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

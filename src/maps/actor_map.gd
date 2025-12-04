@tool
class_name ActorMap
extends Node2D


var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []
		result.assign(get_children())
		return result


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	for c in get_children():
		if not c is Actor:
			result.append("'%s' is not of type 'Actor'" % c)
	return result


func get_actor_on_cell(cell: Vector2i) -> Actor:
	var result: Actor = null
	for a in actors:
		if a.covers_cell(cell):
			result = a
			break
	return result

@tool
class_name ActorLayer
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
	for a: Actor in get_children():
		if a.covers_cell(cell):
			result = a
			break
	return result


func get_actors_on_cells(cells: Array[Vector2i]) -> Array[Actor]:
	var actor_set: Dictionary[Actor, bool] = {}
	for c in cells:
		var actor := get_actor_on_cell(c)
		if actor:
			actor_set[actor] = true
	var result: Array[Actor] = []
	result.assign(actor_set.keys())
	return result


func get_actors_in_rect(rect: Rect2i) -> Array[Actor]:
	var result: Array[Actor] = []
	for a: Actor in get_children():
		if a.cell_rect.intersects(rect):
			result.append(a)
	return result


func actor_can_enter_cell(
		actor: Actor, cell: Vector2i, ignore_other_actors: bool) -> bool:
	var result := true
	for covered_cell in actor.get_covered_cells_at_cell(cell):
		var other_actor := get_actor_on_cell(covered_cell)
		result = not other_actor \
			or (other_actor == actor) \
			or ignore_other_actors
		if not result:
			break
	return result

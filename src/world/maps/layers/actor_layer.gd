@tool
class_name ActorLayer
extends Node2D

signal actor_added(actor: Actor)
signal actor_removed(actor: Actor)
signal actor_moved(actor: Actor, old_cell: Vector2i)


var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []
		result.assign(get_children())
		return result


func _ready() -> void:
	child_entered_tree.connect(_on_actor_added)


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


func _on_actor_added(node: Node) -> void:
	var actor := node as Actor
	if not actor:
		push_error("%s is not an actor" % node.name)

	actor.moved.connect(_on_actor_moved.bind(actor))
	actor.tree_exited.connect(_on_actor_removed.bind(actor))

	actor_added.emit(actor)


func _on_actor_removed(actor: Actor) -> void:
	actor.moved.disconnect(_on_actor_moved)
	actor.tree_exited.disconnect(_on_actor_removed)
	actor_removed.emit(actor)


func _on_actor_moved(old_cell: Vector2i, actor: Actor) -> void:
	actor_moved.emit(actor, old_cell)

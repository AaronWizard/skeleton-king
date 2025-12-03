@tool
class_name MapDesign
extends Node2D

## A design version of a map for editing.

const _CHILD_NAME_TERRAIN := "Terrain"
const _CHILD_NAME_ACTORS := "Actors"

var _terrain: Node2D = null
var _actors: Node2D = null


func _ready() -> void:
	y_sort_enabled = true
	_terrain = _init_node(_CHILD_NAME_TERRAIN)
	_actors = _init_node(_CHILD_NAME_ACTORS)
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()

	if _terrain:
		for c in _terrain.get_children():
			if c is not TileMapLayer:
				result.append("'%s' is not a TileMapLayer" % c.name)
	else:
		result.append("No Node2D child named '%s'" % _CHILD_NAME_TERRAIN)

	if _actors:
		for c in _actors.get_children():
			if c is not Actor:
				result.append("'%s' is not an Actor" % c.name)
	else:
		result.append("No Node2D child named '%s'" % _CHILD_NAME_ACTORS)

	return result


func _init_node(child_name: String) -> Node2D:
	var result: Node2D = null

	if has_node(child_name):
		var child := get_node(child_name)
		if child is not Node2D:
			remove_child(child)
		else:
			result = child as Node2D

	if not result:
		result = Node2D.new()
		result.name = child_name
		result.y_sort_enabled = true

		add_child(result)
		result.owner = self

	return result

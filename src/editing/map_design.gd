@tool
class_name MapDesign
extends Node2D

## A design version of a map for editing.

const _LAYER_NAME_TERRAIN := "Terrain"
const _LAYER_NAME_ACTORS := "Actors"
const _LAYER_NAME_MARKERS := "Markers"


var terrain: Array[TileMapLayer]:
	get:
		var result: Array[TileMapLayer] = []

		var layer := get_node(_LAYER_NAME_TERRAIN)
		if layer:
			for tilemap: TileMapLayer in layer.get_children():
				result.append(tilemap.duplicate())

		return result


var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []

		var layer := get_node(_LAYER_NAME_ACTORS)
		if layer:
			for design: ActorDesign in layer.get_children():
				result.append(design.create_actor())

		return result


var markers: Array[TileObject]:
	get:
		var result: Array[TileObject] = []

		var layer := get_node(_LAYER_NAME_MARKERS)
		if layer:
			for marker: TileObject in layer.get_children():
				result.append(marker.duplicate())

		return result


func _ready() -> void:
	y_sort_enabled = true
	_init_node(_LAYER_NAME_TERRAIN)
	_init_node(_LAYER_NAME_ACTORS)
	_init_node(_LAYER_NAME_MARKERS)
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()

	var terrain_layer := get_node(_LAYER_NAME_TERRAIN)
	if terrain_layer:
		for c in terrain_layer.get_children():
			if c is not TileMapLayer:
				result.append("'%s' is not a TileMapLayer" % c.name)
	else:
		result.append("No Node2D child named '%s'" % _LAYER_NAME_TERRAIN)

	var actor_layer := get_node(_LAYER_NAME_ACTORS)
	if actor_layer:
		for c in actor_layer.get_children():
			if c is not ActorDesign:
				result.append("'%s' is not an ActorDesign" % c.name)
	else:
		result.append("No Node2D child named '%s'" % _LAYER_NAME_ACTORS)

	var marker_layer := get_node(_LAYER_NAME_MARKERS)
	if marker_layer:
		for c in marker_layer.get_children():
			if c is not TileObject:
				result.append("'%s' is not a TileObject" % c.name)
	else:
		result.append("No Node2D child named '%s'" % _LAYER_NAME_MARKERS)

	return result


func _init_node(child_name: String) -> void:
	var layer: Node2D = null

	if has_node(child_name):
		var child := get_node(child_name)
		if child is not Node2D:
			remove_child(child)
		else:
			layer = child as Node2D

	if not layer:
		layer = Node2D.new()
		layer.name = child_name
		layer.y_sort_enabled = true

		add_child(layer)
		layer.owner = self

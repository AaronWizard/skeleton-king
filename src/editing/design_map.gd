@icon("uid://33e4vppa4045")
@tool
class_name DesignMap
extends Node2D

## A design version of a map for editing.

const _LAYER_NAME_TERRAIN := "Terrain"
const _LAYER_NAME_USEABLE_OBJECTS := "UseableObjects"
const _LAYER_NAME_ACTORS := "Actors"
const _LAYER_NAME_MARKERS := "Markers"


var terrain: Array[TileMapLayer]:
	get:
		var result: Array[TileMapLayer] = []
		result.assign(_get_layer_data(_LAYER_NAME_TERRAIN, "duplicate"))
		return result


var useable_objects: Array[UseableObject]:
	get:
		var result: Array[UseableObject] = []
		result.assign(
			_get_layer_data(
				_LAYER_NAME_USEABLE_OBJECTS, "create_useable_object"
			)
		)
		return result


var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []
		result.assign(_get_layer_data(_LAYER_NAME_ACTORS, "create_actor"))
		return result


var markers: Array[SquareTileObject]:
	get:
		var result: Array[SquareTileObject] = []
		result.assign(_get_layer_data(_LAYER_NAME_MARKERS, "duplicate"))
		return result


func _ready() -> void:
	y_sort_enabled = true
	_init_node(_LAYER_NAME_TERRAIN, 0)
	_init_node(_LAYER_NAME_USEABLE_OBJECTS, 1)
	_init_node(_LAYER_NAME_ACTORS, 2)
	_init_node(_LAYER_NAME_MARKERS, 3)
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()

	_check_layer(_LAYER_NAME_TERRAIN, "TileMapLayer", null, result)
	_check_layer(_LAYER_NAME_USEABLE_OBJECTS, "", DesignUseableObject, result)
	_check_layer(_LAYER_NAME_ACTORS, "", DesignActor, result)
	_check_layer(_LAYER_NAME_MARKERS, "", SquareTileObject, result)

	return result


func _check_layer(layer_name: String, expected_class: String,
		expected_script: Script, warnings: PackedStringArray) -> void:
	var layer := get_node(layer_name) as Node2D
	if layer:
		for c in layer.get_children():
			if expected_class and not c.is_class(expected_class):
				warnings.append(
					"'%s' is not of class %s" \
					% [c.name, expected_class]
				)
			elif expected_script and c.get_script() != expected_script:
				warnings.append(
					"'%s' is not of class %s" \
					% [c.name, expected_script.get_global_name()]
				)
	else:
		warnings.append("No Node2D child named '%s'" % layer_name)


func _init_node(layer_name: String, index: int) -> void:
	var layer: Node2D = null

	if has_node(layer_name):
		var child := get_node(layer_name)
		if child is not Node2D:
			remove_child(child)
		else:
			layer = child as Node2D

	if not layer:
		layer = Node2D.new()
		layer.name = layer_name
		layer.y_sort_enabled = true

		add_child(layer)
		layer.owner = self
		move_child(layer, index)

	if layer.get_index() != index:
		move_child(layer, index)


func _get_layer_data(layer_name: String, method_name: String) -> Array:
	var result := []

	var layer := get_node(layer_name)
	for object in layer.get_children():
		var data = object.call(method_name)
		if not data:
			push_error(
				"'%s': '%s' did not create data with '%s'" \
				% [layer_name, object.name, method_name]
			)
		else:
			result.append(data)

	return result

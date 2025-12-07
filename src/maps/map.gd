class_name Map
extends Node2D

@export var terrain_library: TerrainLibrary


var actors: Array[Actor]:
	get:
		return _actor_layer.actors


@onready var _terrain_layer := $TerrainLayer as TerrainLayer
@onready var _actor_layer := $ActorLayer as ActorLayer
@onready var _marker_layer := $MarkerLayer


func load_map(design_map: MapDesign) -> void:
	_clear()
	for tilemap in design_map.terrain:
		_terrain_layer.add_child(tilemap)
	for actor in design_map.actors:
		_actor_layer.add_child(actor)
	for marker in design_map.markers:
		_marker_layer.add_child(marker)


func add_actor(actor: Actor, cell: Vector2i) -> void:
	actor.origin_cell = cell
	_actor_layer.add_child(actor)


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_layer.get_actor_on_cell(cell)


func has_marker(marker_name: StringName) -> bool:
	return _marker_layer.has_node(NodePath(marker_name))


func get_marker_cell(marker_name: StringName) -> Vector2i:
	if not has_marker(marker_name):
		push_error("No marker with name '%s'" % marker_name)

	var result := Vector2.ZERO
	var tile_object := _marker_layer.get_node(NodePath(marker_name)) \
			as TileObject
	if tile_object:
		result = tile_object.origin_cell
	return result


func _clear() -> void:
	_clear_layer(_terrain_layer)
	_clear_layer(_actor_layer)


static func _clear_layer(layer: Node) -> void:
	while layer.get_child_count() > 0:
		var c := layer.get_child(0)
		layer.remove_child(c)
		c.free()

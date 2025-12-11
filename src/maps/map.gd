class_name Map
extends Node2D

signal actor_added(actor: Actor)
signal actor_removed(actor: Actor)

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
		add_actor(actor, actor.origin_cell)
	for marker in design_map.markers:
		_marker_layer.add_child(marker)


func add_actor(actor: Actor, cell: Vector2i) -> void:
	actor.origin_cell = cell
	_actor_layer.add_child(actor)
	actor.map = self
	actor_added.emit(actor)


func remove_actor(actor: Actor) -> void:
	if actor not in _actor_layer.get_children():
		push_error("Actor '%s' not on this map" % actor.name)
		return
	_actor_layer.remove_child(actor)
	actor.map = null
	actor_removed.emit(actor)


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_layer.get_actor_on_cell(cell)


func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	var result := false
	var terrain_data := _get_terrain_data(cell)
	result = not terrain_data or not terrain_data.blocks_move
	if result:
		var other_actor := get_actor_on_cell(cell)
		result = (not other_actor) or (other_actor == actor)
	return result


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


func _get_terrain_data(cell: Vector2i) -> Terrain:
	var result: Terrain = null
	var terrain_name := _terrain_layer.get_terrain_name(cell)
	if terrain_library.library.has(terrain_name):
		result = terrain_library.library[terrain_name]
	return result


static func _clear_layer(layer: Node) -> void:
	while layer.get_child_count() > 0:
		var c := layer.get_child(0)
		layer.remove_child(c)
		c.free()

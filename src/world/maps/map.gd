@icon("uid://33e4vppa4045")
class_name Map
extends Node2D

signal actor_added(actor: Actor)
signal actor_removed(actor: Actor)

signal animation_started
signal animations_finished

@export var terrain_library: TerrainLibrary


var actors: Array[Actor]:
	get:
		return _actor_layer.actors


var useable_objects: Array[UseableObject]:
	get:
		return _useable_object_layer.objects


var animations_running: bool:
	get:
		return _anim_count > 0


var _anim_count := 0

var _pathfinder: Pathfinder

@onready var _terrain_layer := $TerrainLayer as TerrainLayer
@onready var _useable_object_layer := $UseableObjectLayer as UseableObjectLayer
@onready var _actor_layer := $ActorLayer as ActorLayer
@onready var _marker_layer := $MarkerLayer


func _ready() -> void:
	_terrain_layer.terrain_library = terrain_library
	_actor_layer.actor_moved.connect(_on_actor_moved)


func load_map(design_map: DesignMap) -> void:
	_clear()

	for tilemap in design_map.terrain:
		_terrain_layer.add_child(tilemap)
	_init_pathfinder()

	for object in design_map.useable_objects:
		_useable_object_layer.add_child(object)
	for actor in design_map.actors:
		add_actor(actor, actor.origin_cell)
	for marker in design_map.markers:
		_marker_layer.add_child(marker)


func get_pixel_rect() -> Rect2i:
	return _terrain_layer.get_pixel_rect()


func get_cell_rect() -> Rect2i:
	return _terrain_layer.get_cell_rect()

#region Actors

func add_actor(actor: Actor, cell: Vector2i) -> void:
	actor.origin_cell = cell
	_actor_layer.add_child(actor)
	actor.map = self

	_pathfinder.init_grid_for_actor_size(actor.cell_size)
	_pathfinder.set_rect_solid(actor.cell_rect, true)

	actor.sprite.animation_started.connect(_animation_added)
	actor.sprite.animation_finished.connect(_animation_finished)

	actor_added.emit(actor)


func remove_actor(actor: Actor) -> void:
	if actor not in _actor_layer.get_children():
		push_error("Actor '%s' not on this map" % actor.name)
		return
	_actor_layer.remove_child(actor)
	actor.map = null

	_pathfinder.set_rect_solid(actor.cell_rect, false)

	actor.sprite.animation_started.disconnect(_animation_added)
	actor.sprite.animation_finished.disconnect(_animation_finished)
	if actor.sprite.animation_playing:
		_animation_finished()

	actor_removed.emit(actor)


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_layer.get_actor_on_cell(cell)


func get_useable_object_on_cell(cell: Vector2i) -> UseableObject:
	return _useable_object_layer.get_object_on_cell(cell)


func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	return _actor_layer.actor_can_enter_cell(actor, cell) \
		and _terrain_layer.actor_can_enter_cell(actor, cell) \
		and _useable_object_layer.actor_can_enter_cell(actor, cell)


func _on_actor_moved(actor: Actor, old_cell: Vector2i) -> void:
	_pathfinder.set_rect_solid(Rect2i(old_cell, actor.cell_size), false)
	_pathfinder.set_rect_solid(actor.cell_rect, true)

#endregion Actors

func get_terrain(cell: Vector2i) -> Terrain:
	return _terrain_layer.get_terrain(cell)


func has_marker(marker_name: StringName) -> bool:
	return _marker_layer.has_node(NodePath(marker_name))


func get_marker_cell(marker_name: StringName) -> Vector2i:
	if not has_marker(marker_name):
		push_error("No marker with name '%s'" % marker_name)

	var result := Vector2.ZERO
	var tile_object := _marker_layer.get_node(NodePath(marker_name)) \
			as SquareTileObject
	if tile_object:
		result = tile_object.origin_cell
	return result


func _clear() -> void:
	_clear_layer(_terrain_layer)
	_clear_layer(_useable_object_layer)
	_clear_layer(_actor_layer)
	_clear_layer(_marker_layer)
	_pathfinder = null


# Initializes pathfinder and sets walls based on terrain.
func _init_pathfinder() -> void:
	var rect := get_cell_rect()
	_pathfinder = Pathfinder.new(rect)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			var terrain := get_terrain(cell)
			if terrain:
				_pathfinder.set_cell_solid(Vector2i(x, y), terrain.blocks_move)


func _animation_added() -> void:
	_anim_count += 1
	if _anim_count == 1:
		animation_started.emit()


func _animation_finished() -> void:
	if _anim_count == 0:
		push_error("Animations not running")
		return
	_anim_count -= 1
	if _anim_count == 0:
		animations_finished.emit()


static func _clear_layer(layer: Node) -> void:
	while layer.get_child_count() > 0:
		var c := layer.get_child(0)
		layer.remove_child(c)
		c.free()

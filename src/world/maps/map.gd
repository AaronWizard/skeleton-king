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
		return _animation_tracker.animations_running


var _pathfinder: Pathfinder
var _animation_tracker := AnimationTracker.new()

@onready var _terrain_layer := $TerrainLayer as TerrainLayer
@onready var _useable_object_layer := $UseableObjectLayer as UseableObjectLayer
@onready var _actor_layer := $ActorLayer as ActorLayer
@onready var _marker_layer := $MarkerLayer as MarkerLayer

@onready var _pathfinder_debug_drawer \
		:= $PathfinderDebugDrawer as PathfinderDebugDrawer


func _ready() -> void:
	_terrain_layer.terrain_library = terrain_library
	_animation_tracker.animation_started.connect(animation_started.emit)
	_animation_tracker.animations_finished.connect(animations_finished.emit)


func load_map(design_map: DesignMap) -> void:
	_clear()

	for tilemap in design_map.terrain:
		_terrain_layer.add_child(tilemap)

	for object in design_map.useable_objects:
		_useable_object_layer.add_child(object)
	for actor in design_map.actors:
		add_actor(actor, actor.origin_cell)
	for marker in design_map.markers:
		_marker_layer.add_child(marker)

	_pathfinder = PathfinderFactory.create_pathfinder(
			_terrain_layer, _useable_object_layer, _actor_layer)
	_pathfinder_debug_drawer.pathfinder = _pathfinder


func get_pixel_rect() -> Rect2i:
	return _terrain_layer.get_pixel_rect()


func get_cell_rect() -> Rect2i:
	return _terrain_layer.get_cell_rect()

#region Actors

func add_actor(actor: Actor, cell: Vector2i) -> void:
	actor.origin_cell = cell
	_actor_layer.add_child(actor)
	actor.map = self
	_animation_tracker.observe_actor(actor)
	actor_added.emit(actor)


func remove_actor(actor: Actor) -> void:
	if actor not in _actor_layer.get_children():
		push_error("Actor '%s' not on this map" % actor.name)
		return
	_actor_layer.remove_child(actor)
	actor.map = null
	_animation_tracker.unobserve_actor(actor)
	actor_removed.emit(actor)


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_layer.get_actor_on_cell(cell)


func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	return _actor_layer.actor_can_enter_cell(actor, cell) \
		and _terrain_layer.actor_can_enter_cell(actor, cell) \
		and _useable_object_layer.actor_can_enter_cell(actor, cell)


func find_path(actor: Actor, end: Vector2i) -> Array[Vector2i]:
	_pathfinder.set_rect_solid(actor.cell_rect, false)

	var other_actor := get_actor_on_cell(end)
	if other_actor:
		_pathfinder.set_rect_solid(other_actor.cell_rect, false)

	var result := _pathfinder.find_path(actor.origin_cell, end, actor.cell_size)

	_pathfinder.set_rect_solid(actor.cell_rect, false)
	if other_actor:
		_pathfinder.set_rect_solid(other_actor.cell_rect, true)

	return result

#endregion Actors

func get_useable_object_on_cell(cell: Vector2i) -> UseableObject:
	return _useable_object_layer.get_object_on_cell(cell)


func get_terrain(cell: Vector2i) -> Terrain:
	return _terrain_layer.get_terrain(cell)

#region Markers

func has_marker(marker_name: StringName) -> bool:
	return _marker_layer.has_marker(marker_name)


func get_marker_cell(marker_name: StringName) -> Vector2i:
	return _marker_layer.get_marker_cell(marker_name)

#endregion Markers

func _clear() -> void:
	_clear_layer(_terrain_layer)
	_clear_layer(_useable_object_layer)
	_clear_layer(_actor_layer)
	_clear_layer(_marker_layer)
	_pathfinder = null


static func _clear_layer(layer: Node) -> void:
	while layer.get_child_count() > 0:
		var c := layer.get_child(0)
		layer.remove_child(c)
		c.free()

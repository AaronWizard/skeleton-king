class_name Map
extends Node2D

@export var terrain_library: TerrainLibrary


var actors: Array[Actor]:
	get:
		return _actor_layer.actors


@onready var _terrain_layer := $TerrainLayer as TerrainLayer
@onready var _actor_layer := $ActorLayer as ActorLayer


func load_map(design_map: MapDesign) -> void:
	for t in design_map.terrain:
		_terrain_layer.add_child(t.duplicate())
	for a in design_map.actors:
		_actor_layer.add_child(a.create_actor())


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_layer.get_actor_on_cell(cell)

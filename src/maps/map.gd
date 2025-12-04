class_name Map
extends Node2D


var actors: Array[Actor]:
	get:
		return _actor_map.actors


@onready var _terrain := $Terrain as Node2D
@onready var _actor_map := $Actors as ActorMap


func load_map(design_map: MapDesign) -> void:
	for t in design_map.terrain:
		_terrain.add_child(t.duplicate())
	for a in design_map.actors:
		_actor_map.add_child(a.create_actor())


func get_actor_on_cell(cell: Vector2i) -> Actor:
	return _actor_map.get_actor_on_cell(cell)

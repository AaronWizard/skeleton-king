extends Node

@export var initial_map_data: PackedScene
@export var player_span_marker: StringName
@export var player_data: ActorData

@onready var _map := $Map as Map


var _player: Actor


func _ready() -> void:
	_init_player()
	_load_map(initial_map_data.instantiate() as MapDesign, player_span_marker)


func _init_player() -> void:
	_player = Actor.create_actor(player_data)


func _load_map(map_data: MapDesign, player_spawn_marker: StringName) -> void:
	_map.load_map(map_data)
	var cell := _map.get_marker_cell(player_spawn_marker)
	_map.add_actor(_player, cell)

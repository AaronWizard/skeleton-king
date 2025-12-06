extends Node

@export var initial_map_data: PackedScene

@onready var _map := $Map as Map


func _ready() -> void:
	var map_data := initial_map_data.instantiate() as MapDesign
	_map.load_map(map_data)

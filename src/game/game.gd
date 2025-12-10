extends Node

@export var initial_map_data: PackedScene
@export var player_span_marker: StringName
@export var player_data: ActorData

@onready var _map := $Map as Map


var _player: Actor
var _turn_clock := TurnClock.new()

@onready var _player_input := $PlayerInput as PlayerInput


func _ready() -> void:
	_init_player()
	_load_map(initial_map_data.instantiate() as MapDesign, player_span_marker)
	_run()


func _init_player() -> void:
	_player = Actor.create_actor(player_data)

	var controller := PlayerController.new()
	_player.set_controller(controller)
	controller.player_input_requested.connect(_on_player_input_requested)

	_player_input.player = _player
	_player_input.controller = controller


func _load_map(map_data: MapDesign, player_spawn_marker: StringName) -> void:
	_map.load_map(map_data)
	var cell := _map.get_marker_cell(player_spawn_marker)
	_map.add_actor(_player, cell)

	var turn_takers: Array[TurnTaker] = []
	turn_takers.assign(
		_map.actors.map(func(actor: Actor): return actor.turn_taker)
	)
	_turn_clock.set_turn_takers(turn_takers)


func _run() -> void:
	while _player.stats.is_alive:
		await _turn_clock.take_turn()


func _on_player_input_requested() -> void:
	_player_input.active = true

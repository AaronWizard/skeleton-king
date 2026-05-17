class_name Game
extends Node

const _PLAYER_NODE_NAME := "Player"

@export var initial_map_data: PackedScene
@export var player_span_marker: StringName
@export var player_data: ActorData


var map: Map:
	get:
		return _map


@onready var _map := $Map as Map


var _player: Actor
var _turn_clock := TurnClock.new()

@onready var _player_input := $PlayerInput as PlayerInput
@onready var _camera := $Camera as BoundedCamera

@onready var _no_player_turn_passer := $NoPlayerTurnPasser as Timer


func _ready() -> void:
	_init_player()
	_load_map(initial_map_data.instantiate() as DesignMap, player_span_marker)
	_run()


func _init_player() -> void:
	_player = Actor.create_actor(player_data)
	_player.name = _PLAYER_NODE_NAME

	var controller := PlayerController.new()
	_player.set_controller(controller)
	controller.player_input_requested.connect(_on_player_input_requested)

	_player_input.player = _player
	_player_input.controller = controller

	_player.remote_transform.remote_path = _camera.get_path()


func _load_map(map_data: DesignMap, player_spawn_marker: StringName) -> void:
	_turn_clock.clear()

	_map.load_map(map_data)
	var cell := _map.get_marker_cell(player_spawn_marker)
	_map.add_actor(_player, cell)

	_camera.bounds = _map.get_pixel_rect()


func _run() -> void:
	while _player.stats.is_alive:
		await _turn_clock.take_turn()
	_no_player_turn_passer.start()


func _on_player_input_requested() -> void:
	_player_input.active = true


func _on_map_actor_added(actor: Actor) -> void:
	_turn_clock.add_turn_taker(actor.turn_taker)


func _on_map_actor_removed(actor: Actor) -> void:
	_turn_clock.remove_turn_taker(actor.turn_taker)


func _on_no_player_turn_passer_timeout() -> void:
	await _turn_clock.take_turn()
	_no_player_turn_passer.start()

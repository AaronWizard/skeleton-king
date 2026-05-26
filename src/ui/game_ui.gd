class_name GameUI
extends Node2D

@onready var _targeting_grid := $TargetingGrid as TargetingGrid
@onready var _player_input := $PlayerInput as PlayerInput


func set_player(player: Actor, controller: ActorController) -> void:
	_player_input.player = player
	_player_input.controller = controller


func set_player_input_active() -> void:
	_player_input.active = true

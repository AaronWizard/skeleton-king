class_name GameUI
extends Node2D

@onready var _targeting_grid := $TargetingGrid as TargetingGrid
@onready var _player_input := $PlayerInput as PlayerInput

var _player: Actor


func set_player(player: Actor, controller: ActorController) -> void:
	_player = player
	_player_input.player = player
	_player_input.controller = controller


func set_player_input_active() -> void:
	_player_input.active = true


func show_target_range(ability: Ability) -> void:
	var target_range := ability.get_target_range(_player, true)
	var target := target_range[0]
	var aoe := ability.get_aoe(target, _player, true)

	var target_rect := Rect2i(target, Vector2i.ONE)
	if ability.target_type == AbilityTargetType.Type.ACTOR:
		var other_actor := _player.map.get_actor_on_cell(target)
		if other_actor:
			target_rect = other_actor.cell_rect

	_targeting_grid.show_targeting(target_rect, target_range, aoe)

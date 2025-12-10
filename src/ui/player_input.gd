class_name PlayerInput
extends Node

var player: Actor
var controller: PlayerController


var active := false:
	get:
		return is_processing_unhandled_input()
	set(value):
		set_process_unhandled_input(value)


func _ready() -> void:
	active = false


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("wait"):
		_end_turn(null)
		return

	var move_vector := Vector2i(
		Vector2(
			Input.get_axis("move_west", "move_east"),
			Input.get_axis("move_north", "move_south")
		).limit_length(1)
	)
	var next_cell := player.origin_cell + move_vector

	var action: TurnAction

	action = _try_move(next_cell)
	if action:
		_end_turn(action)
		return

	action = _try_attack(next_cell)
	if action:
		_end_turn(action)
		return


func _try_move(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	if (next_cell != player.origin_cell) \
			and (player.map.actor_can_enter_cell(player, next_cell)):
		result = MoveAction.new(player, next_cell)
	return result


func _try_attack(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	var other_actor := player.map.get_actor_on_cell(next_cell)
	if other_actor and other_actor.data.faction != player.data.faction:
		result = AttackAction.new(player, other_actor)
	return result


func _end_turn(action: TurnAction) -> void:
	active = false
	controller.send_player_action(action)

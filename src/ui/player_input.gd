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
	var move_vector := Vector2i(
		Vector2(
			Input.get_axis("move_west", "move_east"),
			Input.get_axis("move_north", "move_south")
		).limit_length(1)
	)
	var next_cell := player.origin_cell + move_vector
	if (next_cell != player.origin_cell) \
			and (player.map.actor_can_enter_cell(player, next_cell)):
		active = false
		var action := MoveAction.new(player, next_cell)
		controller.send_player_action(action)

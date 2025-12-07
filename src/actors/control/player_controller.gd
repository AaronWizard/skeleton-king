class_name PlayerController
extends ActorController

signal player_input_requested

signal _player_input_set(action: TurnAction)


func get_turn_action() -> TurnAction:
	player_input_requested.emit()
	var action := await _player_input_set as TurnAction
	return action


func send_player_action(action: TurnAction) -> void:
	_player_input_set.emit(action)

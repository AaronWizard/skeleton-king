class_name TurnTaker
extends Node

signal turn_started
signal turn_ended(action: TurnAction)


var turn_running:
	get:
		return _turn_running


var _turn_running := false


func start_turn() -> void:
	if _turn_running:
		push_error("Turn already running")
		return
	_turn_running = true
	turn_started.emit()


func end_turn(action: TurnAction) -> void:
	if not _turn_running:
		push_error("Turn not running")
		return
	_turn_running = false
	turn_ended.emit(action)

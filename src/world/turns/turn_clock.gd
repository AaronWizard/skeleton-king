class_name TurnClock

var _turn_takers: Array[TurnTaker] = []
var _current_index := 0


func add_turn_taker(turn_taker: TurnTaker) -> void:
	if turn_taker in _turn_takers:
		push_error("TurnTaker already in TurnClock")
		return
	_turn_takers.append(turn_taker)


func remove_turn_taker(turn_taker: TurnTaker) -> void:
	var index := _turn_takers.find(turn_taker)
	if index < 0:
		push_error("TurnTaker not in TurnClock")
		return
	_turn_takers.remove_at(index)
	if index < _current_index:
		_current_index = wrapi(_current_index - 1, 0, _turn_takers.size())


func clear() -> void:
	_turn_takers.clear()
	_current_index = 0


func take_turn() -> bool:
	var turn_taker := _turn_takers[_current_index]

	turn_taker.start_turn.call_deferred()
	var action := await turn_taker.turn_action_chosen as TurnAction

	@warning_ignore("redundant_await")
	var ran_turn := not action or await action.run() or action.wait_if_failed
	if ran_turn:
		_current_index = wrapi(_current_index + 1, 0, _turn_takers.size())

	return ran_turn

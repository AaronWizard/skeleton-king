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


func take_turn() -> void:
	var turn_taker := _turn_takers[_current_index]

	turn_taker.start_turn.call_deferred()
	var action := await turn_taker.turn_ended as TurnAction
	await _run_turn_action(action)

	_current_index = wrapi(_current_index + 1, 0, _turn_takers.size())


func _run_turn_action(action: TurnAction) -> void:
	if action:
		@warning_ignore("redundant_await")
		await action.run()

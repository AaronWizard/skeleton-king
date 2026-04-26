@abstract
class_name TurnAction

## An action a [TurnTaker] does on its turn.

var _alternative: TurnAction = null
var _wait_if_failed := true


## Sets an alternative action if this action fails.[br]
## Returns self for chaining.
func with_alternative(p_alternative: TurnAction) -> TurnAction:
	_alternative = p_alternative
	return self


## Sets whether the turn taker waits if this action fails and there's no
## alternative. Set to true by default.[br]
## Returns self for chaining.
func wait_if_failed(p_wait_if_failed: bool) -> TurnAction:
	_wait_if_failed = p_wait_if_failed
	return self


## Runs the turn action.
func run() -> Result:
	@warning_ignore("redundant_await")
	var succeeded := await _run()
	if succeeded:
		return Result.return_success()
	elif _alternative:
		return Result.return_alternative(_alternative)
	else:
		return Result.return_failure(_wait_if_failed)


## Runs the action, returning whether it succeeded or not.
@abstract func _run() -> bool


## The result of running a [TurnAction].
class Result:
	## True if the turn action successfully ran.
	var succeded: bool:
		get:
			return _succeeded


	## An alternative action to run if the action failed.
	var alternative: TurnAction:
		get:
			return _alternative


	## Make the turn taker wait if the action failed and there is no alternative
	## action.
	var wait_if_failed:
		get:
			return _wait_if_failed


	var _succeeded: bool
	var _alternative: TurnAction
	var _wait_if_failed: bool


	## Return a result representing success.
	static func return_success() -> Result:
		return _make_result(true, null, false)


	## Return a result representing failure. If [param p_wait_if_failed] is true
	## the turn taker's turn is skipped.
	static func return_failure(p_wait_if_failed: bool) -> Result:
		return _make_result(false, null, p_wait_if_failed)


	## Return a result representing failure with an alternative action.
	static func return_alternative(action: TurnAction) -> Result:
		return _make_result(false, action, false)


	static func _make_result(p_succeeded: bool, p_alternative: TurnAction,
			p_wait_if_failed: bool) -> Result:
		var result := Result.new()
		result._succeeded = p_succeeded
		result._alternative = p_alternative
		result._wait_if_failed = p_wait_if_failed
		return result

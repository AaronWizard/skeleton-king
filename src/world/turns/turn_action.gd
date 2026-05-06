@abstract
class_name TurnAction

## An action a [TurnTaker] does on its turn.

## If true, the turn taker should skip its turn if the action fails.
var wait_if_failed := true


## Runs the action, returning whether it succeeded or not.
@abstract func run() -> bool

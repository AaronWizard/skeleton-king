class_name CompositeTurnAction
extends TurnAction

## A [TurnAction] that attempts to run a list a turn actions, stopping at the
## first successful action.

var _sub_actions: Array[TurnAction] = []


func _init(p_sub_actions: Array[TurnAction]) -> void:
	_sub_actions = p_sub_actions


func run() -> bool:
	var result := false
	for subaction in _sub_actions:
		@warning_ignore("redundant_await")
		result = await subaction.run()
		if result:
			break
	return result

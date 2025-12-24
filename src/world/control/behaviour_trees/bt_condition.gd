@abstract
class_name BehaviourTreeCondition
extends Resource

## A condition used in a [BehaviourTreeConditionNode].

## The result of evaluating the condition is inverted if this is true.
@export var invert := false


## Evaluates the condition, using [method _evaluate]. Result is inverted if
## [member invert] is true.
func evaluate(actor: Actor) -> bool:
	var result := _evaluate(actor)
	if invert:
		result = not result
	return result


## Evaluates the condition.
@abstract func _evaluate(actor: Actor) -> bool

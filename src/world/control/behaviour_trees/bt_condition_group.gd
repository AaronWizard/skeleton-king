class_name BehaviourTreeConditionGroup
extends BehaviourTreeCondition

## Evaluates a list of conditions, using either an AND expression or an OR
## expression.

enum Type {
	## The condition group is an AND expression.
	AND,
	## The condition group is an OR expressin.
	OR
}

## The set of conditions that are combined.
@export var conditions: Array[BehaviourTreeCondition]
## How to combine the results of the conditions.
@export var type := Type.AND


func _evaluate(actor: Actor) -> bool:
	if conditions.is_empty():
		push_error("No conditions set")
		return false

	var result := type == Type.AND

	for c in conditions:
		if type == Type.AND:
			result = result and c.evaluate(actor)
			if not result:
				break
		else:
			assert(type == Type.OR)
			result = result or c.evaluate(actor)
			if result:
				break

	return result

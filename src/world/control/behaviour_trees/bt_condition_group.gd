class_name BehaviourTreeConditionGroup
extends BehaviourTreeCondition

## Evaulates a list of conditions, using either an AND experssion or an OR
## expression.

enum Type {
	AND, OR
}

@export var conditions: Array[BehaviourTreeCondition]
@export var type := Type.AND


func _evaulate(actor: Actor) -> bool:
	if conditions.is_empty():
		push_error("No conditions set")
		return false

	var result := type == Type.AND

	for c in conditions:
		if type == Type.AND:
			result = result and c.evaulate(actor)
			if not result:
				break
		else:
			assert(type == Type.OR)
			result = result or c.evaulate(actor)
			if result:
				break

	return result

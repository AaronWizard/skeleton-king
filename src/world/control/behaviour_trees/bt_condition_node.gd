class_name BehaviourTreeConditionNode
extends BehaviourTreeNode

## Runs the child behaviour tree node if the condition passes.

## The condition the child behaviour depends on. The child is only run if this
## returns true.
@export var condition: BehaviourTreeCondition
## The child behaviour that is run if the condition returns true.
@export var child: BehaviourTreeNode


func get_action(actor: Actor) -> TurnAction:
	if not condition:
		push_error("No condition set")
		return null
	if not child:
		push_error("No child set")
		return null

	var result: TurnAction = null
	if condition.evaluate(actor):
		result = child.get_action(actor)
	return result

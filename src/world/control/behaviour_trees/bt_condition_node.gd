class_name BehaviourTreeConditionNode
extends BehaviourTreeNode

## Runs the child if the condition passes.

@export var condition: BehaviourTreeCondition
@export var child: BehaviourTreeNode


func get_action(actor: Actor) -> TurnAction:
	if not condition:
		push_error("No condition set")
		return null
	if not child:
		push_error("No child set")
		return null

	var result: TurnAction = null
	if condition.evaulate(actor):
		result = child.get_action(actor)
	return result

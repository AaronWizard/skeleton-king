class_name BehaviourTreeSelectorNode
extends BehaviourTreeNode

## Run each child in order, stopping at the the first child that returns a
## non-null action.

@export var children: Array[BehaviourTreeNode] = []


func get_action(actor: Actor) -> TurnAction:
	if children.is_empty():
		push_error("No children set")
		return null

	var result: TurnAction = null
	for child in children:
		result = child.get_action(actor)
		if result:
			break
	return result

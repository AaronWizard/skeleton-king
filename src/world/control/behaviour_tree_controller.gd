class_name BehaviourTreeController
extends ActorController

@export var behaviour_tree: BehaviourTreeNode


func get_turn_action() -> TurnAction:
	return behaviour_tree.get_action(actor)

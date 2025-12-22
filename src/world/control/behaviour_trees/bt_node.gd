@abstract
class_name BehaviourTreeNode
extends Resource

## A node in a behaviour tree.

## Gets a turn action for an actor, or null to make the actor do nothing on its
## turn.
@abstract func get_action(actor: Actor) -> TurnAction

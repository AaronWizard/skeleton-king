@abstract
class_name ActorController
extends Node


var actor: Actor:
	set(value):
		if actor == value:
			return
		if actor and actor.is_ancestor_of(self):
			push_error("Cannot change an actor controller's actor while " \
					+ "it's still a child of its current actor")
			return
		if value and not value.is_ancestor_of(self):
			push_error("Cannot change an actor controller's actor to an " \
					+ "actor it is not a child of")
			return

		actor = value


@abstract func get_turn_action() -> TurnAction

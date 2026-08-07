class_name ActorRangeFilter
extends TargetRangeFilter

enum Type {
	ANY, ENEMY, ALLY
}

@export var actor_type := Type.ANY


func cell_in_range(cell: Vector2i, actor: Actor) -> bool:
	var other_actor := actor.map.get_actor_on_cell(cell)

	if not other_actor:
		return false

	match actor_type:
		Type.ENEMY:
			return Actor.are_enemies(actor, other_actor)
		Type.ALLY:
			return not Actor.are_enemies(actor, other_actor)

	return true

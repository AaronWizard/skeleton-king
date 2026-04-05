class_name WorldQueries


static func get_closest_enemy(actor: Actor) -> Actor:
	var result: Actor = null
	var distance := -1.0

	for other_actor in actor.map.actors:
		if Actor.are_enemies(actor, other_actor):
			var new_distance := TileGeometry.manhattan_distance(
					other_actor.origin_cell, actor.origin_cell)
			if not result or (new_distance < distance):
				result = other_actor
				distance = new_distance

	return result

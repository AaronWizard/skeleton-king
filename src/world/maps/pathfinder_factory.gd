class_name PathfinderFactory

static func create_pathfinder(
	terrain_layer: TerrainLayer,
	object_layer: UseableObjectLayer,
	actor_layer: ActorLayer
) -> Pathfinder:
	var result := _create_pathfinder_from_terrain(terrain_layer)
	_fill_objects(result, object_layer)
	_fill_actors(result, actor_layer)
	return result


static func _create_pathfinder_from_terrain(terrain_layer: TerrainLayer) \
		-> Pathfinder:
	var rect := terrain_layer.get_cell_rect()
	var result := Pathfinder.new(rect)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			var terrain := terrain_layer.get_terrain(cell)
			if terrain:
				result.set_cell_solid(Vector2i(x, y), terrain.blocks_move)
	return result


static func _fill_objects(
		pathfinder: Pathfinder, object_layer: UseableObjectLayer) -> void:
	for object in object_layer.objects:
		if object.current_state.blocks_move:
			pathfinder.set_rect_solid(object.cell_rect, true)


static func _fill_actors(pathfinder: Pathfinder, actor_layer: ActorLayer) \
		-> void:
	for actor in actor_layer.actors:
		pathfinder.init_grid_for_actor_size(actor.cell_size)
		pathfinder.set_rect_solid(actor.cell_rect, true)

	actor_layer.actor_added.connect(
		func (actor: Actor) -> void:
			pathfinder.init_grid_for_actor_size(actor.cell_size)
			pathfinder.set_rect_solid(actor.cell_rect, true)
	)
	actor_layer.actor_removed.connect(
		func (actor: Actor) -> void:
			pathfinder.set_rect_solid(actor.cell_rect, false)
	)

	actor_layer.actor_moved.connect(
		func (actor: Actor, old_cell: Vector2i) -> void:
			pathfinder.set_rect_solid(Rect2i(old_cell, actor.cell_size), false)
			pathfinder.set_rect_solid(actor.cell_rect, true)
	)

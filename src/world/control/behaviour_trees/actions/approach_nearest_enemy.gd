class_name ApproachNearestEnemy
extends BehaviourTreeNode

@export var sight_range := 5


func get_action(actor: Actor) -> TurnAction:
	var result: TurnAction = null

	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy:
		var delta := (enemy.origin_cell - actor.origin_cell).abs()
		var dist := delta.x
		if delta.max_axis_index() == Vector2i.Axis.AXIS_Y:
			dist = delta.y
		if dist <= sight_range:
			var path := ActorPathfinder.find_path_to_rect(
					actor, enemy.cell_rect)
			if path.size() > 1:
				result = MoveAction.new(actor, path[1])

	return result

class_name SimpleAIController
extends ActorController

@export var chase_range := 5


func get_turn_action() -> TurnAction:
	var result: TurnAction = null

	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy:
		if TileGeometry.rects_are_adjacent(actor.cell_rect, enemy.cell_rect):
			result = AttackAction.new(self.actor, enemy)
		elif _enemy_in_range(enemy):
			var path := actor.map.find_path(actor, enemy.origin_cell)
			if path.size() > 1:
				result = MoveAction.new(self.actor, path[1])

	return result


func _enemy_in_range(enemy: Actor) -> bool:
	var sight_rect := Rect2i(
		-chase_range, -chase_range,
		chase_range * 2, chase_range * 2
	)
	sight_rect.position += actor.origin_cell
	sight_rect.size += actor.cell_size

	return sight_rect.intersects(enemy.cell_rect)

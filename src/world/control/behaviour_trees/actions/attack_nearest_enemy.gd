class_name AttackNearestEnemy
extends BehaviourTreeNode


func get_action(actor: Actor) -> TurnAction:
	var result: TurnAction = null
	var enemy := ActorQueries.get_closest_enemy(actor)
	if enemy and TileGeometry.rects_are_adjacent(
			actor.cell_rect, enemy.cell_rect):
		result = AttackAction.new(actor, enemy)
	return result

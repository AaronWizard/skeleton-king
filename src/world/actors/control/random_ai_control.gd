class_name RandomAIController
extends ActorController

const _CARDINALS: Array[Vector2i] = [
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
]


func get_turn_action() -> TurnAction:
	var result: TurnAction = null

	var possible_attacks: Array[TurnAction] = []
	var possible_moves: Array[TurnAction] = []

	for dir in _CARDINALS:
		var next_cell := actor.origin_cell + dir

		var attack := _try_attack(next_cell)
		if attack:
			possible_attacks.append(attack)
		else:
			var move := _try_move(next_cell)
			if move:
				possible_moves.append(move)

	if possible_attacks.size() > 0:
		result = possible_attacks.pick_random()
	elif possible_moves.size() > 0:
		result = possible_moves.pick_random()

	return result


func _try_move(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	if (next_cell != actor.origin_cell) \
			and (actor.map.actor_can_enter_cell(actor, next_cell)):
		result = MoveAction.new(actor, next_cell)
	return result


func _try_attack(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	var other_actor := actor.map.get_actor_on_cell(next_cell)
	if other_actor and other_actor.data.faction != actor.data.faction:
		result = AttackAction.new(actor, other_actor)
	return result

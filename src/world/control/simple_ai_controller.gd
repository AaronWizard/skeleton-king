class_name SimpleAIController
extends ActorController

enum _State
{
	IDLE,
	CHASE,
	RETURN
}

const _CHASE_RANGE := 5
const _SEARCH_RANGE := 5
const _SEARCH_TIME := 10

var _initial_cell: Vector2i
var _target_enemy: Actor = null

var _state := _State.IDLE


var _state_transitions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func () -> _State:
			if _see_enemy():
				return _State.CHASE
			else:
				return _State.IDLE,

	_State.CHASE:
		func () -> _State:
			if _see_enemy():
				return _State.CHASE
			elif actor.origin_cell == _initial_cell:
				return _State.IDLE
			else:
				return _State.RETURN,

	_State.RETURN:
		func () -> _State:
			if _see_enemy():
				return _State.CHASE
			elif actor.origin_cell == _initial_cell:
				return _State.IDLE
			else:
				return _State.RETURN
}


var _state_actions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func() -> TurnAction:
			return null,

	_State.CHASE:
		func() -> TurnAction:
			if TileGeometry.rects_are_adjacent(
					actor.cell_rect, _target_enemy.cell_rect):
				return AttackAction.new(actor, _target_enemy)
			else:
				var path := actor.map.find_path(
						actor, _target_enemy.origin_cell)
				if path.size() > 1:
					return MoveAction.new(self.actor, path[1])
			return null,

	_State.RETURN:
		func() -> TurnAction:
			var path := actor.map.find_path(actor, _initial_cell)
			if path.size() > 1:
				return MoveAction.new(self.actor, path[1])
			return null
}


func _ready() -> void:
	_initial_cell = actor.origin_cell


func get_turn_action() -> TurnAction:
	_state = _state_transitions[_state].call()
	return _state_actions[_state].call()


func _see_enemy() -> bool:
	var result := false
	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy and _can_see_actor(enemy, _CHASE_RANGE):
		_target_enemy = enemy
		result = true
	else:
		_target_enemy = null
	return result


func _can_see_actor(other_actor: Actor, sight_range: int) -> bool:
	var sight_rect := Rect2i(
		-sight_range, -sight_range,
		sight_range * 2, sight_range * 2
	)
	sight_rect.position += actor.origin_cell
	sight_rect.size += actor.cell_size

	return sight_rect.intersects(other_actor.cell_rect)

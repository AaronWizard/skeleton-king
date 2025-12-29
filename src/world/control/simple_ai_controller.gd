class_name SimpleAIController
extends ActorController

enum _State
{
	IDLE,
	CHASE,
	SEARCH,
	RETURN
}

const _CHASE_RANGE := 5
const _SEARCH_RANGE := 8
const _MAX_SEARCH_COUNT := 3

var _initial_cell: Vector2i
var _target_enemy: Actor = null

var _target_last_cell: Vector2i
var _search_cell: Vector2i
var _search_count := 0

var _state := _State.IDLE


var _state_transitions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE
			else:
				return _State.IDLE,

	_State.CHASE:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE
			else:
				_search_cell = _target_last_cell
				_search_count = _MAX_SEARCH_COUNT
				return _State.SEARCH,

	_State.SEARCH:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE
			else:
				if _search_cell == actor.origin_cell:
					_search_count -= 1
				if _search_count == 0:
					return _State.RETURN
				else:
					return _State.SEARCH,

	_State.RETURN:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE
			elif actor.origin_cell == _initial_cell:
				return _State.IDLE
			else:
				return _State.RETURN
}


var _state_actions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func () -> TurnAction:
			return null,

	_State.CHASE:
		func () -> TurnAction:
			if TileGeometry.rects_are_adjacent(
					actor.cell_rect, _target_enemy.cell_rect):
				return AttackAction.new(actor, _target_enemy)
			else:
				var path := ActorPathfinder.find_path_to_rect(
						actor, _target_enemy.cell_rect)
				if not path.is_empty():
					return MoveAction.new(self.actor, path[0])
			return null,

	_State.SEARCH:
		func () -> TurnAction:
			if _search_cell == actor.origin_cell:
				return _start_wander(_target_last_cell)
			else:
				return _continue_wander(),

	_State.RETURN:
		func () -> TurnAction:
			var path := ActorPathfinder.find_path_to_cell(actor, _initial_cell)
			if not path.is_empty():
				return MoveAction.new(self.actor, path[0])
			return null
}


func _ready() -> void:
	_initial_cell = actor.origin_cell


func get_turn_action() -> TurnAction:
	_state = _state_transitions[_state].call()
	return _state_actions[_state].call()


func _set_target_enemy() -> void:
	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy and _can_see_actor(enemy):
		_target_enemy = enemy
		_target_last_cell = _target_enemy.origin_cell
	else:
		_target_enemy = null


func _can_see_actor(other_actor: Actor) -> bool:
	var sight_rect := Rect2i(
		-_CHASE_RANGE, -_CHASE_RANGE,
		_CHASE_RANGE * 2, _CHASE_RANGE * 2
	)
	sight_rect.position += actor.origin_cell
	sight_rect.size += actor.cell_size

	return sight_rect.intersects(other_actor.cell_rect)


func _start_wander(center_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null

	var wander_rect := Rect2i(
		-_SEARCH_RANGE, -_SEARCH_RANGE,
		_SEARCH_RANGE * 2, _SEARCH_RANGE * 2
	)
	wander_rect.position += center_cell
	wander_rect.size += actor.cell_size

	var cells := TileGeometry.cells_in_rect(wander_rect)
	cells.erase(actor.origin_cell)
	cells.shuffle()
	while not cells.is_empty():
		var target := cells[-1]
		cells.pop_back()
		if actor.map.actor_can_enter_cell(actor, target):
			var path := ActorPathfinder.find_path_to_cell(actor, target)
			if not path.is_empty():
				_search_cell = target
				result = MoveAction.new(actor, path[0])
				break

	return result


func _continue_wander() -> TurnAction:
	var result: TurnAction = null
	if actor.map.actor_can_enter_cell(actor, _search_cell):
		var path := ActorPathfinder.find_path_to_cell(actor, _search_cell)
		if not path.is_empty():
			result = MoveAction.new(actor, path[0])
	return result

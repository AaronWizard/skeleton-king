class_name AIGuardController
extends ActorController

enum _State
{
	IDLE,
	CHASE,
	SEARCH,
	RETURN
}

const _SIGHT_RANGE := 5
const _SEARCH_RANGE := 5

const _YELL_SENSE_RANGE := 5
const _YELL_SENSE_RANGE_SQUARED := _YELL_SENSE_RANGE * _YELL_SENSE_RANGE

const _MAX_SEARCH_COUNT := 3

const _YELL_EVENT_ID := &"guard_saw_enemy_event"
const _YELL_DATA_ENEMY_LOCATION := &"enemy_location"

var _initial_cell: Vector2i
var _target_enemy: Actor = null

var _target_last_rect: Rect2i
var _search_rect: Rect2i
var _search_count := 0

var _targets_heard_about := PriorityQueue.new()

var _state := _State.IDLE


var _state_transitions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE

			if _process_heared_targets():
				return _State.SEARCH

			return _State.IDLE,

	_State.CHASE:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE

			_search_rect = _target_last_rect
			_search_count = _MAX_SEARCH_COUNT
			return _State.SEARCH,

	_State.SEARCH:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE

			if _process_heared_targets():
				return _State.SEARCH

			if actor.cell_rect.intersects(_search_rect):
				_search_count -= 1
			if _search_count == 0:
				return _State.RETURN

			return _State.SEARCH,

	_State.RETURN:
		func () -> _State:
			_set_target_enemy()
			if _target_enemy:
				return _State.CHASE

			if _process_heared_targets():
				return _State.SEARCH

			if actor.origin_cell == _initial_cell:
				return _State.IDLE

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
				return _head_to_rect(_target_enemy.cell_rect),

	_State.SEARCH:
		func () -> TurnAction:
			if actor.cell_rect.intersects(_search_rect):
				return _pick_new_search_rect(_target_last_rect.position)
			else:
				var head_action := _head_to_rect(_search_rect)
				if not head_action:
					print(actor.name, " failed to head towards ", _search_rect)
				return head_action,

	_State.RETURN:
		func () -> TurnAction:
			var path := ActorPathfinder.find_path_to_cell(actor, _initial_cell)
			if not path.is_empty():
				return MoveAction.new(self.actor, path[0])
			return null
}


func _ready() -> void:
	_initial_cell = actor.origin_cell
	actor.map_changed.connect(_on_map_changed)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)


func get_turn_action() -> TurnAction:
	_state = _state_transitions[_state].call()
	return _state_actions[_state].call()


func _set_target_enemy() -> void:
	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy and _can_see_actor(enemy):
		_target_enemy = enemy
		_target_last_rect = _target_enemy.cell_rect
		_yell_for_help(_target_last_rect)
	else:
		_target_enemy = null


func _can_see_actor(other_actor: Actor) -> bool:
	var sight_rect := Rect2i(
		-_SIGHT_RANGE, -_SIGHT_RANGE,
		_SIGHT_RANGE * 2, _SIGHT_RANGE * 2
	)
	sight_rect.position += actor.origin_cell
	sight_rect.size += actor.cell_size

	return sight_rect.intersects(other_actor.cell_rect)


func _pick_new_search_rect(center_cell: Vector2i) -> TurnAction:
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
		if actor.map.actor_can_enter_cell(actor, target, true):
			var path := ActorPathfinder.find_path_to_cell(actor, target)
			if not path.is_empty():
				_search_rect = Rect2i(target, Vector2i.ONE)
				result = MoveAction.new(actor, path[0])
				break

	if not result:
		print(actor.name, " failed to pick new search rect")

	return result


func _head_to_rect(rect: Rect2i) -> TurnAction:
	var result: TurnAction = null
	var path := ActorPathfinder.find_path_to_rect(actor, rect)
	if not path.is_empty():
		result = MoveAction.new(actor, path[0])
	return result


func _yell_for_help(enemy_rect: Rect2i) -> void:
	print(actor.name, " yelled about enemy at ", enemy_rect)
	actor.map.events.send_custom_event(
		_YELL_EVENT_ID,
		actor.cell_rect,
		{_YELL_DATA_ENEMY_LOCATION: enemy_rect}
	)


func _process_heared_targets() -> bool:
	if _targets_heard_about.is_empty():
		return false

	var target := _targets_heard_about.pop() as Rect2i
	_targets_heard_about.clear()
	_search_rect = target

	if _search_count == 0:
		_search_count = 1

	print(actor.name, " heared about enemy at ", _search_rect)

	return true


func _on_map_changed(old_map: Map) -> void:
	if old_map:
		old_map.events.custom_event_sent.disconnect(_on_map_custom_event_sent)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)


func _on_map_custom_event_sent(event: MapEvents.CustomEvent) -> void:
	if event.id != _YELL_EVENT_ID:
		return
	if TileGeometry.rect_distance_squared(actor.cell_rect, event.source_rect) \
			> _YELL_SENSE_RANGE_SQUARED:
		return

	var enemy_rect := event.data[_YELL_DATA_ENEMY_LOCATION] as Rect2i
	var dist_sqrd := TileGeometry.rect_distance_squared(
			actor.cell_rect, enemy_rect)

	_targets_heard_about.push(enemy_rect, dist_sqrd)

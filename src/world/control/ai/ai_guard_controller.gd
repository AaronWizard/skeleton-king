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

const _MAX_SEARCH_COUNT := 2

const _YELL_EVENT_ID := &"guard_saw_enemy_event"
const _YELL_DATA_ENEMY_LOCATION := &"enemy_location"
const _YELL_DATA_SOURCE_ACTOR := &"source_actor"

var _initial_cell: Vector2i
var _target_enemy: Actor = null

var _target_last_rect: Rect2i
var _search_rect: Rect2i
var _search_count := 0

var _closest_alert_target: Rect2i
var _closest_alert_target_dist_sqr := -1.0

var _state := _State.IDLE


var _state_transitions: Dictionary[_State, Callable] = {
	_State.IDLE:
		func () -> _State:
			if _target_enemy:
				_yell_for_help(_target_last_rect)
				return _State.CHASE

			if _process_alert_target():
				return _State.SEARCH

			return _State.IDLE,

	_State.CHASE:
		func () -> _State:
			if _target_enemy:
				return _State.CHASE

			_search_rect = _target_last_rect
			_search_count = _MAX_SEARCH_COUNT
			return _State.SEARCH,

	_State.SEARCH:
		func () -> _State:
			if _target_enemy:
				_yell_for_help(_target_last_rect)
				return _State.CHASE

			if _process_alert_target():
				return _State.SEARCH

			if actor.cell_rect.intersects(_search_rect):
				_search_count -= 1
			if _search_count == 0:
				return _State.RETURN

			return _State.SEARCH,

	_State.RETURN:
		func () -> _State:
			if _target_enemy:
				_yell_for_help(_target_last_rect)
				return _State.CHASE

			if _process_alert_target():
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
				@warning_ignore("integer_division")
				return _pick_new_search_rect(
					_target_last_rect.position + (_target_last_rect.size / 2)
				)
			else:
				return _head_to_rect(_search_rect),

	_State.RETURN:
		func () -> TurnAction:
			var path := ActorPathfinder.find_path_to_cell(actor, _initial_cell, false)
			if not path.is_empty():
				return MoveAction.new(actor, path[0])
			return null
}


func _ready() -> void:
	_initial_cell = actor.origin_cell
	actor.map_changed.connect(_on_map_changed)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)


func get_turn_action() -> TurnAction:
	_check_for_enemy()
	_state = _state_transitions[_state].call()
	return _state_actions[_state].call()


func _check_for_enemy() -> void:
	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy and _can_see_actor(enemy):
		_target_enemy = enemy
		_target_last_rect = _target_enemy.cell_rect
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
	for target in cells:
		if actor.map.actor_can_enter_cell(actor, target, true):
			var path := ActorPathfinder.find_path_to_cell(actor, target, true)
			if not path.is_empty():
				_search_rect = Rect2i(target, Vector2i.ONE)
				result = MoveAction.new(actor, path[0])
				break

	return result


func _head_to_rect(rect: Rect2i) -> TurnAction:
	var result: TurnAction = null
	var path := ActorPathfinder.find_path_to_rect(actor, rect, false)
	if not path.is_empty():
		result = MoveAction.new(actor, path[0])
	return result


func _yell_for_help(enemy_rect: Rect2i) -> void:
	actor.map.events.send_custom_event(
		_YELL_EVENT_ID,
		actor.cell_rect,
		{
			_YELL_DATA_ENEMY_LOCATION: enemy_rect,
			_YELL_DATA_SOURCE_ACTOR: actor
		}
	)


func _process_alert_target() -> bool:
	if _closest_alert_target_dist_sqr < 0:
		return false

	_search_rect = _closest_alert_target

	_closest_alert_target = Rect2i()
	_closest_alert_target_dist_sqr = -1.0

	if _search_count == 0:
		_search_count = 1

	return true


func _on_map_changed(old_map: Map) -> void:
	if old_map:
		old_map.events.custom_event_sent.disconnect(_on_map_custom_event_sent)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)


func _on_map_custom_event_sent(event: MapEvents.CustomEvent) -> void:
	if event.id != _YELL_EVENT_ID:
		return
	if _state == _State.CHASE:
		return

	if (event.data[_YELL_DATA_SOURCE_ACTOR] as Actor) == actor:
		return

	if TileGeometry.rect_distance_squared(actor.cell_rect, event.source_rect) \
			> _YELL_SENSE_RANGE_SQUARED:
		return

	var enemy_rect := event.data[_YELL_DATA_ENEMY_LOCATION] as Rect2i
	var dist_sqrd := TileGeometry.rect_distance_squared(
			actor.cell_rect, enemy_rect)

	if (_closest_alert_target_dist_sqr < 0) \
			or (dist_sqrd < _closest_alert_target_dist_sqr):
		_closest_alert_target = enemy_rect
		_closest_alert_target_dist_sqr = dist_sqrd

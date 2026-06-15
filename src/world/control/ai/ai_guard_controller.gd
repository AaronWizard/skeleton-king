class_name AIGuardController
extends ActorController

enum _State
{
	IDLE,
	CHASE,
	INVESTIGATE,
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

#region State Data

var _initial_cell: Vector2i

var _target_enemy: Actor = null

var _investigate_target: Rect2i

var _search_cell: Vector2i
var _search_count := 0

var _closest_alert_target: Rect2i
var _closest_alert_target_dist_sqr := -1.0

#endregion State Data

#region State Structure

var _state_transitions: Dictionary[_State, Callable] = {
	_State.IDLE: _state_check_idle,
	_State.CHASE: _state_check_chase,
	_State.INVESTIGATE: _state_check_investigate,
	_State.SEARCH: _state_check_search,
	_State.RETURN: _state_check_return
}

var _state_actions: Dictionary[_State, Callable] = {
	_State.IDLE: _state_action_idle,
	_State.CHASE: _state_action_chase,
	_State.INVESTIGATE: _state_action_investigate,
	_State.SEARCH: _state_action_search,
	_State.RETURN: _state_action_return
}

#endregion State Structure

var _state := _State.IDLE


func _ready() -> void:
	_initial_cell = actor.origin_cell
	actor.map_changed.connect(_on_map_changed)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)


func get_turn_action() -> TurnAction:
	var old_state := _state
	_state = _state_transitions[_state].call()
	if old_state != _state:
		Log.print(
			"%s's state is now %s" % [actor.name, _State.keys()[_state]],
			Color.SPRING_GREEN
		)
	return _state_actions[_state].call()


#region State Checks

func _state_check_idle() -> _State:
	_track_enemy()
	if _target_enemy:
		_yell_for_help(_investigate_target)
		return _State.CHASE

	if _update_investigate_target_from_alert():
		return _State.INVESTIGATE

	return _State.IDLE


func _state_check_chase() -> _State:
	_track_enemy()
	if _target_enemy:
		return _State.CHASE
	else:
		_search_count = _MAX_SEARCH_COUNT
		return _State.INVESTIGATE


func _state_check_investigate() -> _State:
	_track_enemy()
	if _target_enemy:
		_yell_for_help(_investigate_target)
		return _State.CHASE

	# Investigate closer target when alerted about one
	_update_investigate_target_from_alert()

	var ally_at_target := func (other_actor: Actor) -> bool:
		return (actor != other_actor) \
				and not Actor.are_enemies(actor, other_actor)

	if actor.cell_rect.intersects(_investigate_target) \
			or ( \
				_can_see_rect(_investigate_target) \
				and actor.map.get_actors_in_rect(_investigate_target).any( \
					ally_at_target \
				) \
			):
		if _pick_new_search_cell():
			return _State.SEARCH
		else:
			_search_count = 0
			return _State.RETURN

	return _State.INVESTIGATE


func _state_check_search() -> _State:
	_track_enemy()
	if _target_enemy:
		_yell_for_help(_investigate_target)
		return _State.CHASE

	if _update_investigate_target_from_alert():
		return _State.INVESTIGATE

	if actor.origin_cell == _search_cell:
		_search_count -= 1
		if (_search_count == 0) or not _pick_new_search_cell():
			_search_count = 0
			return _State.RETURN

	return _State.SEARCH


func _state_check_return() -> _State:
	_track_enemy()
	if _target_enemy:
		_yell_for_help(_investigate_target)
		return _State.CHASE

	if _update_investigate_target_from_alert():
		return _State.INVESTIGATE

	if actor.origin_cell == _initial_cell:
		return _State.IDLE
	else:
		return _State.RETURN

#endregion State Checks

#region State Actions

func _state_action_idle() -> TurnAction:
	return null


func _state_action_chase() -> TurnAction:
	if actor.abilities.can_attack(_target_enemy.origin_cell):
		Log.print(
			'%s attacking %s' % [actor.name, _target_enemy.name], Color.GREEN
		)
		return actor.abilities.create_attack_action(_target_enemy.origin_cell)
	else:
		return _head_to_rect(_target_enemy.cell_rect)


func _state_action_investigate() -> TurnAction:
	return _head_to_rect(_investigate_target)


func _state_action_search() -> TurnAction:
	return _head_to_cell(_search_cell)


func _state_action_return() -> TurnAction:
	return _head_to_cell(_initial_cell)


#endregion State Actions


func _track_enemy() -> void:
	var enemy := WorldQueries.get_closest_enemy(actor)
	if enemy and _can_see_actor(enemy):
		_target_enemy = enemy
		_investigate_target = _target_enemy.cell_rect
	else:
		_target_enemy = null


func _can_see_actor(other_actor: Actor) -> bool:
	return _can_see_rect(other_actor.cell_rect)


func _can_see_rect(rect: Rect2i) -> bool:
	var sight_rect := Rect2i(
		-_SIGHT_RANGE, -_SIGHT_RANGE,
		_SIGHT_RANGE * 2, _SIGHT_RANGE * 2
	)
	sight_rect.position += actor.origin_cell
	sight_rect.size += actor.cell_size

	return sight_rect.intersects(rect)


func _pick_new_search_cell() -> bool:
	var result := false

	var wander_rect := Rect2i(
		-_SEARCH_RANGE, -_SEARCH_RANGE,
		_SEARCH_RANGE * 2, _SEARCH_RANGE * 2
	)

	@warning_ignore("integer_division")
	wander_rect.position += \
			_investigate_target.position + (_investigate_target.size / 2)
	wander_rect.size += actor.cell_size

	var cells := TileGeometry.cells_in_rect(wander_rect)
	cells.erase(actor.origin_cell)
	cells.shuffle()
	for target in cells:
		if actor.map.actor_can_enter_cell(actor, target, true):
			var path := ActorPathfinder.find_path_to_cell(actor, target, true)
			if not path.is_empty():
				_search_cell = target
				result = true
				break

	return result


func _head_to_rect(rect: Rect2i) -> TurnAction:
	var result: TurnAction = null
	var path := ActorPathfinder.find_path_to_rect(actor, rect, false)
	if not path.is_empty():
		Log.print(
			'%s moving from %.v to %.v'
				% [actor.name, actor.origin_cell, path[0]],
			Color.SKY_BLUE
		)
		result = MoveAction.new(actor, path[0])
	return result


func _head_to_cell(cell: Vector2i) -> TurnAction:
	var path := ActorPathfinder.find_path_to_cell(actor, cell, false)
	if not path.is_empty():
		Log.print(
			'%s moving from %.v to %.v'
				% [actor.name, actor.origin_cell, path[0]],
			Color.SKY_BLUE
		)
		return MoveAction.new(actor, path[0])
	return null


func _yell_for_help(enemy_rect: Rect2i) -> void:
	actor.map.events.send_custom_event(
		_YELL_EVENT_ID,
		actor.cell_rect,
		{
			_YELL_DATA_ENEMY_LOCATION: enemy_rect,
			_YELL_DATA_SOURCE_ACTOR: actor
		}
	)


func _update_investigate_target_from_alert() -> bool:
	if _closest_alert_target_dist_sqr < 0:
		# We've not been alerted
		return false

	if _state == _State.INVESTIGATE:
		var curr_invst_rect_dist_sqr := TileGeometry.rect_distance_squared(
				actor.cell_rect, _investigate_target)
		if _closest_alert_target_dist_sqr > curr_invst_rect_dist_sqr:
			# Alert target farther than what we're already investigating
			return false

	_investigate_target = _closest_alert_target

	# Reset closest alert tracking
	_closest_alert_target = Rect2i()
	_closest_alert_target_dist_sqr = -1.0

	# Alerted about rect to investigate
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

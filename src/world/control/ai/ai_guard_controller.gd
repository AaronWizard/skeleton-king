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

var _pending_yell_target := Rect2i()
var _has_pending_yell := false
var _yell_accepted := false

#endregion State Data

var _use_object_action_factory: UseObjectActionFactory = null
var _state := _State.IDLE


func _ready() -> void:
	actor.map_changed.connect(_on_map_changed)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)
	_use_object_action_factory = UseObjectActionFactory.new(actor)
	_init_data()


func get_turn_action() -> TurnAction:
	_observe()
	var next_state := _get_next_state()
	_set_state(next_state)
	return _get_turn_action()


func _observe() -> void:
	_yell_accepted = false
	_track_enemy()
	if _target_enemy:
		return
	if _has_pending_yell:
		_consume_yell()
	elif (_state == _State.SEARCH) and (actor.origin_cell == _search_cell):
		_search_count -= 1
		if _search_count > 0 and not _pick_new_search_cell():
			_search_count = 0


func _get_next_state() -> _State:
	if _target_enemy:
		return _State.CHASE
	if _yell_accepted:
		return _State.INVESTIGATE

	match _state:
		_State.CHASE:
			assert(not _target_enemy)
			return _State.INVESTIGATE
		_State.INVESTIGATE:
			if _has_reached_investigate_target():
				return _State.SEARCH
		_State.SEARCH:
			if _search_count <= 0:
				return _State.RETURN
		_State.RETURN:
			if actor.origin_cell == _initial_cell:
				return _State.IDLE

	return _state


func _set_state(new_state: _State) -> void:
	if new_state == _state:
		return
	var old_state := _state
	_state = new_state
	Log.print(
		"%s: %s -> %s" % [
			actor.name, _State.keys()[old_state], _State.keys()[new_state]
		],
		Color.SPRING_GREEN
	)
	match new_state:
		_State.CHASE:
			_clear_pending_yell()
			_yell_for_help(_target_enemy.cell_rect)
		_State.SEARCH:
			_search_count = _MAX_SEARCH_COUNT
			if not _pick_new_search_cell():
				_set_state(_State.RETURN)


func _get_turn_action() -> TurnAction:
	match _state:
		_State.IDLE:
			return null
		_State.CHASE:
			return _chase_or_attack()
		_State.INVESTIGATE:
			return _head_to_rect(_investigate_target)
		_State.SEARCH:
			return _head_to_cell(_search_cell)
		_State.RETURN:
			return _head_to_cell(_initial_cell)
		_:
			push_error("Invalid state: %d" % _state)
			return null


func _init_data() -> void:
	_state = _State.IDLE

	_initial_cell = actor.origin_cell

	_target_enemy = null
	_investigate_target = Rect2i()

	_search_cell = Vector2i.ZERO
	_search_count = 0

	_clear_pending_yell()
	_yell_accepted = false


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


func _chase_or_attack() -> TurnAction:
	if actor.abilities.can_attack(_target_enemy.origin_cell):
		Log.print(
			'%s attacking %s' % [actor.name, _target_enemy.name], Color.GREEN
		)
		return actor.abilities.create_attack_action(_target_enemy.origin_cell)
	else:
		return _head_to_rect(_target_enemy.cell_rect)


func _has_reached_investigate_target() -> bool:
	if actor.cell_rect.intersects(_investigate_target):
		return true
	# Check if a visible ally is at _investigate_target
	return _can_see_rect(_investigate_target) \
			and actor.map.get_actors_in_rect(_investigate_target).any(
				func (other_actor: Actor) -> bool:
					return (actor != other_actor) \
						and not Actor.are_enemies(actor, other_actor) \
			)


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
		if actor.map.actor_can_enter_cell(actor, target, true, true):
			var path := ActorPathfinder.find_path_to_cell(actor, target, true)
			if not path.is_empty():
				_search_cell = target
				result = true
				break
			else:
				Log.print(
					"%s failed to find path to %.v" % [actor.name, target],
					Color.DARK_ORANGE
				)

	return result


func _head_to_rect(rect: Rect2i) -> TurnAction:
	var path := ActorPathfinder.find_path_to_rect(actor, rect, false)
	if not path.is_empty():
		Log.print(
			'%s moving from %.v to %.v'
				% [actor.name, actor.origin_cell, path[0]],
			Color.SKY_BLUE
		)
		return _create_move_action(path[0])
	else:
		Log.print(
			"%s failed to find path to %s" % [actor.name, rect],
			Color.DARK_ORANGE
		)
	return null


func _head_to_cell(cell: Vector2i) -> TurnAction:
	var path := ActorPathfinder.find_path_to_cell(actor, cell, false)
	if not path.is_empty():
		Log.print(
			'%s moving from %.v to %.v'
				% [actor.name, actor.origin_cell, path[0]],
			Color.SKY_BLUE
		)
		return _create_move_action(path[0])
	else:
		Log.print(
			"%s failed to find path to %.v" % [actor.name, cell],
			Color.DARK_ORANGE
		)
	return null


func _yell_for_help(enemy_rect: Rect2i) -> void:
	Log.print("%s yelling about enemy at %s" % [actor.name, enemy_rect],
			Color.GOLD)
	actor.map.events.send_custom_event(
		_YELL_EVENT_ID,
		actor.cell_rect,
		{
			_YELL_DATA_ENEMY_LOCATION: enemy_rect,
			_YELL_DATA_SOURCE_ACTOR: actor
		}
	)


func _consume_yell() -> void:
	var yell_target := _pending_yell_target
	_clear_pending_yell()
	if (_state == _State.INVESTIGATE) and (
			_dist_sqr_to_actor(yell_target)
				> _dist_sqr_to_actor(_investigate_target)
	):
		# Already investigating something closer.
		return
	_investigate_target = yell_target
	_yell_accepted = true
	Log.print("%s will investigate yell targeting %s" \
			% [actor.name, _investigate_target], Color.GOLD)


func _clear_pending_yell() -> void:
	_pending_yell_target = Rect2i()
	_has_pending_yell = false


func _create_move_action(next_cell: Vector2i) -> TurnAction:
	var actions: Array[TurnAction] = [ MoveAction.new(actor, next_cell) ]

	var edge_cells := TileGeometry.adjacent_edge_cells(
		actor.cell_rect,
		Directions.dir_to_cardinal(next_cell - actor.origin_cell)
	)
	for cell in edge_cells:
		actions.append(_use_object_action_factory.create_action(cell))

	return CompositeTurnAction.new(actions)


func _on_map_changed(old_map: Map) -> void:
	if old_map:
		old_map.events.custom_event_sent.disconnect(_on_map_custom_event_sent)
	if actor.map:
		actor.map.events.custom_event_sent.connect(_on_map_custom_event_sent)

	_init_data()


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
	if not _has_pending_yell or (
			_dist_sqr_to_actor(enemy_rect)
				< _dist_sqr_to_actor(_pending_yell_target)
	):
		_pending_yell_target = enemy_rect
		_has_pending_yell = true


func _dist_sqr_to_actor(rect: Rect2i) -> float:
	return TileGeometry.rect_distance_squared(actor.cell_rect, rect)

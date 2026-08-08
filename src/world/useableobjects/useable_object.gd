@icon("uid://c5ymkqiptishk")
@tool
class_name UseableObject
extends RectTileObject

const _USEABLE_TILE_SCENE := preload("uid://bj40j07ghclgb")


@export var data: UseableObjectData:
	set(value):
		data = value
		if data:
			cell_dimensions = data.size
		else:
			cell_dimensions = Vector2i.ONE
		state_index = 0


@export var state_index := 0:
	set(value):
		if data:
			state_index = wrapi(value, 0, data.states.size())
		else:
			state_index = 0

		if not is_node_ready():
			await ready
		if current_state:
			_sprite.texture = current_state.sprite
		else:
			_sprite.texture = null


var current_state: UseableObjectState:
	get:
		var result: UseableObjectState = null
		if data and not data.states.is_empty():
			result = data.states[state_index]
		return result


@onready var _sprite := $Sprite as Sprite2D

var _map_tracker := ParentMapTracker.new(self)


static func create_useable_object(p_data: UseableObjectData, initial_state: int) \
		-> UseableObject:
	var object := _USEABLE_TILE_SCENE.instantiate() as UseableObject
	object.data = p_data
	object.state_index = initial_state
	return object


func set_map(map: Map) -> void:
	_map_tracker.set_map(map)


func can_use() -> bool:
	if not data or not data.states or data.states.is_empty():
		return false

	var result := true

	var next_index := wrapi(state_index + 1, 0, data.states.size())
	var next_state := data.states[next_index]

	if next_state.blocks_move and _map_tracker.get_map():
		var actors := _map_tracker.get_map().get_actors_in_rect(cell_rect)
		result = actors.is_empty()

	return result


## Get how many times object has to be used before it doesn't block movement.
## [br]
## Returns 0 if the object is already unblocked.
## [br]
## Returns -1 if the object can never be unblocked.
func use_count_until_move_unblocked() -> int:
	if not current_state.blocks_move:
		return 0
	var count := 0
	var index := wrapi(state_index + 1, 0, data.states.size())
	while index != state_index:
		count += 1
		if not data.states[index].blocks_move:
			break
		index = wrapi(index + 1, 0, data.states.size())

	if index == state_index:
		return -1
	else:
		return count


func use() -> bool:
	var result := false
	if can_use():
		state_index += 1
		result = true
	return result


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre


func _cell_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

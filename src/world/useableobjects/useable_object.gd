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


static func create_useable_object(p_data: UseableObjectData, initial_state: int) \
		-> UseableObject:
	var object := _USEABLE_TILE_SCENE.instantiate() as UseableObject
	object.data = p_data
	object.state_index = initial_state
	return object


func use() -> void:
	state_index += 1


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre


func _cell_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

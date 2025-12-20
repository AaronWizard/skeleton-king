@icon("uid://c5ymkqiptishk")
@tool
class_name DesignUseableObject
extends RectTileObject


@export var data: UseableObjectData:
	set(value):
		data = value

		if not Engine.is_editor_hint():
			return

		if data:
			cell_dimensions = data.size
		else:
			cell_dimensions = Vector2i.ONE
		state_index = 0


@export_range(0, 1, 1, "or_greater") var state_index := 0:
	set(value):
		if data:
			state_index = wrapi(value, 0, data.states.size())
		else:
			state_index = 0

		if not is_node_ready():
			await ready
		if data and not data.states.is_empty():
			_sprite.texture = data.states[state_index].sprite
		else:
			_sprite.texture = null


var _sprite: Sprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		_sprite = Sprite2D.new()
		_sprite.position = pixel_centre
		add_child(_sprite)
		move_child(_sprite, 0)


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	if not data:
		result.append("No UseableObjectData")
	return result


func _tile_size_changed() -> void:
	_position_sprite()


func _cell_size_changed() -> void:
	_position_sprite()


func create_useable_object() -> UseableObject:
	var object := UseableObject.create_useable_object(data, state_index)
	object.name = name
	object.tile_size = tile_size
	object.origin_cell = origin_cell
	return object


func _position_sprite() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

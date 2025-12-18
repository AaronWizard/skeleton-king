@tool
class_name UseableTile
extends TileObject


@export var data: UseableTileData:
	set(value):
		data = value
		state_index = 0 # Calls _init_current_state()


@export_range(0, 1, 1, "or_greater") var state_index := 0:
	set(value):
		state_index = wrapi(value, 0, data.state_count)
		_init_current_state()


var current_state: UseableTileState:
	get:
		var result: UseableTileState = null
		if data.state_count > 0:
			result = data.states[state_index]
		return result


@onready var _sprite := $Sprite as Sprite2D


func use() -> void:
	state_index += 1


func _init_current_state() -> void:
	if not is_node_ready():
		await ready

	_sprite.texture = null
	if current_state:
		_sprite.texture = current_state.sprite


func _tile_size_changed() -> void:
	_sprite.position = pixel_centre

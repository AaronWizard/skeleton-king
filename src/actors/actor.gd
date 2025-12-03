@tool
class_name Actor
extends TileObject


@export var data: ActorData:
	set(value):
		data = value
		if not is_node_ready():
			await ready
		_init_data()


var _stamina := Stamina.new()

@onready var _sprite := $Sprite as Sprite2D


func _init_data() -> void:
	_sprite.texture = null
	if data:
		_sprite.texture = data.sprite
		_stamina.init(data.stamina)


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

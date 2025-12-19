@tool
class_name DesignActor
extends SquareTileObject

## A design version of an actor for placing in [DesignMap] scenes while creating
## levels.


@export var data: ActorData:
	set(value):
		data = value

		if not Engine.is_editor_hint():
			return
		if not is_node_ready():
			await ready

		if data:
			cell_length = data.size
			_sprite.texture = data.sprite
		else:
			cell_length = 1
			_sprite.texture = null


@export var controller_scene: PackedScene

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
		result.append("No ActorData")
	return result


func create_actor() -> Actor:
	var actor := Actor.create_actor(data)
	actor.tile_size = tile_size
	actor.origin_cell = origin_cell

	if controller_scene:
		var controller := controller_scene.instantiate() as ActorController
		actor.set_controller(controller)

	return actor


func _tile_size_changed() -> void:
	_position_sprite()


func _cell_size_changed() -> void:
	_position_sprite()


func _position_sprite() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

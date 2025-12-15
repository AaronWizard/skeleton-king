@tool
class_name ActorDesign
extends TileObject

## A design version of an actor for placing in [MapDesign] scenes while creating
## levels.

const _SPRITE_NAME := "Sprite"


@export var data: ActorData:
	set(value):
		if data:
			data.changed.disconnect(_update_sprite)

		data = value
		_update_sprite()

		if data:
			data.changed.connect(_update_sprite)


@export var controller_scene: PackedScene


var _sprite: Sprite2D


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	if (get_child_count() == 0) or (get_child(0) is not Sprite2D):
		result.append("No Sprite2D node")
	if not data:
		result.append("No ActorData")
	return result


func _ready() -> void:
	if get_child_count(true) > 0:
		var sprite := get_child(0, true) as Sprite2D
		if sprite:
			_sprite = sprite

	if not _sprite:
		_init_sprite()


func create_actor() -> Actor:
	var actor := Actor.create_actor(data)
	actor.tile_size = tile_size
	actor.origin_cell = origin_cell

	if controller_scene:
		var controller := controller_scene.instantiate() as ActorController
		actor.set_controller(controller)

	return actor


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre


func _init_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = _SPRITE_NAME
	_sprite.position = pixel_centre
	add_child(_sprite)
	_sprite.owner = self
	move_child(_sprite, 0)

	if data:
		_sprite.texture = data.sprite


func _update_sprite() -> void:
	if not is_node_ready():
		await ready
	_sprite.texture = null
	if data:
		_sprite.texture = data.sprite

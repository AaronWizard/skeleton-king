@tool
class_name ActorDesign
extends TileObject

## A design version of an actor for placing in [MapDesign] scenes while creating
## levels.

@export var data: ActorData:
	set(value):
		data = value
		if not is_node_ready():
			await ready

		_sprite.texture = null
		if data:
			_sprite.texture = data.sprite


@export var controller_scene: PackedScene


var _sprite: Sprite2D


func _ready() -> void:
	if get_child_count(true) > 0:
		var sprite := get_child(0, true) as Sprite2D
		if sprite:
			_sprite = sprite

	if not _sprite:
		_sprite = Sprite2D.new()
		_sprite.position = pixel_centre
		add_child(_sprite, false, Node.INTERNAL_MODE_FRONT)
		_sprite.owner = self
		move_child(_sprite, 0)


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

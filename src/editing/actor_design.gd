@tool
class_name ActorDesign
extends TileObject

## A design version of an actor for placing in [MapDesign] scenes while creating
## levels.

const _ACTOR_SCENE := preload("uid://bcifsfm6gsylc")


@export var data: ActorData:
	set(value):
		data = value
		if not is_node_ready():
			await ready

		_sprite.texture = null
		if data:
			_sprite.texture = data.sprite


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


func construct_actor() -> Actor:
	var actor := _ACTOR_SCENE.instantiate() as Actor
	actor.data = data
	return actor


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre

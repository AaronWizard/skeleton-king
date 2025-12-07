@tool
class_name Actor
extends TileObject

const _ACTOR_SCENE := preload("uid://bcifsfm6gsylc")


@export var data: ActorData:
	set(value):
		data = value
		if not is_node_ready():
			await ready
		_init_data()


var turn_taker: TurnTaker:
	get:
		return $TurnTaker as TurnTaker


var stamina: Stamina:
	get:
		return _stamina


var _stamina := Stamina.new()

var _controller: ActorController

@onready var _sprite := $Sprite as Sprite2D


static func create_actor(p_data: ActorData) -> Actor:
	var actor := _ACTOR_SCENE.instantiate() as Actor
	actor.data = p_data
	return actor


func _ready() -> void:
	if not Engine.is_editor_hint():
		pass


func set_controller(controller: ActorController) -> void:
	if _controller == controller:
		return

	if _controller:
		remove_child(_controller)
		_controller.actor = null
		_controller = null

	_controller = controller

	if _controller:
		add_child(_controller)
		_controller.actor = self


func _init_data() -> void:
	_sprite.texture = null
	if data:
		_sprite.texture = data.sprite
		_stamina.init(data.stamina)


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre


func _on_turn_taker_turn_started() -> void:
	var action: TurnAction = null

	if _controller:
		@warning_ignore("redundant_await")
		action = await _controller.get_turn_action()

	turn_taker.end_turn(action)

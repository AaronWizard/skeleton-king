@tool
class_name Actor
extends TileObject

const _ACTOR_SCENE := preload("uid://bcifsfm6gsylc")


@export var data: ActorData:
	set(value):
		data = value
		_init_data()


var map: Map:
	set(value):
		if map == value:
			return

		if map and map.is_ancestor_of(self):
			push_error("Cannot change an actor's map while it is still a " \
					+ "child of its current map")
			return
		if value and not value.is_ancestor_of(self):
			push_error("Cannot change an actor's map to a map it is not a " \
					+ "child of")
			return

		map = value


var turn_taker: TurnTaker:
	get:
		return $TurnTaker as TurnTaker


var sprite: ActorSprite:
	get:
		return _sprite


var stats: Stats:
	get:
		return _stats


var _stats: Stats
var _controller: ActorController

@onready var _sprite := $ActorSprite as ActorSprite
@onready var _stamina_bar := %StaminaBar as Range


static func create_actor(p_data: ActorData) -> Actor:
	var actor := _ACTOR_SCENE.instantiate() as Actor
	actor.data = p_data
	return actor


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
	if not is_node_ready():
		await ready

	_sprite.texture = null

	if not data:
		return

	_sprite.texture = data.sprite

	_stats = Stats.new(data.base_stats)

	_stamina_bar.max_value = stats.max_stamina
	_stamina_bar.max_value = stats.stamina
	_stamina_bar.visible = stats.max_stamina != stats.stamina
	stats.stamina_changed.connect(_on_stamina_changed)


func _tile_size_changed() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = pixel_centre
	_sprite.tile_size = tile_size


func _on_turn_taker_turn_started() -> void:
	if _sprite.animation_playing:
		await _sprite.animation_finished

	var action: TurnAction = null
	if _controller:
		@warning_ignore("redundant_await")
		action = await _controller.get_turn_action()
	turn_taker.end_turn(action)


func _on_stamina_changed(_delta: int) -> void:
	_stamina_bar.value = stats.stamina
	_stamina_bar.visible = stats.max_stamina != stats.stamina

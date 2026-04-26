class_name PlayerInput
extends Node

@export var cheats_enabled := false

var player: Actor
var controller: PlayerController

@onready var _timer: Timer = $Timer


var active := false:
	get:
		return is_processing()
	set(value):
		set_process(value)


func _ready() -> void:
	active = false


func _process(_delta: float) -> void:
	if not _timer.is_stopped():
		return

	if cheats_enabled and Input.is_action_just_pressed("click"):
		player.origin_cell = player.map.mouse_cell

	if Input.is_action_just_pressed("wait"):
		_end_turn(null)
		return

	var move_vector := _get_move_vec()
	var next_cell := player.origin_cell + move_vector
	if next_cell == player.origin_cell:
		return

	var move_action := MoveAction.new(player, next_cell)
	var attack_action := AttackAction.new(
			player, player.map.get_actor_on_cell(next_cell))
	var use_action := UseObjectAction.new(
			player.map.get_useable_object_on_cell(next_cell), player.map)

	var action := move_action.with_alternative(
		attack_action.with_alternative(
			use_action.wait_if_failed(false)
		)
	)

	_end_turn(action)


func _get_move_vec() -> Vector2i:
	var result := Vector2i.ZERO

	if Input.is_action_pressed("move_north"):
		result += Vector2i.UP
	if Input.is_action_pressed("move_east"):
		result += Vector2i.RIGHT
	if Input.is_action_pressed("move_south"):
		result += Vector2i.DOWN
	if Input.is_action_pressed("move_west"):
		result += Vector2i.LEFT

	if result.length_squared() > 1:
		result = Vector2i.ZERO

	return result


func _end_turn(action: TurnAction) -> void:
	active = false
	_timer.start()
	controller.send_player_action(action)

class_name PlayerInput
extends Node

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

	if Input.is_action_just_pressed("wait"):
		_end_turn(null)
		return

	var move_vector := _get_move_vec()
	var next_cell := player.origin_cell + move_vector

	var action: TurnAction

	action = _try_move(next_cell)
	if action:
		_end_turn(action)
		return

	action = _try_attack(next_cell)
	if action:
		_end_turn(action)
		return


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

	return result


func _try_move(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	if (next_cell != player.origin_cell) \
			and (player.map.actor_can_enter_cell(player, next_cell)):
		result = MoveAction.new(player, next_cell)
	return result


func _try_attack(next_cell: Vector2i) -> TurnAction:
	var result: TurnAction = null
	var other_actor := player.map.get_actor_on_cell(next_cell)
	if other_actor and other_actor.data.faction != player.data.faction:
		result = AttackAction.new(player, other_actor)
	return result


func _end_turn(action: TurnAction) -> void:
	active = false
	_timer.start()
	controller.send_player_action(action)

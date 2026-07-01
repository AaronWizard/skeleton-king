class_name PlayerInput
extends Node

signal turn_action_selected(action: TurnAction)

@export var cheats_enabled := false

var player: Actor

@onready var _timer: Timer = $Timer


var active := false:
	set(value):
		active = value
		set_process(value)
		set_process_unhandled_input(value)


func _ready() -> void:
	active = false


func _unhandled_input(event: InputEvent) -> void:
	if cheats_enabled and event.is_action_pressed("click"):
		player.origin_cell = player.map.mouse_cell


func _process(_delta: float) -> void:
	if not _timer.is_stopped():
		return

	if Input.is_action_just_pressed("wait"):
		_select_action(null)
		return

	var move_vector := MovementInput.input_move_vect()
	var next_cell := player.origin_cell + move_vector
	if next_cell == player.origin_cell:
		return

	var move_action := MoveAction.new(player, next_cell)
	var attack_action := player.abilities.create_attack_action(next_cell)
	var use_action := UseObjectAction.new(
			player.map.get_useable_object_on_cell(next_cell), player.map)

	var action := CompositeTurnAction.new(
		[move_action, attack_action, use_action]
	)
	action.wait_if_failed = false
	_select_action(action)


func _select_action(action: TurnAction) -> void:
	turn_action_selected.emit(action)
	_timer.start()

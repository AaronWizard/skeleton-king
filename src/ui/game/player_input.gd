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

	var possible_actions: Array[TurnAction] = [
		MoveAction.new(player, next_cell)
	]

	if player.abilities.attack.target_type == TargetType.Type.ACTOR:
		var attack_action := _try_bump_attack(move_vector)
		if attack_action:
			possible_actions.append(attack_action)

	possible_actions.append(
		UseObjectAction.new(
			player.map.get_useable_object_on_cell(next_cell), player.map
		)
	)

	var action := CompositeTurnAction.new(
		possible_actions
	)
	action.wait_if_failed = false
	_select_action(action)


func _try_bump_attack(move_vector: Vector2i) -> TurnAction:
	if move_vector.length_squared() != 1:
		return null

	var direction := Directions.dir_to_cardinal(move_vector)
	var edge_cells := TileGeometry.adjacent_edge_cells(
			player.cell_rect, direction)
	var other_actors := player.map.get_actors_on_cells(edge_cells)
	var target_actors := other_actors.filter(
		func (actor: Actor) -> bool:
			return player.abilities.attack.target_is_valid(
					player, actor.origin_cell)
	)

	var result: TurnAction = null
	if target_actors.size() == 1:
		result = player.abilities.create_attack_action(
			target_actors[0].origin_cell
		)
	return result


func _select_action(action: TurnAction) -> void:
	turn_action_selected.emit(action)
	_timer.start()
